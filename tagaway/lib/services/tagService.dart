import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/uploadService.dart';

class TagService {
  TagService._privateConstructor ();
  static final TagService instance = TagService._privateConstructor ();

  var localVisible = [];
  var uploadedVisible = [];
  // We use this to see whether queryTags has changed and based on that, query pivs again or use the last result.
  dynamic queryTags = '';

  getTags () async {
    var response = await ajax ('get', 'tags');
    if (response['code'] == 200) {
      StoreService.instance.set ('hometags', response['body']['hometags']);
      StoreService.instance.set ('tags', response['body']['tags']);
      var usertags = [];
      response['body']['tags'].forEach ((tag) {
        if (!RegExp ('^[a-z]::').hasMatch (tag)) usertags.add (tag);
      });
      StoreService.instance.set ('usertags', usertags);
      updateLastNTags (null, true);
    }
    // TODO: handle errors
    return response['code'];
  }

  editHometags (String tag, bool add) async {
    // Refresh hometag list first in case it was updated in another client
    await getTags ();
    tag = tag.trim ();
    var hometags = StoreService.instance.get ('hometags');
    if (hometags == '') hometags = [];
    if ((add && hometags.contains (tag)) || (!add && !hometags.contains (tag)))
      return;
    add ? hometags.add (tag) : hometags.remove (tag);
    var response = await ajax ('post', 'hometags', {'hometags': hometags});
    if (response['code'] == 200) {
      await getTags ();
    }
    // TODO: handle errors
    return response['code'];
  }

  tagPivById (String id, String tag, bool del) async {
    var response = await ajax ('post', 'tag', {'tag': tag, 'ids': [id], 'del': del, 'autoOrganize': true});
    if (response['code'] == 200) {
       var hometags = StoreService.instance.get ('hometags');
       if (! del && (hometags == '' || hometags.isEmpty)) await editHometags (tag, true);
       await queryPivs (StoreService.instance.get ('queryTags'), true);
       var total = StoreService.instance.get ('queryResult')['total'];

       if (total == 0 && StoreService.instance.get ('queryTags').length > 0) {
         StoreService.instance.set('swipedUploaded', false);
         StoreService.instance.set('currentlyTaggingUploaded', '');
         StoreService.instance.set ('queryTags', []);
         await queryPivs (StoreService.instance.get ('queryTags'));
       }
    }
    return response['code'];
  }

  updateLastNTags (var tag, [bool refreshExistingList = false]) {
    var lastNTags = StoreService.instance.get ('lastNTags');
    if (lastNTags == '') lastNTags = [];
    if (refreshExistingList) {
      var usertags = StoreService.instance.get ('usertags');
      // We iterate a copy of the list to avoid Flutter complaining about modifying a list while it's being iterated
      List.from (lastNTags).forEach ((tag) {
         if (! usertags.contains (tag)) lastNTags.remove (tag);
      });
      return StoreService.instance.set ('lastNTags', lastNTags);
    }

    var N = 3;
    if (lastNTags.contains (tag)) {
       lastNTags.remove (tag);
    }
    lastNTags.insert (0, tag);
    if (lastNTags.length > N) lastNTags = lastNTags.sublist (0, N);
    StoreService.instance.set ('lastNTags', lastNTags);
  }

  tagPiv (dynamic assetOrPiv, String tag, String type) async {
    String id = type == 'uploaded' ? assetOrPiv['id'] : assetOrPiv.id;
    dynamic pivId = type == 'uploaded' ? id : StoreService.instance.get ('pivMap:' + id);
    bool   del   = StoreService.instance.get ('tagMap:' + id) != '';
    StoreService.instance.set ('tagMap:' + id, del ? '' : true);
    StoreService.instance.set ('taggedPivCount' + (type == 'local' ? 'Local' : 'Uploaded'), StoreService.instance.get ('taggedPivCount' + (type == 'local' ? 'Local': 'Uploaded')) + (del ? -1 : 1));

    if (! del && type == 'local') {
       var currentlyTaggingPivs = StoreService.instance.get ('currentlyTaggingPivs');
       if (currentlyTaggingPivs == '') currentlyTaggingPivs = [];
       currentlyTaggingPivs.add (id);
       StoreService.instance.set ('currentlyTaggingPivs', currentlyTaggingPivs);
    }

    updateLastNTags (tag);

    if (pivId != '' && pivId != true) {
      var code = await tagPivById (pivId, tag, del);
      if (type == 'uploaded') return;

      // If piv still exists, we are done. Otherwise, we need to re-upload it.
      if (code == 200) return;
      if (code == 404) {
         StoreService.instance.remove ('pivMap:' + id);
         StoreService.instance.remove ('rpivMap:' + pivId);
      }
      // TODO: add error handling for non 200, non 404
    }

    // If we're untagging a piv that's not uploaded yet, we only need to unset `pivMap:ID`, which was temporarily set to `true` by the `queuePiv` function
    if (del) {
       if ([true, ''].contains (StoreService.instance.get ('pivMap:' + id))) StoreService.instance.remove ('pivMap:' + id);
       return;
    }
    UploadService.instance.queuePiv (assetOrPiv);
    var pendingTags = StoreService.instance.get ('pending:' + id);
    if (pendingTags == '') pendingTags = [];
    if (del) pendingTags.remove (tag);
    else     pendingTags.add    (tag);
    StoreService.instance.set ('pendingTags:' + id, pendingTags, 'disk');
   }

   getTaggedPivs (String tag, String type) async {
      var existing = [], New = [];
      StoreService.instance.store.keys.toList ().forEach ((k) {
         if (RegExp ('^tagMap:').hasMatch (k)) existing.add (k.split (':') [1]);
         if (type == 'local') {
            if (RegExp ('^pendingTags:').hasMatch (k)) {
               if (StoreService.instance.get (k).contains (tag)) New.add (k.split (':') [1]);
            }
         }
      });
      var response = await ajax ('post', 'query', {
         'tags':    [tag],
         'sort':    'newest',
         'from':    1,
         'to':      100000,
         'idsOnly': true
      });
      var queryIds;
      if (type == 'uploaded') queryIds = StoreService.instance.get ('queryResult') ['pivs'].map ((v) => v ['id']);
      response ['body'].forEach ((v) {
         if (type == 'uploaded') {
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
        StoreService.instance.set ('tagMap:' + id, '');
      });

      StoreService.instance.set ('taggedPivCount' + (type == 'local' ? 'Local' : 'Uploaded'), New.length);
   }

   getUploadedTimeHeader () {
      var localCount  = {};
      var remoteCount = {};
      var lastPivInMonth = {};
      var output      = [];
      var min, max;
      var timeHeader = StoreService.instance.get ('queryResult') ['timeHeader'];
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
           if (timeHeader [dateKey] == null)       output.add ([year, shortMonthNames [month - 1], 'white', false]);
           // TODO: add last piv in month or figure out alternative way to jump
           else if (timeHeader [dateKey] == false) output.add ([year, shortMonthNames [month - 1], 'gray', false]);
           else                                    output.add ([year, shortMonthNames [month - 1], 'green', false]);
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
      // The line below is a hack. A redraw we don't understand well yet is sometimes recalculating the uploaded time header, causing the selected months to be erased. By recomputing visibility, we overcome the problem.
      toggleTimeHeaderVisibility ('update', null, false);
      StoreService.instance.set ('yearUploaded', semesters[semesters.length - 1][0][0]);
   }

   queryPivs (dynamic tags, [refresh = false]) async {
      tags.sort ();
      if (refresh == false && queryTags != '') {
        // If query tags have not changed and we're not getting the `refresh` parameters, do not query again since we already have that result.
        // We need to check if we have data loaded; we might not, if we just logged in.
        if (listEquals (tags, queryTags) && StoreService.instance.get ('queryResult') != '') return;
      }
      queryTags = List.from (tags);
      var firstLoadSize = 200;
      var response = await ajax ('post', 'query', {
         'tags': tags,
         'sort': 'newest',
         'from': 1,
         'to': firstLoadSize,
         'timeHeader': true
      });

      // TODO: NOTIFY ERRORS
      if (response ['code'] != 200) return;

      var queryResult = response ['body'];
      if (tags.length == 0) StoreService.instance.set ('countUploaded', queryResult ['total']);

      // If query changed in the meantime, don't do anything else.
      if (! listEquals (queryTags, tags)) return;

      if (queryResult ['total'] > firstLoadSize) {
        // We create n empty entries as placeholders for those pivs we haven't loaded yet
        queryResult ['pivs'] = [...queryResult ['pivs'], ...List.generate (queryResult ['total'] - firstLoadSize, (v) => {})];
      }

      StoreService.instance.set ('queryResult', queryResult);
      getUploadedTimeHeader ();

      var orgIds;
      if (tags.contains ('o::')) orgIds = queryResult ['pivs'].map ((v) => v['id']);
      else {
         response = await ajax ('post', 'query', {
            'tags': [...tags]..addAll (['o::']),
            'sort': 'newest',
            'from': 1,
            'to': firstLoadSize,
            'idsOnly': true
         });
         if (! listEquals (queryTags, tags)) return debug;

         // TODO: NOTIFY ERRORS
         if (response ['code'] != 200) return;
         orgIds = response['body'];
      }

      // Iterate only returned pivs, since only those will be shown initially
      queryResult ['pivs'].forEach ((piv) {
         // Ignore the empty entries created by our array with empty objects as placeholders for what's not loaded yet
         if (piv ['id'] == null) return;
         var wasOrganized = StoreService.instance.get ('orgMap:' + piv ['id']) != '';
         var isOrganized = orgIds.contains (piv ['id']);
         if (! wasOrganized && isOrganized) StoreService.instance.set ('orgMap:' + piv ['id'], true);
         if (wasOrganized && ! isOrganized) StoreService.instance.remove ('orgMap:' + piv ['id']);
      });

      if (queryResult ['total'] > firstLoadSize) {

         response = await ajax ('post', 'query', {
            'tags': tags,
            'sort': 'newest',
            'from': 1,
            // Load all pivs in the query, no time header needed
            'to': 100000
         });
         if (! listEquals (queryTags, tags)) return debug;

         // TODO: NOTIFY ERRORS
         if (response ['code'] != 200) return;

         queryResult = response ['body'];

         StoreService.instance.set ('queryResult', queryResult, '', 'mute');

         if (tags.contains ('o::')) orgIds = queryResult ['pivs'].map ((v) => v['id']);
         else {
            response = await ajax ('post', 'query', {
               'tags': [...tags]..addAll (['o::']),
               'sort': 'newest',
               'from': 1,
               'to': 100000,
               'idsOnly': true
            });
            if (! listEquals (queryTags, tags)) return debug;

            // TODO: NOTIFY ERRORS
            if (response ['code'] != 200) return;
            orgIds = response['body'];

            // Iterate all pivs now, since only those will be shown initially
            queryResult ['pivs'].forEach ((piv) {
               var wasOrganized = StoreService.instance.get ('orgMap:' + piv ['id']) != '';
               var isOrganized = orgIds.contains (piv ['id']);
               if (! wasOrganized && isOrganized) StoreService.instance.set ('orgMap:' + piv ['id'], true);
               if (wasOrganized && ! isOrganized) StoreService.instance.remove ('orgMap:' + piv ['id']);
            });
         }
      }
      return {'code': response ['code'], 'body': response ['body']};
  }

  toggleQueryTag (String tag) {
    var queryTags = StoreService.instance.get ('queryTags');
    if (queryTags.contains (tag)) queryTags.remove (tag);
    else                          queryTags.add (tag);
    StoreService.instance.set ('queryTags', queryTags);
  }

  deleteUploadedPivs (dynamic ids) async {
    // TODO: Why do we need to pass 'csrf' here? We don't do it on any other ajax calls! And yet, if we don't, the ajax call fails with a type error. Madness.
    var response = await ajax ('post', 'delete', {'ids': ids, 'csrf': 'foo'});
    ids.forEach ((id) {
       var localPivId = StoreService.instance.get ('rpivMap:' + id);
       if (localPivId != '') {
         StoreService.instance.remove ('pivMap:' + localPivId);
         StoreService.instance.remove ('rpivMap:' + id);
       }
    });
    StoreService.instance.remove ('currentlyDeletingPivsUploaded');
    if (response['code'] == 200) {
       await queryPivs (StoreService.instance.get ('queryTags'), true);
       var total = StoreService.instance.get ('queryResult')['total'];
       if (total == 0 && StoreService.instance.get ('queryTags').length > 0) {
         StoreService.instance.set ('queryTags', []);
         await queryPivs (StoreService.instance.get ('queryTags'));
       }
    }
    return response['code'];
  }

  toggleTimeHeaderVisibility (String view, dynamic piv, bool visible) async {

     filter (dynamic list, String id, int date, bool visible) {
        var existing;
        list.forEach ((v) {
           if (v['id'] == id) existing = v;
        });
        if (visible && existing == null)   list.add ({'id': id, 'date': date});
        if (! visible && existing != null) list.remove (existing);
     }

     getDates (dynamic list) {
       var dates = [];
       list.forEach ((v) {
         var date    = new DateTime.fromMillisecondsSinceEpoch (v['date']);
         var dateKey = date.year.toString () + ':' + date.month.toString ();
         if (! dates.contains (dateKey)) dates.add (dateKey);
        });
        dates.sort ();

        return dates;
     }

     var activePages = [];

     updateHeader (dynamic newDates) {
        var header = StoreService.instance.get ('timeHeader');
        header.asMap ().forEach ((k, semester) {
          semester.forEach ((month) {
             var monthKey = month [0].toString () + ':' + (shortMonthNames.indexOf (month [1]) + 1).toString ();
             month [3] = newDates.contains (monthKey);
             if (newDates.contains (monthKey)) {
               // Pages are inverted, that's why we use this index and not `k` itself.
               var page = header.length - k - 1;
               if (! activePages.contains (page)) activePages.add (page);
             }

          });
        });
        StoreService.instance.set ('timeHeader', header);
     }

     activePages.sort ();

     if (view == 'uploaded') {
        var oldDates = getDates (uploadedVisible);
        // In the case of uploaded, `piv` is an index.
        piv = StoreService.instance.get ('queryResult')['pivs'] [piv];
        filter (uploadedVisible, piv['id'], piv['date'], visible);
        var newDates = getDates (uploadedVisible);
        if (ListEquality ().equals (oldDates, newDates)) return;
        updateHeader (newDates);
        var currentPage = StoreService.instance.get ('timeHeaderPage');
        if (activePages.length > 0 && ! activePages.contains (currentPage)) {
           var pageController = StoreService.instance.get ('timeHeaderController');
           // Prevent scrolling semesters if the uploaded view is not active.
           if (pageController.hasClients) {
              pageController.animateToPage (activePages [activePages.length - 1], duration: Duration (milliseconds: 500), curve: Curves.easeInOut);
           }
        }
     }

     // This enables the hack of recalculating month visibility when computing the uploaded time header.
     if (view == 'update') {
       var newDates = getDates (uploadedVisible);
       updateHeader (newDates);
     }

  }

   renameTag (String from, String to) async {
      await ajax ('post', 'rename', {'from': from, 'to': to});
      await getTags ();
      var queryTags = StoreService.instance.get ('queryTags');
      if (queryTags == '') queryTags = [];
      if (queryTags.contains (from)) {
         queryTags.remove (from);
         queryTags.add (to);
      }
      StoreService.instance.set ('queryTags', queryTags);
      await queryPivs (queryTags, true);
      // TODO: handle non-200 error
   }

   deleteTag (String tag) async {
      await ajax ('post', 'deleteTag', {'tag': tag});
      await getTags ();
      var queryTags = StoreService.instance.get ('queryTags');
      if (queryTags == '') queryTags = [];
      if (queryTags.contains (tag)) queryTags.remove (tag);
      StoreService.instance.set ('queryTags', queryTags);
      await queryPivs (queryTags, true);
      await queryPivs (StoreService.instance.get ('queryTags'), true);
      // TODO: handle non-200 error
   }

   toggleDeletion (String id, String view) {
      var key = 'currentlyDeletingPivs' + (view == 'local' ? 'Local' : 'Uploaded');
      var currentlyDeletingPivs = StoreService.instance.get (key);
      if (currentlyDeletingPivs == '') currentlyDeletingPivs = [];
      if (! currentlyDeletingPivs.contains (id)) currentlyDeletingPivs.add (id);
      else currentlyDeletingPivs.remove (id);
      StoreService.instance.set (key, currentlyDeletingPivs);
   }

}
