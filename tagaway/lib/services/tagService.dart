import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/uploadService.dart';
import 'package:tagaway/ui_elements/constants.dart';

class TagService {
  TagService._privateConstructor();
  static final TagService instance = TagService._privateConstructor();

  getTags() async {
    var response = await ajax('get', 'tags');
    if (response['code'] == 200) {
      StoreService.instance.set('hometags', response['body']['hometags'], true);
      StoreService.instance.set('tags', response['body']['tags'], true);
      var usertags = [];
      response['body']['tags'].forEach((tag) {
        if (!RegExp('^[a-z]::').hasMatch(tag)) usertags.add(tag);
      });
      StoreService.instance.set('usertags', usertags, true);
    }
    // TODO: handle errors
    return response['code'];
  }

  editHometags(String tag, bool add) async {
    // Refresh hometag list first in case it was updated in another client
    await getTags ();
    var hometags = StoreService.instance.get('hometags');
    if (hometags == '') hometags = [];
    if ((add && hometags.contains(tag)) || (!add && !hometags.contains(tag)))
      return;
    add ? hometags.add(tag) : hometags.remove(tag);
    var response = await ajax('post', 'hometags', {'hometags': hometags});
    if (response['code'] == 200) {
      await getTags();
    }
    // TODO: handle errors
    return response['code'];
  }

  tagPivById(String id, String tag, bool del) async {
    var response = await ajax('post', 'tag', {
      'tag': tag,
      'ids': [id],
      'del': del
    });
    return response['code'];
  }

  togglePiv (dynamic piv, String tag) async {
    String pivId = StoreService.instance.get ('pivMap:' + piv.id);
    bool   del   = StoreService.instance.get ('tagMap:' + piv.id) != '';
    StoreService.instance.set ('tagMap:' + piv.id, del ? '' : true, true);
    StoreService.instance.set ('taggedPivCount', StoreService.instance.get ('taggedPivCount') + (del ? -1 : 1), true);

    // If there are no hometags yet, add one if this is a tagging operation.
    var hometags = StoreService.instance.get ('hometags');
    if (! del && (hometags == '' || hometags.isEmpty)) await editHometags (tag, true);

    // If we have an entry for the piv:
    if (pivId != '') {
      var code = await tagPivById(pivId, tag, del);
      // If piv exists, we are done. Otherwise, we need to upload it.
      if (code == 200) return;
      if (code == 404) {
         StoreService.instance.remove ('pivMap:' + piv.id);
         StoreService.instance.remove ('rpivMap:' + pivId);
      }
      // TODO: add error handling for non 200, non 404
    }
     UploadService.instance.queuePiv (piv);
     var pendingTags = StoreService.instance.get ('pending:' + piv.id);
     if (pendingTags == '') pendingTags = [];
     if (del) pendingTags.remove (tag);
     else     pendingTags.add    (tag);
     StoreService.instance.set ('pendingTags:' + piv.id, pendingTags);
    // TODO: add error handling
  }

  getTaggedPivs (String tag) async {
    var response = await ajax('post', 'query', {
      'tags': [tag],
      'sort': 'newest',
      'from': 1,
      'to': 10000,
      'idsOnly': true
    });
    await StoreService.instance.remove ('tagMap:*', true);
    int count = 0;
    response ['body'].forEach ((v) {
      var id = StoreService.instance.get ('rpivMap:' + v);
      if (id == '') return;
      StoreService.instance.set ('tagMap:' + id, true, true);
      count += 1;
    });
    StoreService.instance.set ('taggedPivCount', count);
  }

   getLocalTimeHeader () {
      var monthNames  = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var localCount  = {};
      var remoteCount = {};
      var lastPivInMonth = {};
      var output      = [];
      var min = now (), max = 0;

      StoreService.instance.store.keys.toList ().forEach ((k) {
        // pivDate entries exist for *all* local pivs, whereas pivMap entries exist only for local pivs that were already uploaded
        if (! RegExp ('^pivDate:').hasMatch (k)) return;

        var id   = k.replaceAll ('pivDate:', '');
        var date = StoreService.instance.get (k);
        if (date < min) min = date;
        if (date > max) max = date;

        var Date        = new DateTime.fromMillisecondsSinceEpoch (date);
        var dateKey = Date.year.toString () + ':' + Date.month.toString ();
        if (localCount  [dateKey] == null) localCount  [dateKey] = 0;
        if (remoteCount [dateKey] == null) remoteCount [dateKey] = 0;
        if (lastPivInMonth [dateKey] == null) lastPivInMonth [dateKey] = {};

        localCount [dateKey] += 1;
        if (StoreService.instance.get ('pivMap:' + id) != '') remoteCount [dateKey] += 1;
        if (lastPivInMonth [dateKey] ['id'] == null || lastPivInMonth [dateKey] ['date'] < date) {
           lastPivInMonth [dateKey] = {'id': id, 'date': date};
        }
      });

      var fromYear  = DateTime.fromMillisecondsSinceEpoch (min).year;
      var toYear    = DateTime.fromMillisecondsSinceEpoch (max).year;
      var fromMonth = DateTime.fromMillisecondsSinceEpoch (min).month;
      var toMonth   = DateTime.fromMillisecondsSinceEpoch (max).month;
      fromMonth = fromMonth < 7 ? 1  : 7;
      toMonth   = toMonth   > 6 ? 12 : 6;

      for (var year = fromYear; year <= toYear; year++) {
         for (var month = (year == fromYear ? fromMonth : 1); month <= (year == toYear ? toMonth : 12); month++) {
            var dateKey = year.toString () + ':' + month.toString ();
            if (localCount  [dateKey] == null) localCount  [dateKey] = 0;
            if (remoteCount [dateKey] == null) remoteCount [dateKey] = 0;

            if (localCount [dateKey] == 0)                         output.add ([year, monthNames [month - 1], 'white']);
            else if (localCount [dateKey] > remoteCount [dateKey]) output.add ([year, monthNames [month - 1], 'gray', lastPivInMonth [dateKey] ['id']]);
            else                                                   output.add ([year, monthNames [month - 1], 'green', lastPivInMonth [dateKey] ['id']]);
         }
      };

      var semesters = [[]];
      output.forEach ((month) {
         var lastSemester = semesters [semesters.length - 1];
         if (lastSemester.length < 6) lastSemester.add (month);
         else semesters.add ([month]);
      });

      StoreService.instance.set ('timeHeader', semesters, true);
   }

   queryPivs (dynamic tags) async {
    var response = await ajax('post', 'query', {
      'tags': tags,
      'sort': 'newest',
      'from': 1,
      'to': 10000,
    });
    if (response ['code'] == 200) {
       var pivIds = [], videoIds = [];
       response ['body'] ['pivs'].forEach ((v) {
          pivIds.add (v ['id']);
          if (v ['vid'] != null) videoIds.add (v ['id']);
       });
       return {'pivIds': pivIds, 'videoIds': videoIds};
    }
    else return response ['code'];
  }
}
