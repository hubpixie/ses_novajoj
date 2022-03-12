import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';

class NovaDetailItem {
  static const _kHtmlTemplateString = '''
<html>
    <head>
        <META HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8"> 
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>{{title}}</title>
        <style type='text/css'>
          img { 
              max-width: 100%; 
              height: auto; 
          }
          body 
          {
            min-height:100%; height:100%; 
            overflow:scroll; 
            display:block;
            -webkit-transition: all .3s;
            -moz-transition: all .3s;
            -ms-transition: all .3s;
            -o-transition: all .3s;
          }       
        </style>
    </head>
    <body>
		<div style="margin:14px;"><p style="background-color:#ceebfd;">{{title}}</p></div>
		<hr style="border-top: 1px solid #bbb;">  
		<p style="text-align:center;">
<!-- itemSource -->
			{{itemSource}}  Latest Upated:{{createAt}} 
		</p>      
		<hr style="border-top: 1px solid #bbb;">  
        <div id='shownewsc' style="margin:15px;">
<!-- Author -->
<!-- Body Text -->
{{author}}　{{body}}
      <br/>		
			<div>
				<div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div> <script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
			</div>
			</div>    
    </body>
</html>    ''';

  NovaItemInfo itemInfo;
  String bodyString;

  NovaDetailItem({
    required this.itemInfo,
    required this.bodyString,
  });

  String toHtmlString() {
    String html = _kHtmlTemplateString.replaceAll(r'{{title}}', itemInfo.title);
    html = html.replaceAll(r'{{itemSource}}', itemInfo.source);
    html = html.replaceAll(
        r'{{createAt}}',
        DateUtil().getDateString(
            date: itemInfo.createAt, format: 'yyyy-MM-dd H:mm:ss'));
    html = html.replaceAll(r'{{author}}', itemInfo.author);
    html = html.replaceAll(r'{{body}}', bodyString);
    return html;
  }
}
