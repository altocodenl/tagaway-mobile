import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';

import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/tools.dart';

class TagService {
   TagService._ ();
   static final TagService instance = TagService._ ();

   dynamic queryTags = [];

   // TODO: annotate
   // canReplaceExisting is to, on load of a new list of thumbs, to sometimes overwrite cloud pivs
   // This will not happen on calls to this function that happen when new local piv pages are loaded on startup, to avoid seeing thumbs changing
   getLocalTagsThumbs ([canReplaceExisting = false]) async {

      var tags = getList ('tags');
      var thumbs = store.get ('thumbs');

      // If no cloud thumbs were loaded, do nothing, since we need those to be loaded before loading the local ones.
      if (thumbs == '') return;

      inner (piv, yearOrMonth) {
         var date = piv.createDateTime.toUtc ();
         var year = 'd::' + date.year.toString (), month = 'd::M' + date.month.toString ();
         var pivTags = <dynamic>[year, month];
         // This is what type systems make you do.
         getList ('pendingTags:' + piv.id).forEach ((tag) => pivTags.add (tag));
         pivTags.forEach ((tag) {
            if (! tags.contains (tag)) tags.add (tag);
         });
         var thumb = {
            'id': piv.id,
            'date': ms (date),
            'vid': piv.type == AssetType.video,
            'currentMonth': [date.year, date.month],
            'tags': pivTags,
            'piv': piv,
            'local': true,
         };
         if (yearOrMonth == 'year' && (thumbs [year] == null || canReplaceExisting)) thumbs [year] = thumb;
         if (yearOrMonth == 'month' && (thumbs [month] == null || canReplaceExisting)) thumbs [month] = thumb;
      };

      // We do two iterations over all the pivs in different order, to minimize the odds of having repeated thumbs for a given year & month
      var localPivs = PivService.instance.localPivs.toList ()..shuffle ();
      localPivs.forEach ((piv) => inner (piv, 'year'));
      localPivs = PivService.instance.localPivs.toList ()..shuffle ();
      localPivs.forEach ((piv) => inner (piv, 'month'));

      if (canReplaceExisting) tags.shuffle ();

      store.set ('tags', tags);
      store.set ('thumbs', thumbs);
   }

   getTags () async {
      var response = await ajax ('get', 'tags');

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your tags - CODE TAGS:' + response ['code'].toString (), 'yellow');
         return;
      }

      store.set ('tags', response ['body'] ['tags'].toList ()..shuffle ());

      updateOrganizedCount (response ['body'] ['organized']);

      store.set ('hometags', response ['body'] ['hometags']);
      store.set ('thumbs', response ['body'] ['homeThumbs'], '', 'mute');

      getLocalTagsThumbs (true);

      var usertags = response ['body'] ['tags'].where ((tag) {
         return ! RegExp ('^[a-z]::').hasMatch (tag);
      }).toList ();

      store.getKeys ('^pendingTags:').forEach ((k) {
         var pendingTags = store.get (k);
         if (pendingTags != '') pendingTags.forEach ((tag) {
            if (! usertags.contains (tag)) usertags.add (tag);
         });
      });
      usertags.sort ();

      store.set ('usertags', usertags);

      store.set ('lastNTags', getList ('lastNTags').where ((tag) {
         return usertags.contains (tag);
      }).toList (), 'disk');
   }

   updateOrganizedCount (organizedNow) {

      var midnight = DateTime (DateTime.now ().year, DateTime.now ().month, DateTime.now ().day);
      var organizedAtDaybreak = store.get ('organizedAtDaybreak');
      if (organizedAtDaybreak == '' || organizedAtDaybreak ['midnight'] < ms (midnight)) store.set ('organizedAtDaybreak', {
         'midnight': ms (midnight),
         'organized': organizedNow
      }, 'disk');

      store.getKeys ('^pendingTags:').forEach ((k) {
         if (store.get (k) != '') organizedNow++;
      });

      store.set ('organized', {
         'total': organizedNow,
         'today': organizedNow - store.get ('organizedAtDaybreak') ['organized']
      });
   }

   // TODO: annotate
   // overall: local + uploaded
   getOverallAchievements () async {

      var localPagesLength = store.get ('localPagesLength');
      if (localPagesLength == '') return;

      var organizedTimeHeader = store.get ('organizedTimeHeader');
      if (organizedTimeHeader == true) return;
      if (organizedTimeHeader == '') {
         store.set ('organizedTimeHeader', true);
         var response = await ajax ('post', 'query', {
            'tags': [],
            'sort': 'newest',
            'timeHeader': true,
            'from': 1,
            'to': 1
         });

         if (response ['code'] != 200) {
            if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your achievements - CODE ACHIEVEMENTS:' + response ['code'].toString (), 'yellow');
            return;
         }

         organizedTimeHeader = response ['body'] ['timeHeader'];
         store.set ('organizedTimeHeader', organizedTimeHeader);
         Future.delayed (Duration (seconds: 10), () {
            store.remove ('organizedTimeHeader');
         });
      }

      // if a local page is fully organized and it has no cloud counterpart, the month is considered organized
      // same with a cloud page that is fully organized without a local counterpart, the month is considered organized
      // if a month has both a local and a cloud page, it is organized if both are
      // no need to look at the localquery, we get the local organization status from the page itself
      // if a local page is fully organized and it has no cloud counterpart, the month is considered organized
      // put local entries in organized
      // then mask it over with cloud, which may complement with more months
      var organized = {};
      Iterable.generate (localPagesLength, (index) => index).forEach ((index) {
         var page = store.get ('localPage:' + index.toString ());
         // local entries are [d::MDD, d::DDDD]
         var year = int.parse (page ['dateTags'] [1].substring (3));
         var month = int.parse (page ['dateTags'] [0].substring (4));
         if (organized [year] == null) organized [year] = {};
         organized [year] [month] = page ['left'] == 0;
      });

      organizedTimeHeader.forEach ((yearMonth, organizedCloud) {
         var year = int.parse (yearMonth.split (':') [0]);
         var month = int.parse (yearMonth.split (':') [1]);
         if (organized [year] == null) organized [year] = {};
         // the mask
         organized [year] [month] = organized [year] [month] == null ? organizedCloud : organized [year] [month] && organizedCloud;
      });

      var achievements = [];

      organized.forEach ((year, entries) {
         if (entries.values.every ((value) => value == true)) achievements.add ([year, 'all']);
         else                      achievements.addAll (entries.keys.map ((month) {
            return entries [month] == true ? [year, month] : null;
         }).where ((entry) => entry != null).toList ());
      });

      achievements.sort ((a, b) {
         return a [0] != b [0] ? a [0].compareTo (b [0]) : a [1].compareTo (b [1]);
      });

      store.set ('achievements', achievements);
   }

   editHometags (String tag, bool add) async {
      await getTags ();

      var hometags = getList ('hometags');
      if ((add && hometags.contains (tag)) || (! add && ! hometags.contains (tag))) return;

      add ? hometags.add (tag) : hometags.remove (tag);

      store.set ('hometags', hometags);

      var response = await ajax ('post', 'hometags', {'hometags': hometags});

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error updating your hometags - CODE HOMETAGS:' + response ['code'].toString (), 'yellow');
      }

      await getTags ();
   }

   updateLastNTags (tag) {
      var lastNTags = getList ('lastNTags');

      if (lastNTags.contains (tag)) lastNTags.remove (tag);
      lastNTags.insert (0, tag);

      var N = 9;
      if (lastNTags.length > N) lastNTags = lastNTags.sublist (0, N);
      store.set ('lastNTags', lastNTags, 'disk');
   }

   tagCloudPiv (dynamic id, dynamic tags, bool del) async {
      for (var tag in tags) {
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': [id], 'del': del, 'autoOrganize': true});
         if (response ['code'] != 200) return response ['code'];
      }

      await queryOrganizedIds ([id]);

      var hometags = getList ('hometags');
      if (! del && hometags.isEmpty) await editHometags (tags [0], true);

      queryPivs (true, true);
      return 200;
   }

   toggleTags (dynamic piv, String type, [selectAll = null]) {

      var pivId;
      try {
        pivId = piv.id;
      }
      catch (error) {
         pivId = piv ['id'];
      }

      var tagMapPrefix = 'tagMap' + (type == 'local' ? 'Local' : 'Uploaded') + ':';

      var state = store.get ('toggleTags' + (type == 'local' ? 'Local' : 'Uploaded'));
      if (state == '') state = {};

      // if false/'', set to true; if true, set to false. This is the toggle.
      if (selectAll != null) state [pivId] = selectAll;
      else                   state [pivId] = store.get (tagMapPrefix + pivId) != true;

      store.set (tagMapPrefix + pivId, state [pivId]);
      store.set ('toggleTags' + (type == 'local' ? 'Local' : 'Uploaded'), state);
   }

   doneTagging (String view) async {

      var tags = store.get ('currentlyTagging' + (view == 'local' ? 'Local' : 'Uploaded'));

      tags.forEach ((tag) => updateLastNTags (tag));

      var state = store.get ('toggleTags' + (view == 'local' ? 'Local' : 'Uploaded'));
      if (state == '') state = {};

      var cloudPivsToTag = [], cloudPivsToUntag = [], localPivsToTagUntag = {};

      state.forEach ((id, tagged) {
         // This relies on cloud pivs having uuids and locals not. We can only be 100% sure of the former.
         var cloudPiv = RegExp ('^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}').hasMatch (id);

         var cloudId = cloudPiv ? id : store.get ('pivMap:' + id);

         if (cloudId == '' || cloudId == true) localPivsToTagUntag [id] = tagged;
         else {
            if (tagged == true) cloudPivsToTag.add (cloudId);
            else                cloudPivsToUntag.add (cloudId);
         }
      });

      if (cloudPivsToTag.length > 0) for (var tag in tags) {
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': cloudPivsToTag, 'autoOrganize': true});
         if (response ['code'] != 200) return showSnackbar ('There was an error tagging your piv - CODE TAG:' + response ['code'].toString (), 'yellow');
      }

      if (cloudPivsToUntag.length > 0) for (var tag in tags) {
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': cloudPivsToUntag, 'del': true, 'autoOrganize': true});
         if (response ['code'] != 200) return showSnackbar ('There was an error tagging your piv - CODE TAG:' + response ['code'].toString (), 'yellow');
      }

      if ((cloudPivsToTag + cloudPivsToUntag).length > 0) queryOrganizedIds (cloudPivsToTag + cloudPivsToUntag);

      var hometags = getList ('hometags');
      if (cloudPivsToTag.length > 0 && hometags.isEmpty) editHometags (tags [0], true);

      if ((cloudPivsToTag + cloudPivsToUntag).length > 0) queryPivs (true, true);

      if (localPivsToTagUntag.keys.length == 0) return;

      var localPivsById = PivService.instance.localPivsById ();

      for (var id in localPivsToTagUntag.keys) {

         var untag = localPivsToTagUntag [id] == false;

         var pendingTags = getList ('pendingTags:' + id);

         tags.forEach ((tag) {
            if (untag)                             pendingTags.remove (tag);
            else if (! pendingTags.contains (tag)) pendingTags.add (tag);
         });

         if (pendingTags.length > 0) store.set    ('pendingTags:' + id, pendingTags, 'disk');
         else                        store.remove ('pendingTags:' + id, 'disk');

         if (! untag) PivService.instance.queuePiv (localPivsById [id]);
         if (pendingTags.length == 0) {
            store.remove ('pivMap:' + id);
            var uploadQueueIndex;
            PivService.instance.uploadQueue.asMap ().forEach ((index, queuedPiv) {
               if (queuedPiv.id == id) uploadQueueIndex = index;
            });
            if (uploadQueueIndex != null) PivService.instance.uploadQueue.removeAt (uploadQueueIndex);
         }
      }
   }

   getTaggedPivs (dynamic tags, String view) async {

      var existing = [], New = [];

      var tagMapPrefix = 'tagMap' + (view == 'local' ? 'Local' : 'Uploaded') + ':';

      store.store.keys.toList ().forEach ((k) {
         if (RegExp ('^' + tagMapPrefix).hasMatch (k)) existing.add (k.split (':') [1]);
         if (RegExp ('^pendingTags:').hasMatch (k)) {
             var pendingTags = store.get (k);
             var tagsContained = true;
             tags.forEach ((tag) {
                if (! pendingTags.contains (tag)) tagsContained = false;
             });
             if (tagsContained) New.add (k.split (':') [1]);
         }
      });

      var response = await ajax ('post', 'query', {
         'tags':    tags,
         'sort':    'newest',
         'from':    1,
         'to':      100000,
         'idsOnly': true
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your tagged pivs - CODE TAGGED:' + response ['code'].toString (), 'yellow');
         return;
      }

      var queryIds;
      if (view == 'uploaded') queryIds = store.get ('queryResult') ['pivs'].map ((v) => v ['id']);
      response ['body'].forEach ((v) {
         if (view == 'uploaded') {
            if (queryIds.contains (v)) New.add (v);
         }
         else {
            var id = store.get ('rpivMap:' + v);
            if (id != '') New.add (id);
         }
      });

      New.forEach ((id) {
        if (! existing.contains (id)) store.set (tagMapPrefix + id, true);
        else existing.remove (id);
      });
      existing.forEach ((id) {
        store.remove (tagMapPrefix + id);
      });

   }

   selectAll (String view, String operation, bool select) {

      if (view == 'local') {
         var currentPage = store.get ('localPage:' + store.get ('localPage').toString ());
         currentPage ['pivs'].forEach ((piv) {
            if (operation == 'delete') toggleDeletion (piv.id, 'local', select);
            if (operation == 'tag')    toggleTags (piv, 'local', select);
         });
      }
      if (view == 'uploaded') {
         var queryResult = store.get ('queryResult');
         queryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) {
               if (operation == 'delete') toggleDeletion (piv ['piv'].id, 'uploaded', select);
               if (operation == 'tag')    toggleTags (piv ['piv'], 'uploaded', select);
            }
            else {
               if (operation == 'delete') toggleDeletion (piv ['id'], 'uploaded', select);
               if (operation == 'tag')    toggleTags (piv, 'uploaded', select);
            }
         });
      }
   }

   localQuery (tags, currentMonth, queryResult) {

      // TODO: remove references to currentMonth if it turns out to be a relic
      currentMonth = '';

      var containsGeoTag = false;
      tags.forEach ((tag) {
         if (RegExp('^g::[A-Z]{2}').hasMatch(tag)) containsGeoTag = true;
      });
      if (containsGeoTag) return queryResult;

      var usertags = tags.where ((tag) {
         return ! RegExp ('^[a-z]::').hasMatch (tag);
      }).toList ();

      var minDate = 0;
      var maxDate = now ();

      var monthTag, yearTag;
      tags.forEach ((tag) {
         if (RegExp ('^d::[0-9]').hasMatch (tag)) yearTag = tag;
         if (RegExp ('^d::M').hasMatch (tag))     monthTag = tag;
      });

      if (yearTag  != null) yearTag  = int.parse (yearTag.substring (3));
      if (monthTag != null) monthTag = int.parse (monthTag.substring (4));

      if (yearTag != null && monthTag == null) {
         minDate = DateTime.utc (yearTag,     1, 1).millisecondsSinceEpoch;
         maxDate = DateTime.utc (yearTag + 1, 1, 1).millisecondsSinceEpoch;
      }
      if (yearTag != null && monthTag != null) {
         minDate = DateTime.utc (yearTag, 1, 1).millisecondsSinceEpoch;
         if (monthTag == 12) maxDate = DateTime.utc (yearTag + 1, 1,            1).millisecondsSinceEpoch;
         else                maxDate = DateTime.utc (yearTag,     monthTag + 1, 1).millisecondsSinceEpoch;
      }

      var minDateCurrentMonth;
      var maxDateCurrentMonth;

      if (currentMonth != '') {
         minDateCurrentMonth = DateTime.utc (currentMonth [0], currentMonth [1], 1).millisecondsSinceEpoch;
         if (currentMonth [1] == 12) maxDateCurrentMonth = DateTime.utc (currentMonth [0] + 1, 1,                    1).millisecondsSinceEpoch;
         else                        maxDateCurrentMonth = DateTime.utc (currentMonth [0],     currentMonth [1] + 1, 1).millisecondsSinceEpoch;
      }

      var localPivsById = PivService.instance.localPivsById ();

      var localPivsToAdd = [];

      var localPivsAlreadyPresent = {};
      queryResult ['pivs'].forEach ((piv) {
         if (piv ['local'] == true) localPivsAlreadyPresent [piv ['piv'].id] = true;
      });

      PivService.instance.localPivs.forEach ((piv) {
         if (store.get ('pivMap:' + piv.id) != '') return;

         if (localPivsAlreadyPresent [piv.id] == true) return;

         var pendingTags = getList ('pendingTags:' + piv.id);
         var dateTags = ['d::' + piv.createDateTime.toUtc ().year.toString (), 'd::M' + piv.createDateTime.toUtc ().month.toString ()];

         if (tags.contains ('o::') && pendingTags.length == 0) return;
         if ((tags.contains ('u::') || tags.contains ('t::')) && pendingTags.length > 0) return;

         if (minDate > ms (piv.createDateTime) || maxDate < ms (piv.createDateTime)) return;
         if (monthTag != null && yearTag == null && piv.createDateTime.toUtc ().month != monthTag) return;

         var matchesQuery = true;
         usertags.forEach ((tag) {
            if (! pendingTags.contains (tag)) matchesQuery = false;
         });
         if (matchesQuery == false) return;

         queryResult ['total'] += 1;
         (pendingTags + dateTags).forEach ((tag) {
            if (queryResult ['tags'] [tag] == null) queryResult ['tags'] [tag] = 0;
            queryResult ['tags'] [tag] += 1;
         });

         var yearMonth = piv.createDateTime.toUtc ().year.toString () + ':' + piv.createDateTime.toUtc ().month.toString ();
         if (queryResult ['timeHeader'] != null) {
            if (pendingTags.length == 0) queryResult ['timeHeader'] [yearMonth] = false;
            else if (queryResult ['timeHeader'] [yearMonth] == null) queryResult ['timeHeader'] [yearMonth] = true;
         }

         if (currentMonth != '') {
            if (minDateCurrentMonth > ms (piv.createDateTime) || maxDateCurrentMonth < ms (piv.createDateTime)) return;
            queryResult ['pivs'].add ({'date': ms (piv.createDateTime), 'piv': piv, 'local': true});
         }
         else localPivsToAdd.add (piv);
      });

      localPivsToAdd.shuffle ();
      localPivsToAdd.forEach ((piv) {
         queryResult ['pivs'].add ({'date': ms (piv.createDateTime), 'piv': piv, 'local': true});
      });

      return queryResult;
   }

   getLocalAchievements (pageIndex) async {
      var storageKey = 'localAchievements:' + pageIndex.toString ();
      var page = store.get ('localPage:' + pageIndex.toString ());

      if (page == '') return store.set (storageKey, []);
      var response = await ajax ('post', 'query', {
         'tags': ['o::'],
         'sort': 'newest',
         'mindate': page ['from'],
         'maxdate': page ['to'],
         'from': 1,
         'to': 1
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your achievements - CODE ACHIEVEMENTS:' + response ['code'].toString (), 'yellow');
         return store.set (storageKey, []);
      }

      var localPivsById = PivService.instance.localPivsById ();

      var localCount = {}, localQueryTotal = 0;
      store.getKeys ('^pendingTags:').forEach ((key) {
         var piv = localPivsById [key.replaceAll ('pendingTags:', '')];
         if (piv == null) return;
         if (page ['from'] > ms (piv.createDateTime) || page ['to'] < ms (piv.createDateTime)) return;

         localQueryTotal++;

         var pendingTags = getList (key);
         pendingTags.forEach ((tag) {
            if (localCount [tag] == null) localCount [tag] = 0;
            localCount [tag]++;
         });
      });

      var output = [];

      response ['body'] ['tags'].keys.forEach ((tag) {
         if (RegExp ('^[a-z]::').hasMatch (tag)) return;
         var value = response ['body'] ['tags'] [tag];
         output.add ([tag, value]);
      });

      localCount.keys.forEach ((tag) {
         var matchingRow = output.indexWhere ((row) => row [0] == tag);
         if (matchingRow == -1) output.add ([tag, localCount [tag]]);
         else output [matchingRow] [1] += localCount [tag];
      });

      output.sort ((a, b) {
         return (b [1] as int).compareTo ((a [1] as int));
      });

      if (output.length > 3) output = output.sublist (0, 3);
      output.add (['Total', response ['body'] ['total'] + localQueryTotal]);

      var organized = store.get ('organized');
      if (organized != '') output.add (['All time organized', store.get ('organized') ['total']]);

      store.set (storageKey, output);
   }

   queryPivs ([refresh = false, preserveMonth = false]) async {

      var tags = getList ('queryTags');
      tags.sort ();

      if ((store.get ('queryResult') != '' || store.get ('queryInProgress') == true) && refresh == false && listEquals (tags, queryTags)) return;

      var currentMonth = store.get ('currentMonth');
      if (preserveMonth == true && currentMonth != '') return queryPivsForMonth (currentMonth);

      queryTags = List.from (tags);

      var firstLoadSize = 300;

      Future.delayed (Duration (milliseconds: 1), () {
        store.set ('queryInProgress', true);
      });

      var response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'timeHeader': true,
         'from': 1,
         'to': firstLoadSize
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:A:' + response ['code'].toString (), 'yellow');
         store.remove ('queryInProgress');
         return response ['code'];
      }

      if (! listEquals (queryTags, tags)) return 409;

      var queryResult = response ['body'];
      if (queryResult ['lastMonth'] == null) store.remove ('currentMonth');
      else {
         var lastMonth = queryResult ['lastMonth'] [0].split (':');
         store.set ('currentMonth', [int.parse (lastMonth [0]), int.parse (lastMonth [1])]);
      }
      queryResult = localQuery (tags, store.get ('currentMonth'), queryResult);

      if (queryResult ['total'] == 0 && tags.length > 0) {
         store.remove ('currentlyTaggingUploaded');
         store.remove ('showSelectAllButtonUploaded');
         return store.set ('queryTags', []);
      }

      store.set ('queryResult', {
         'timeHeader':  queryResult ['timeHeader'],
         'total':       0,
         'tags':        {'a::': 0, 'u::': 0, 't::': 0, 'o::': 0},
         'pivs':        []
      }, '', 'mute');

      computeTimeHeader ();

      if (queryResult ['total'] > 0 && queryResult ['lastMonth'] != null && queryResult ['lastMonth'] [1] < queryResult ['pivs'].length) {
         queryResult ['pivs'].removeRange (queryResult ['lastMonth'] [1], queryResult ['pivs'].length);
      }

      if (tags.contains ('o::')) {
         queryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            store.set ('orgMap:' + piv ['id'], true);
         });
      }
      else queryOrganizedIds (queryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());

      if (queryResult ['total'] > 0 && queryResult ['lastMonth'] != null && queryResult ['pivs'].length < queryResult ['lastMonth'] [1]) {
         queryResult ['pivs'] = [...queryResult ['pivs'], ...List.generate (queryResult ['lastMonth'] [1] - queryResult ['pivs'].length, (v) => {'placeholder': true})];
      }

      store.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        queryResult ['pivs']
      });

      store.remove ('queryInProgress');

      getTags ();

      if (queryResult ['total'] == 0 || queryResult ['pivs'].last ['placeholder'] == null) return 200;

      response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'from': 1,
         'to': queryResult ['lastMonth'] [1],
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:B:' + response ['code'].toString (), 'yellow');
         return response ['code'];
      }

      if (! listEquals (queryTags, tags)) return 409;

      var secondQueryResult = response ['body'];
      secondQueryResult = localQuery (tags, store.get ('currentMonth'), secondQueryResult);

      store.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        secondQueryResult ['pivs']
      }, '', 'mute');

      if (tags.contains ('o::')) {
         secondQueryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            store.set ('orgMap:' + piv ['id'], true);
         });
      }
      else queryOrganizedIds (secondQueryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());

      return 200;
   }

   // TODO: annotate the code below

   queryPivsForMonth (dynamic currentMonth) async {

      var tags = getList ('queryTags');
      tags.sort ();

      queryTags = List.from (tags);

      // The streams join here. We get all the pivs for the month. We only care about the pivs.
      var currentMonthTags = ['d::' + currentMonth [0].toString (), 'd::M' + currentMonth [1].toString ()];

      // Do it quickly to show changes to the user before the roundtrip
      store.set ('currentMonth', currentMonth);
      computeTimeHeader ();

      store.set ('queryInProgress', true);

      var response = await ajax ('post', 'query', {
         'tags': ([...tags]..addAll (currentMonthTags)).toSet ().toList (),
         'sort': 'newest',
         'from': 1,
         'to': 100000
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:C:' + response ['code'].toString (), 'yellow');
         store.remove ('queryInProgress');
         return response ['code'];
      }

      if (! listEquals (queryTags, tags)) return 409;

      var queryResultForPivs = response ['body'];
      // We copy these to pass them below to avoid a double adding of local pivs
      var pivsWithoutLocal = List.from (response ['body'] ['pivs']);
      // This is done here because we want to avoid an early ronin return
      queryResultForPivs = localQuery (tags, currentMonth, queryResultForPivs);

      if (queryResultForPivs ['total'] == 0 && tags.length > 0) {
         store.remove ('currentlyTaggingUploaded');
         store.remove ('showSelectAllButtonUploaded');
         return store.set ('queryTags', []);
      }

      if (tags.contains ('o::')) {
         queryResultForPivs ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            store.set ('orgMap:' + piv ['id'], true);
         });
      }
      // We don't await on purpose
      else queryOrganizedIds (queryResultForPivs ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());

      response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'timeHeader': true,
         'from': 1,
         'to': 1
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:D:' + response ['code'].toString (), 'yellow');
         store.remove ('queryInProgress');
         return response ['code'];
      }

      if (! listEquals (queryTags, tags)) return 409;

      var queryResult = response ['body'];
      queryResult ['pivs'] = pivsWithoutLocal;
      queryResult = localQuery (tags, currentMonth, queryResult);

      store.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        queryResult ['pivs']
      });

      // Do it again in case this function was called from home and there was no queryResult when we called computeTimeHeader above
      computeTimeHeader ();

      getTags ();

      store.remove ('queryInProgress');
      return 200;
   }

  toggleQueryTag (String tag) {
    // We copy it to avoid the update not triggering anything
    var queryTags = store.get ('queryTags').toList ();
    if (queryTags.contains (tag)) queryTags.remove (tag);
    else                          queryTags.add (tag);
    store.set ('queryTags', queryTags);
  }

  deleteUploadedPivs (dynamic ids) async {

   // remove queued local piv
    var localPivsById = PivService.instance.localPivsById ();

    var filteredIds = ids.toList ();
    var localPivs = [];
    ids.forEach ((id) {
       if (localPivsById [id] == null) return;
       filteredIds.remove (id);
       localPivs.add (id);
       PivService.instance.uploadQueue.remove (localPivsById [id]);
       store.remove ('pendingTags:' + id);
    });

    if (localPivs.length > 0) PivService.instance.deleteLocalPivs (localPivs);

    if (filteredIds.length == 0) return;

    var response = await ajax ('post', 'delete', {'ids': filteredIds});

    if (response ['code'] != 200) {
       if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error deleting your pivs - CODE DELETE:' + response ['code'].toString (), 'yellow');
       return;
    }

    filteredIds.forEach ((id) {
       var localPivId = store.get ('rpivMap:' + id);
       if (localPivId != '') {
         store.remove ('pivMap:' + localPivId);
         store.remove ('rpivMap:' + id);
       }
    });
    store.remove ('currentlyDeletingPivsUploaded');
    await queryPivs (true, true);
  }

   renameTag (String from, String to) async {
      var response = await ajax ('post', 'rename', {'from': from, 'to': to});
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error renaming the tag - CODE RENAME:' + response ['code'].toString (), 'yellow');
         return;
      }

      await getTags ();
      var queryTags = getList ('queryTags');
      if (queryTags.contains (from)) {
         queryTags.remove (from);
         queryTags.add (to);
      }
      store.set ('queryTags', queryTags);
      await queryPivs (true, true);
   }

   deleteTag (String tag) async {
      var response = await ajax ('post', 'deleteTag', {'tag': tag});
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error deleting the tag - CODE RENAME:' + response ['code'].toString (), 'yellow');
         return;
      }
      await getTags ();
      var queryTags = getList ('queryTags');
      // Is this conditional necessary?
      if (queryTags.contains (tag)) queryTags.remove (tag);
      store.set ('queryTags', queryTags);
      await queryPivs (true, true);
   }

   toggleDeletion (String id, String view, [selectAll = null]) {
      var key = 'currentlyDeletingPivs' + (view == 'local' ? 'Local' : 'Uploaded');
      var currentlyDeletingPivs = getList (key);
      // copy
      currentlyDeletingPivs = currentlyDeletingPivs.toList ();
      if (selectAll != null) {
         if (currentlyDeletingPivs.contains (id) == selectAll) return;
      }
      if (! currentlyDeletingPivs.contains (id)) currentlyDeletingPivs.add (id);
      else currentlyDeletingPivs.remove (id);
      store.set (key, currentlyDeletingPivs);
   }

   // This is for the uploaded grid only
   getMonthEdges () {
      var currentMonth = store.get ('currentMonth');
      var timeHeader = store.get ('timeHeader');
      if (currentMonth == '' || timeHeader == '') return {'previousMonth': '', 'nextMonth': ''};
      var nonWhiteMonths = [];
      var index = -1;
      var currentMonthIndex;
      timeHeader.forEach ((semester) {
         semester.forEach ((month) {
           if (month [2] == 'white') return;
           index++;
           if (month [0] == currentMonth [0] && month [1] == currentMonth [1]) {
             currentMonthIndex = index;
           }
           nonWhiteMonths.add ([month [0], month [1]]);
         });
      });
      // If no pivs, no current month. Return an object with neither previous nor next.
      if (currentMonthIndex == null) return {'previousMonth': '', 'nextMonth': ''};
      var previousMonth = currentMonthIndex == 0     ? '' : nonWhiteMonths [currentMonthIndex - 1];
      var nextMonth     = currentMonthIndex == index ? '' : nonWhiteMonths [currentMonthIndex + 1];
      return {'previousMonth': previousMonth, 'nextMonth': nextMonth};
   }

   queryOrganizedIds (dynamic ids) async {
      var response = await ajax ('post', 'organized', {'ids': ids});
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your organized pivs - CODE ORGANIZE:' + response ['code'].toString (), 'yellow');
         return;
      }

      var organizedIds = {};
      response ['body'].forEach ((id) {
         organizedIds [id] = true;
      });

      // These sets are sync, so we don't need to await.
      ids.forEach ((id) {
         store.set ('orgMap:' + id, organizedIds [id] == true ? true : '');
      });
   }

   computeTimeHeader () {
      var output      = [];
      var min, max;
      if (store.get ('queryResult') == '') return;
      var timeHeader = store.get ('queryResult') ['timeHeader'];
      var currentMonth = store.get ('currentMonth');
      // We initialize the current month to an array signifying there's no current month.
      if (currentMonth == '') currentMonth = [0, 1];
      timeHeader.keys.forEach ((v) {
         var dates = v.split (':');
         dates = [int.parse (dates [0]), int.parse (dates [1])];
         // Round down to the beginning of the semester
         if (dates [1] < 7) dates [1] = 1;
         else               dates [1] = 7;
         if (min == null) min = dates;
         if (max == null) max = dates;
         if (dates [0] < min [0] || (dates [0] == min [0] && dates [1] < min [1])) min = dates;
         if (dates [0] > max [0] || (dates [0] == max [0] && dates [1] < max [1])) max = dates;
      });
      // No uploaded pivs, return current semester as empty.
      if (timeHeader.keys.length == 0) {
        max = [DateTime.now ().year, DateTime.now ().month > 6 ? 12 : 6];
        min = [DateTime.now ().year, DateTime.now ().month < 7 ? 1 : 7];
      }
      // Semester is an array of months.
      // A month is [year, month, color, selected (boolean), id of the last piv on the month]
      for (var year = min [0]; year <= max [0]; year++) {
         for (var month = 1; month <= 12; month++) {
           var dateKey = year.toString () + ':' + month.toString ();
           var isCurrentMonth = year == currentMonth [0] && month == currentMonth [1];
           if (timeHeader [dateKey] == null)       output.add ([year, month, 'white', false]);
           else if (timeHeader [dateKey] == false) output.add ([year, month, 'gray', isCurrentMonth]);
           else                                    output.add ([year, month, 'green', isCurrentMonth]);
         }
      }
      var semesters = [[]];
      output.forEach ((month) {
         var lastSemester = semesters [semesters.length - 1];
         if (lastSemester.length < 6) lastSemester.add (month);
         else semesters.add ([month]);
      });

      // Filter out ronin semesters if we have pivs
      if (timeHeader.keys.length > 0) {
         semesters = semesters.where ((semester) {
            var nonWhite = 0;
            semester.forEach ((month) {
               if (month [2] != 'white') nonWhite++;
            });
            return nonWhite > 0;
         }).toList ();
      }

      store.set ('timeHeader', semesters);

      var newCurrentPage;
      semesters.asMap ().forEach ((k, semester) {
        semester.forEach ((month) {
           if (month [0] == currentMonth [0] && month [1] == currentMonth [1]) {
             // Pages are inverted, that's why we use this index and not `k` itself.
             newCurrentPage = semesters.length - k - 1;
           }
        });
      });

      var currentPage = store.get ('timeHeaderPage');
      if (currentPage != newCurrentPage) {
         var pageController = store.get ('timeHeaderController');
         // The conditional prevents scrolling semesters if the uploaded view is not active.
         // new current page might be null if suddenly there's no more pages due to untagging
         // or if there is no current month because there's no pivs
         if (pageController != '' && pageController.hasClients && newCurrentPage != null) {
            pageController.animateToPage (newCurrentPage, duration: Duration (milliseconds: 500), curve: Curves.easeInOut);
         }
      }

      var yearIndex = semesters.length - 1 - (currentPage == '' ? 0 : currentPage);
      if (yearIndex >= 0) store.set ('yearUploaded', semesters [yearIndex as dynamic] [0] [0]);
   }

   getTagList (currentTags, tagFilter, ignoreCurrentTags) {
      if (tagFilter == null) tagFilter == '';
      var ignoreTags = [];
      if (ignoreCurrentTags && currentTags != null) ignoreTags = currentTags;

      // Place currentTags, lastNTags and hometags first.
      var usertags = currentTags + getList ('lastNTags') + getList ('hometags') + getList ('usertags');
      // Eliminate duplicates.
      usertags = usertags.toSet ().toList ();
      // Eliminate ignored tags
      usertags = usertags.where ((tag) => ! ignoreTags.contains (tag)).toList ();
      // Eliminate by filter
      usertags = usertags.where ((tag) => RegExp (RegExp.escape (tagFilter), caseSensitive: false).hasMatch (tag)).toList ();

      // If there's a filter, sort at the top the tags that start with the filter
      // Sorting is stable in Dart
      if (tagFilter != '') usertags.sort ((a, b) {
         bool startsWithA = a.startsWith (tagFilter);
         bool startsWithB = b.startsWith (tagFilter);
         if (startsWithA   && ! startsWithB) return -1;
         if (! startsWithA && startsWithB) return 1;
         // The Dart type system needs the `as int`, apparently, but the weird thing is that if this is not here, we get a runtime error (not a compile-time error)
         return a.compareTo (b) as int;
      });

      // Insert new tag
      if (tagFilter != '' && ! usertags.contains (tagFilter)) usertags.insert (0, tagFilter + ' (new tag)');

      if (usertags.length == 0) usertags.addAll (['Family (example)', 'Holidays (example)', 'Friends (example)']);

      if (RegExp ('^org', caseSensitive: false).hasMatch (RegExp.escape (tagFilter))) usertags.add ('o::');

      return usertags;
   }

}

