import 'dart:async';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/storeService.dart';

class TagService {
   TagService._privateConstructor ();
   static final TagService instance = TagService._privateConstructor ();

   Future <dynamic> getTags () async {
      var response = await ajax ('get', 'tags');
      if (response ['code'] == 200) {
         StoreService.instance.set ('hometags', response ['body'] ['hometags']);
         StoreService.instance.set ('tags',     response ['body'] ['tags']);
      }
      return response ['code'];
   }

   Future <dynamic> editHometags (String tag, bool add) async {
      // Refresh hometag list first in case it was updated in another client
      await getTags ();
      var hometags = await StoreService.instance.get ('hometags');
      if (hometags == '') hometags = [];
      if ((add && hometags.contains (tag)) || (! add && ! hometags.contains (tag))) return;
      add ? hometags.add (tag) : hometags.remove (tag);
      var response = await ajax ('post', 'hometags', {'hometags': hometags});
      if (response ['code'] == 200) await getTags ();
      return response ['code'];
   }
}
