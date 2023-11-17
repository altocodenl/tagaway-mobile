import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:tagaway/services/pivService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tools.dart';

class TagService {
   TagService._ ();
   static final TagService instance = TagService._ ();

   dynamic queryTags = '';

   getTags () async {
      var response = await ajax ('get', 'tags');

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your tags - CODE TAGS:' + response ['code'].toString (), 'yellow');
         return;
      }

      StoreService.instance.set ('tags', response ['body'] ['tags']);

      var homeThumbs = {};
      response ['body'] ['hometags'].forEach ((tag) async {
         var res = await ajax ('post', 'query', {
            'tags':    [tag],
            'sort':    'newest',
            'from':    1,
            'to':      1,
         });

         if (res ['code'] != 200) {
            if (! [0, 403].contains (res ['code'])) showSnackbar ('There was an error getting your tags - CODE TAGS:' + res ['code'].toString (), 'yellow');
            return;
         }
         if (res ['body'] ['pivs'].length > 0) homeThumbs [tag] = res ['body'] ['pivs'] [0];
         if (homeThumbs.length == response ['body'] ['hometags'].length) {
            StoreService.instance.set ('hometags', response ['body'] ['hometags']);
            StoreService.instance.set ('homeThumbs', homeThumbs);
         }
      });

      var usertags = response ['body'] ['tags'].where ((tag) {
         return ! RegExp ('^[a-z]::').hasMatch (tag);
      }).toList ();

      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (! RegExp ('^pendingTags:').hasMatch (k)) return;
         var pendingTags = StoreService.instance.get (k);
         if (pendingTags != '') pendingTags.forEach ((tag) {
            if (! usertags.contains (tag)) usertags.add (tag);
         });
      });
      usertags.sort ();

      StoreService.instance.set ('usertags', usertags);

      StoreService.instance.set ('lastNTags', getList ('lastNTags').where ((tag) {
         return usertags.contains (tag);
      }).toList (), 'disk');
   }

   editHometags (String tag, bool add) async {
      await getTags ();

      var hometags = getList ('hometags');
      if ((add && hometags.contains (tag)) || (! add && ! hometags.contains (tag))) return;

      add ? hometags.add (tag) : hometags.remove (tag);
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

      var N = 7;
      if (lastNTags.length > N) lastNTags = lastNTags.sublist (0, N);
      StoreService.instance.set ('lastNTags', lastNTags, 'disk');
   }

   tagCloudPiv (String id, dynamic tags, bool del) async {
      for (var tag in tags) {
         var response = await ajax ('post', 'tag', {'tag': tag, 'ids': [id], 'del': del, 'autoOrganize': true});
         if (response ['code'] != 200) return response ['code'];
      }

      await queryOrganizedIds ([id]);

      var hometags = StoreService.instance.get ('hometags');
      if (! del && (hometags == '' || hometags.isEmpty)) await editHometags (tags [0], true);

      queryPivs (true, true);
      return 200;
   }

   toggleTags (dynamic piv, dynamic tags, String type) async {
      var pivId   = type == 'uploaded' ? piv ['id'] : piv.id;
      var cloudId = type == 'uploaded' ? pivId      : StoreService.instance.get ('pivMap:' + pivId);

      var untag = StoreService.instance.get ('tagMap:' + pivId) != '';
      StoreService.instance.set ('tagMap:' + pivId, untag ? '' : true);

      if (! untag && type == 'local') {
         var currentlyTaggingPivs = StoreService.instance.get ('currentlyTaggingPivs');
         if (currentlyTaggingPivs == '') currentlyTaggingPivs = [];
         currentlyTaggingPivs.add (pivId);
         StoreService.instance.set ('currentlyTaggingPivs', currentlyTaggingPivs);
      }

      tags.forEach ((tag) => updateLastNTags (tag));

      if (cloudId != '' && cloudId != true) {
         var code = await tagCloudPiv (cloudId, tags, untag);
         var unexpectedCode = type == 'uploaded' ? code != 200 : (code != 200 && code != 404);
         if (unexpectedCode) {
            return showSnackbar ('There was an error tagging your piv - CODE TAG:' + (type == 'uploaded' ? 'C' : 'L') + code.toString (), 'yellow');
         }

         if (code == 200) return;

         if (code == 404) {
            StoreService.instance.remove ('pivMap:'  + pivId);
            StoreService.instance.remove ('rpivMap:' + cloudId);
         }
      }

      var pendingTags = StoreService.instance.get ('pending:' + pivId);
      if (pendingTags == '') pendingTags = [];

      tags.forEach ((tag) => untag ? pendingTags.remove (tag) : pendingTags.add (tag));

      if (pendingTags.length > 0) StoreService.instance.set    ('pendingTags:' + pivId, pendingTags, 'disk');
      else                        StoreService.instance.remove ('pendingTags:' + pivId, 'disk');

      if (! untag) return PivService.instance.queuePiv (piv);

      if (pendingTags.length == 0) {
         StoreService.instance.remove ('pivMap:' + pivId);
         var uploadQueueIndex;
         PivService.instance.uploadQueue.asMap ().forEach ((index, queuedPiv) {
            if (queuedPiv.id == pivId) uploadQueueIndex = index;
         });
         if (uploadQueueIndex != null) {
            PivService.instance.uploadQueue.removeAt (uploadQueueIndex);
         }
      }
   }

   getTaggedPivs (dynamic tags, String view) async {

      var existing = [], New = [];

      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (RegExp ('^tagMap:').hasMatch (k)) existing.add (k.split (':') [1]);
         if (RegExp ('^pendingTags:').hasMatch (k)) {
             var pendingTags = StoreService.instance.get (k);
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
      if (view == 'uploaded') queryIds = StoreService.instance.get ('queryResult') ['pivs'].map ((v) => v ['id']);
      response ['body'].forEach ((v) {
         if (view == 'uploaded') {
            if (queryIds.contains (v)) New.add (v);
         }
         else {
            var id = StoreService.instance.get ('rpivMap:' + v);
            if (id != '') New.add (id);
         }
      });

      New.forEach ((id) {
        if (! existing.contains (id)) StoreService.instance.set ('tagMap:' + id, true);
        else existing.remove (id);
      });
      existing.forEach ((id) {
        StoreService.instance.remove ('tagMap:' + id);
      });

   }

   selectAll (String view, String operation, bool select) {

      // get all local on the current page, or all uploaded that match the month
      // all uploaded is all pivs in the query, because we get them one at a time
      var localPage = StoreService.instance.get ('localPage');

      if (operation == 'delete') {
                    //var pivsToDelete = StoreService.instance .get('currentlyDeletingPivs' + widget.view);
      }

      //var ids;
      // toggleTags (dynamic piv, dynamic tags, view.toLowerCase ()) async {
      // toggleDeletion (String id, String view) {

      if (operation == 'tag') {
      }
   }

   localQuery (tags, currentMonth, queryResult) {
      if (tags.contains ('u::') || tags.contains ('t::')) return queryResult;

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
         if (RegExp('^d::[0-9]').hasMatch(tag)) monthTag = tag;
         if (RegExp('^d::M').hasMatch(tag))     yearTag = tag;
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

      var minDateCurrentMonth = 0;
      var maxDateCurrentMonth = now ();
      if (currentMonth != '') {
         minDateCurrentMonth = DateTime.utc (currentMonth [0], currentMonth [1], 1).millisecondsSinceEpoch;
         if (currentMonth [1] == 12) maxDateCurrentMonth = DateTime.utc (currentMonth [0] + 1, 1,                    1).millisecondsSinceEpoch;
         else                        maxDateCurrentMonth = DateTime.utc (currentMonth [0],     currentMonth [1] + 1, 1).millisecondsSinceEpoch;
      }

      var localPivsById = {};
      PivService.instance.localPivs.forEach ((v) {
         localPivsById [v.id] = v;
      });

      /* UNCOMMENT AFTER TESTING
      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (! RegExp ('^pendingTags:').hasMatch (k)) return;
         var piv = localPivsById [k.replaceAll ('pendingTags:', '')];
         var pendingTags = StoreService.instance.get (k);
         */

      // TODO: remove the next two lines after testing
      PivService.instance.localPivs.forEach ((piv) {
         var pendingTags = ['a local tag'];

         if (minDate > ms (piv.createDateTime) || maxDate < ms (piv.createDateTime)) return;
         if (monthTag != null && yearTag == null && piv.createDateTime.toUtc ().month != monthTag) return;

         var matchesQuery = true;
         usertags.forEach ((tag) {
            if (! pendingTags.contains (tag)) matchesQuery = false;
         });
         if (matchesQuery == false) return;

         queryResult ['total'] += 1;
         pendingTags.forEach ((tag) {
            if (queryResult ['tags'] [tag] == null) queryResult ['tags'] [tag] = 0;
            queryResult ['tags'] [tag] += 1;
         });

         if (minDateCurrentMonth > ms (piv.createDateTime) || maxDateCurrentMonth < ms (piv.createDateTime)) return;
         queryResult ['pivs'].add ({'date': ms (piv.createDateTime), 'piv': piv, 'local': true});
      });

      queryResult ['pivs'].sort ((a, b) {
         return (b ['date'] as int).compareTo ((a ['date'] as int));
      });

      return queryResult;
   }

   queryPivs ([refresh = false, preserveMonth = false]) async {

      var tags = StoreService.instance.get ('queryTags');
      if (tags == '') tags = [];
      tags.sort ();

      if (StoreService.instance.get ('queryResult') != '' && refresh == false && listEquals (tags, queryTags)) return;

      var currentMonth = StoreService.instance.get ('currentMonth');
      if (preserveMonth == true && currentMonth != '') return queryPivsForMonth (currentMonth);

      queryTags = List.from (tags);

      var firstLoadSize = 300;

      var response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'timeHeader': true,
         'from': 1,
         'to': firstLoadSize
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:A:' + response ['code'].toString (), 'yellow');
         return response ['code'];
      }

      if (! listEquals (queryTags, tags)) return 409;

      var queryResult = response ['body'];

      if (queryResult ['total'] == 0 && tags.length > 0) {
         StoreService.instance.remove ('currentlyTaggingUploaded');
         StoreService.instance.remove ('showSelectAllButtonUploaded');
         return StoreService.instance.set ('queryTags', []);
      }

      StoreService.instance.set ('queryResult', {
         'timeHeader':  queryResult ['timeHeader'],
         'total':       0,
         'tags':        {'a::': 0, 'u::': 0, 't::': 0, 'o::': 0},
         'pivs':        []
      }, '', 'mute');

      if (queryResult ['lastMonth'] == null) StoreService.instance.remove ('currentMonth');
      else {
         var lastMonth = queryResult ['lastMonth'] [0].split (':');
         StoreService.instance.set ('currentMonth', [int.parse (lastMonth [0]), int.parse (lastMonth [1])]);
      }
      computeTimeHeader ();

      if (queryResult ['total'] > 0 && queryResult ['lastMonth'] [1] < queryResult ['pivs'].length) {
         queryResult ['pivs'].removeRange (queryResult ['lastMonth'] [1], queryResult ['pivs'].length);
      }

      if (tags.contains ('o::')) {
         queryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            StoreService.instance.set ('orgMap:' + piv ['id'], true);
         });
      }
      else queryOrganizedIds (queryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());

      queryResult = localQuery (tags, currentMonth, queryResult);

      if (queryResult ['total'] > 0 && queryResult ['pivs'].length < queryResult ['lastMonth'] [1]) {
         queryResult ['pivs'] = [...queryResult ['pivs'], ...List.generate (queryResult ['lastMonth'] [1] - queryResult ['pivs'].length, (v) => {'placeholder': true})];
      }

      StoreService.instance.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        queryResult ['pivs']
      });

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
      secondQueryResult = localQuery (tags, currentMonth, secondQueryResult);

      StoreService.instance.set ('queryResult', {
         'total':       queryResult ['total'],
         'tags':        queryResult ['tags'],
         'timeHeader':  queryResult ['timeHeader'],
         'pivs':        secondQueryResult ['pivs']
      }, '', 'mute');

      if (tags.contains ('o::')) {
         secondQueryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            StoreService.instance.set ('orgMap:' + piv ['id'], true);
         });
      }
      else queryOrganizedIds (secondQueryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());

      return 200;
   }

   // TODO: annotate the code below

   queryPivsForMonth (dynamic currentMonth) async {

      var tags = StoreService.instance.get ('queryTags');
      if (tags == '') tags = [];
      tags.sort ();

      // The streams join here. We get all the pivs for the month. We only care about the pivs.
      var currentMonthTags = ['d::' + currentMonth [0].toString (), 'd::M' + currentMonth [1].toString ()];

      // Do it quickly to show changes to the user before the roundtrip
      StoreService.instance.set ('currentMonth', currentMonth);
      computeTimeHeader (false);

      var response = await ajax ('post', 'query', {
         'tags': ([...tags]..addAll (currentMonthTags)).toSet ().toList (),
         'sort': 'newest',
         'from': 1,
         'to': 100000
      });

      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error getting your pivs - CODE QUERY:A:' + response ['code'].toString (), 'yellow');
         return response ['code'];
      }

      if (! listEquals (queryTags, tags)) return 409;

      var queryResult = response ['body'];
      queryResult = localQuery (tags, currentMonth, queryResult);

      if (queryResult ['total'] == 0 && tags.length > 0) {
         StoreService.instance.remove ('currentlyTaggingUploaded');
         StoreService.instance.remove ('showSelectAllButtonUploaded');
         return StoreService.instance.set ('queryTags', []);
      }

      var oldQueryResult = StoreService.instance.get ('queryResult');

      StoreService.instance.set ('queryResult', {
         'total':       oldQueryResult ['total'],
         'tags':        oldQueryResult ['tags'],
         'timeHeader':  oldQueryResult ['timeHeader'],
         'pivs':        queryResult ['pivs']
      });
      // Not mute on purpose!

      if (tags.contains ('o::')) {
         queryResult ['pivs'].forEach ((piv) {
            if (piv ['local'] == true) return;
            StoreService.instance.set ('orgMap:' + piv ['id'], true);
         });
      }
      else queryOrganizedIds (queryResult ['pivs'].where ((v) => v ['local'] == null).map ((v) => v ['id']).toList ());

      getTags ();
      return 200;
   }

  toggleQueryTag (String tag) {
    // We copy it to avoid the update not triggering anything
    var queryTags = StoreService.instance.get ('queryTags').toList ();
    if (queryTags.contains (tag)) queryTags.remove (tag);
    else                          queryTags.add (tag);
    StoreService.instance.set ('queryTags', queryTags);
  }

  deleteUploadedPivs (dynamic ids) async {

   // remove queued local piv
    var localPivsById = {};
    PivService.instance.localPivs.forEach ((v) {
       localPivsById [v.id] = v;
    });
    var filteredIds = ids.toList ();
    ids.forEach ((id) {
       if (localPivsById [id] == null) return;
       filteredIds.remove (id);
       PivService.instance.uploadQueue.remove(localPivsById [id]);
       StoreService.instance.remove('pendingTags:' + id);
    });

    if (filteredIds.length == 0) return;

    var response = await ajax ('post', 'delete', {'ids': filteredIds});

    if (response ['code'] != 200) {
       if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error deleting your pivs - CODE DELETE:' + response ['code'].toString (), 'yellow');
       return;
    }

    filteredIds.forEach ((id) {
       var localPivId = StoreService.instance.get ('rpivMap:' + id);
       if (localPivId != '') {
         StoreService.instance.remove ('pivMap:' + localPivId);
         StoreService.instance.remove ('rpivMap:' + id);
       }
    });
    StoreService.instance.remove ('currentlyDeletingPivsUploaded');
    await queryPivs (true, true);
  }

   renameTag (String from, String to) async {
      var response = await ajax ('post', 'rename', {'from': from, 'to': to});
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error renaming the tag - CODE RENAME:' + response ['code'].toString (), 'yellow');
         return;
      }

      await getTags ();
      var queryTags = StoreService.instance.get ('queryTags');
      if (queryTags == '') queryTags = [];
      if (queryTags.contains (from)) {
         queryTags.remove (from);
         queryTags.add (to);
      }
      StoreService.instance.set ('queryTags', queryTags);
      await queryPivs (true, true);
   }

   deleteTag (String tag) async {
      var response = await ajax ('post', 'deleteTag', {'tag': tag});
      if (response ['code'] != 200) {
         if (! [0, 403].contains (response ['code'])) showSnackbar ('There was an error deleting the tag - CODE RENAME:' + response ['code'].toString (), 'yellow');
         return;
      }
      await getTags ();
      var queryTags = StoreService.instance.get ('queryTags');
      if (queryTags == '') queryTags = [];
      // Is this conditional necessary?
      if (queryTags.contains (tag)) queryTags.remove (tag);
      StoreService.instance.set ('queryTags', queryTags);
      await queryPivs (true, true);
   }

   toggleDeletion (String id, String view) {
      var key = 'currentlyDeletingPivs' + (view == 'local' ? 'Local' : 'Uploaded');
      var currentlyDeletingPivs = StoreService.instance.get (key);
      if (currentlyDeletingPivs == '') currentlyDeletingPivs = [];
      // copy
      currentlyDeletingPivs = currentlyDeletingPivs.toList ();
      if (! currentlyDeletingPivs.contains (id)) currentlyDeletingPivs.add (id);
      else currentlyDeletingPivs.remove (id);
      StoreService.instance.set (key, currentlyDeletingPivs);
   }

   // This is for the uploaded grid only
   getMonthEdges () {
      var currentMonth = StoreService.instance.get ('currentMonth');
      var timeHeader = StoreService.instance.get ('timeHeader');
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
         StoreService.instance.set ('orgMap:' + id, organizedIds [id] == true ? true : '');
      });
   }

   computeTimeHeader ([updateYearUploaded = true]) {
      var output      = [];
      var min, max;
      var timeHeader = StoreService.instance.get ('queryResult') ['timeHeader'];
      var currentMonth = StoreService.instance.get ('currentMonth');
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

      StoreService.instance.set ('timeHeader', semesters);

      var newCurrentPage;
      semesters.asMap ().forEach ((k, semester) {
        semester.forEach ((month) {
           if (month [0] == currentMonth [0] && month [1] == currentMonth [1]) {
             // Pages are inverted, that's why we use this index and not `k` itself.
             newCurrentPage = semesters.length - k - 1;
           }
        });
      });

      var currentPage = StoreService.instance.get ('timeHeaderPage');
      if (currentPage != newCurrentPage) {
         var pageController = StoreService.instance.get ('timeHeaderController');
         // The conditional prevents scrolling semesters if the uploaded view is not active.
         // new current page might be null if suddenly there's no more pages due to untagging
         // or if there is no current month because there's no pivs
         if (pageController != '' && pageController.hasClients && newCurrentPage != null) {
            pageController.animateToPage (newCurrentPage, duration: Duration (milliseconds: 500), curve: Curves.easeInOut);
         }
      }

      if (updateYearUploaded) StoreService.instance.set ('yearUploaded', semesters[semesters.length - 1][0][0]);
   }

}
