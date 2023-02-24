import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/uploadService.dart';
import 'package:tagaway/ui_elements/constants.dart';

class TagService {
  TagService._privateConstructor();
  static final TagService instance = TagService._privateConstructor();

  getTags() async {
    var response = await ajax('get', 'tags');
    if (response['code'] == 200) {
      StoreService.instance.set('hometags', response['body']['hometags']);
      StoreService.instance.set('tags', response['body']['tags']);
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

  tagPivById(String id, String tag) async {
    var response = await ajax('post', 'tag', {
      'tag': tag,
      'ids': [id]
    });
    return response['code'];
  }

  tagPiv(dynamic piv, String tag) async {
    String pivId = StoreService.instance.get('pivMap:' + piv.id);
    if (pivId != '') {
      var code = await tagPivById(pivId, tag);
      // If piv doesn't exist, reupload and queue tag
      if (code == 404) return UploadService.instance.queuePiv(piv);
    }
    // If piv on map is deleted, reupload it.
  }

  getPivs() async {
    var response = await ajax('post', 'query', {
      'tags': [],
      'sort': 'newest',
      'from': 1,
      'to': 10000,
    });
    var pivIds = [], videoIds = [];
    response ['body'] ['pivs'].forEach ((v) {
       pivIds.add (v ['id']);
       if (v ['vid'] != null) videoIds.add (v ['id']);
    });
    return {'pivIds': pivIds, 'videoIds': videoIds};
  }
}
