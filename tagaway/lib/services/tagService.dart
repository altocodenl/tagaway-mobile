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
    if (response['code'] == 200) await getTags();
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
    StoreService.instance.set ('tagMap:' + piv.id, del ? '' : true);
    StoreService.instance.set ('taggedPivCount', StoreService.instance.get ('taggedPivCount') + (del ? -1 : 1));

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

   getTimeHeader (int year, int month) async {
      var months = month == 1 ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'] : ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      var minDate = DateTime.utc (year,                         month,              1).millisecondsSinceEpoch;
      var maxDate = DateTime.utc (month == 7 ? year + 1 : year, month == 1 ? 7 : 1, 1).millisecondsSinceEpoch;
      var response = await ajax('post', 'query', {
         'tags': [],
         'sort': 'newest',
         'from': 1,
         'to': 10000,
         'idsOnly': true,
      });
      if (response ['code'] == 200) {
         var allIds = response ['body'];
         var localCount  = [0, 0, 0, 0, 0, 0];
         var remoteCount = [0, 0, 0, 0, 0, 0];
         StoreService.instance.prefs.getKeys ().toList ().forEach ((k) {
           if (!RegExp('^pivMap:').hasMatch (k)) return;
           var id = k.replaceAll ('pivMap:', '');
           var date = StoreService.instance.get ('pivDateMap:' + id);
           // TODO: uncomment
           // if (date < minDate || date > maxDate) return;
           debug (['MATCHING', id]);
           // TODO: add to right element of local count
           // CHECK FOR EXISTENCE OF PIVMAP. If it exists, add it to remote count.
         });
      }
      return {'year': 2022, 'months': months};
   }


  getPivs () async {
    var response = await ajax('post', 'query', {
      'tags': [],
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
  }
}
