import 'package:wechat/entity/index.dart';
import 'package:wechat/utils/index.dart';

///朋友圈API
class TimelineApi {
  ///翻页列表
  static Future<List<TimelineModel>> pageList() async {
    var res = await WxHttpUtil().get('/timeline/news');
    List<TimelineModel> items = [];
    for (var item in res.data) {
      items.add(TimelineModel.fromJson(item));
    }
    return items;
  }
}
