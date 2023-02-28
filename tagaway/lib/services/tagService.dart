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
    await getTags();
    var hometags = await StoreService.instance.get('hometags');
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
