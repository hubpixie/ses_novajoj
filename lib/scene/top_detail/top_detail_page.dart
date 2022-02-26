import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/top_detail/top_detail_presenter.dart';
import 'package:ses_novajoj/utilities/firebase_util.dart';
import 'package:ses_novajoj/scene/utilities/page_util/page_parameter.dart';
import 'package:ses_novajoj/l10n/l10n.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ses_novajoj/domain/entities/nova_detail_item.dart';

class TopDetailPage extends StatefulWidget {
  final TopDetailPresenter presenter;
  const TopDetailPage({Key? key, required this.presenter}) : super(key: key);

  @override
  _TopDetailPageState createState() => _TopDetailPageState();
}

class _TopDetailPageState extends State<TopDetailPage> {
  late final Map? _parameters =
      ModalRoute.of(context)?.settings.arguments as Map;
  late final String _url = _parameters?[TopDetailParamKeys.url] ?? '';

  @override
  void initState() {
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.topDetail);
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String bodyStr = '''
从当地时间2022年1月2日起，因天然气涨价，哈萨克斯坦西部城市扎瑙津爆发大规模抗议，抗议活动在数天内迅速升级，向全国范围蔓延，席卷了最大城市阿拉木图，以及首都努尔苏丹。<br />
<br />
哈萨克斯坦总统托卡耶夫于当地时间1月5日宣布，该国进入紧急状态，直至1月19日结束。<br />
<br />
据俄罗斯塔斯社1月9日消息，哈萨克斯坦内务部新闻处当天表示，哈萨克斯坦执法机构已在该国多个地区拘留了5100多名参与骚乱的人，其中被捕人员中包括许多外国人。<br />
<br />
同天，俄罗斯卫星通讯社援引哈萨克斯坦Khabar 24电视台报道称，一名在阿拉木图被拘捕的男子承认自己是从吉尔吉斯斯坦而来，此前有人给了他200多美元，要求其参加邻国哈萨克斯坦的抗议活动。<br />
<br />
<img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202201/09/16/a57ff30dfdtype_png_size_772_128_end.jpg"/><br />
<br />
俄罗斯卫星通讯社报道截图<br />
<br />
“一些陌生人打电话给我，说只要参加抗议集会就能得到9万哈萨克斯坦坚戈（约合206.8美元）。因为我在吉尔吉斯斯坦没有工作，所以我就同意了。”这名被拘捕者告诉哈萨克斯坦Khabar 24电视台。<br />
<br />
被拘捕男子表示，一些身份不明的人给他买了一张机票，并为其在哈萨克斯坦逗留支付了住所开支。这名吉尔吉斯斯坦人还透露，大约有10名来自乌兹别克斯坦和塔吉克斯坦的人与自己居住在一起。<br />
<br />
<img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202201/09/10/f5afcb6759type_png_size_511_67_end.jpg"/><br />
<br />
俄罗斯卫星通讯社在社交媒体“Telegram”所发布的被拘捕男子视频截图<br />
<br />
1月5日，就在骚乱发生之初，哈萨克斯坦总统托卡耶夫就表示，在该国发生的动乱背后有一群“有经济动机”的策划者，他们在精心策划着一个“抗议活动”。他誓言，要对任何罪犯采取果断行动。<br />
<br />
1月6日，俄罗斯外交部发言人扎哈罗娃则表示，近期在哈萨克斯坦发生的动乱事件有“外国唆使”成分，有境外势力“企图用武装和训练有素之人强行破坏别国安全和完整性”。<br />
<br />
此后，独立国家联合体（独联体）执行秘书谢尔盖·列别捷夫（Sergei Lebedev）的一番发言，也呼应了扎哈罗娃的说法。他认为，哈萨克斯坦的抗议活动是事先计划好的，目的是破坏该国的稳定局势，有活动组织者受境外势力支持。<br />
<br />
列别捷夫说：“很明显，这些破坏分子和暴徒事先准备了大规模集会，以破坏国家稳定，他们得到了外国的支持。”他还表示：“这些‘颜色革命’和独联体骚乱的煽动者、引导者和赞助者，如今竟还‘自豪地’宣称，自己在哈萨克斯坦各地的犯罪行为中扮演了‘领导角色’。”<br />
<br />
<img onload='javascript:if(this.width>600) this.width=600'  src="https://web.popo8.com/202201/09/1/0b1d649643type_jpeg_size_640_150_end.jpg"/><br />
<br />
当地时间2022年1月6日，哈萨克斯坦阿拉木图爆发大规模抗议活动，现场一片狼藉。图为阿拉木图市长办公室的大楼。图自澎湃影像<br />
<br />
据观察者网此前消息，当地时间1月2日，因天然气涨价，哈萨克斯坦西部城市扎瑙津爆发大规模抗议，抗议活动在数天内迅速升级，向全国范围蔓延，席卷了最大城市阿拉木图，以及首都努尔苏丹。<br />
<br />
据当地媒体报道，阿拉木图的抗议者冲进机场，强行进入政府大楼，并放火烧毁该市的主要行政办公室，造成数十人死亡，另有数百人受伤。全国范围内的互联网中断，其他主要城市也遭到破坏。目前哈萨克斯坦已宣布在全国范围内实行紧急状态，实行宵禁和行动限制，直至1月19日。<br />
<br />
当地时间1月7日，哈萨克斯坦总统托卡耶夫宣布，已批准执法人员使用致命武力平息骚乱，包括“在没有警告的情况下开火”。<br />
<br />
1月7日，路透社、俄罗斯卫星通讯社援引哈萨克斯坦总统新闻处的一份声明称，托卡耶夫当天宣布，“（哈萨克斯坦）所有地区已经基本恢复了宪法秩序（constitutional order）”。<br />
<br />
与此同时，由于国内局势出现动荡，哈萨克斯坦总统托卡耶夫已请求独联体集体安全条约组织（CSTO，简称集安组织）成员国帮助哈萨克斯坦应对“恐怖主义威胁”，集安组织各成员国也已派遣维和部队，抵达哈萨克斯坦执行任务。
''';
    NovaDetailItem? detailItem;
    // NovaDetailItem detailItem = NovaDetailItem(
    //     id: 0,
    //     urlString: 'http://urlString/',
    //     title: '被捕外国男子:收200多美元参加哈萨克斯坦抗议',
    //     itemSource: '新闻来源: 观察者网 于2022-01-09 5:25:48',
    //     author: '【文/观察者网 熊超然】',
    //     bodyString: bodyStr,
    //     loadCommentAt: 'loadCommentAt');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B80F3),
      ),
      body: Column(
        children: [
          // _buildAdArea(context),
          // _buildTitleArea(context, title: '新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻新闻'),
          // _buildSummaryArea(context),
          // _buildBodyArea(context),
          // _buildCommentArea(context),
          // _buildRelationArea(context),
          _buildContentArea(context, detailItem: detailItem)
        ],
      ),
    );
  }

/*
  Widget _buildTitleArea(BuildContext context, {String? title}) {
    return Column(children: [
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        height: 70,
        color: Colors.blue[50],
        child: Text(
          title ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
      const SizedBox(height: 15),
      const Divider(height: 1.0, thickness: 1.0),
    ]);
  }

  Widget _buildSummaryArea(BuildContext context) {
    return Flexible(
      child: Wrap(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "${L10n.of(context)?.topDetailNewsSoourceLabel ?? ''}德国之声      于 2022-01-03 5:11:12",
                softWrap: true,
              ),
            ),
            const SizedBox(height: 5),
            const Divider(height: 1.0, thickness: 1.0),
          ],
        )
      ]),
    );
  }
*/
  Widget _buildContentArea(BuildContext context, {NovaDetailItem? detailItem}) {
    return Flexible(
      child: Wrap(
        children: <Widget>[
          Container(
              alignment: Alignment.topLeft,
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: WebView(
                initialUrl: 'about:blank',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController controller) {
                  //_controller = controller;
                  controller.loadUrl(Uri.dataFromString(
                          detailItem?.toHtmlString() ?? '',
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString());
                },
                gestureNavigationEnabled: true,
              )),
          const SizedBox(height: 5),
          const Divider(height: 1.0, thickness: 1.0),
        ],
      ),
    );
  }

/*
  Widget _buildBodyArea(BuildContext context) {
    String text = """
    """;
    return Flexible(
      child: Wrap(
        children: <Widget>[
          Container(
              alignment: Alignment.topLeft,
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: WebView(
                initialUrl:
                    'https://www.6parknews.com/newspark/view.php?app=news&act=view&nid=526259',
                javascriptMode: JavascriptMode.unrestricted,
                // onWebViewCreated: (WebViewController controller) {
                //   _controller = controller;
                // },
                gestureNavigationEnabled: true,
              )),
          const SizedBox(height: 5),
          const Divider(height: 1.0, thickness: 1.0),
        ],
      ),
    );
  }

  Widget _buildCommentArea(BuildContext context) {
    return const SizedBox(height: 40);
  }

  Widget _buildRelationArea(BuildContext context) {
    return const SizedBox(height: 40);
  }
  */
}
