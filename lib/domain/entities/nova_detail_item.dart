import 'nova_comment.dart';

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
        </style>
    </head>
    <body>
		<div style="margin:14px;"><p style="background-color:#ceebfd;">{{title}}</p></div>
		<hr style="border-top: 1px solid #bbb;">  
		<p style="text-align:center;">
<!-- itemSource -->
			{{itemSource}} 
		</p>      
		<hr style="border-top: 1px solid #bbb;">  
        <div id='shownewsc' style="margin:15px;">
<!-- Author -->
<!-- Body Text -->
{{author}}　{{body}}		
			<div>
				<div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div> <script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
			</div>
			</div>    
    </body>
</html>    ''';

  int id;
  String urlString;
  String title;
  String itemSource;
  String author;
  String bodyString;
  String loadCommentAt;
  List<NovaComment>? comments;
  NovaDetailItem(
      {required this.id,
      required this.urlString,
      required this.title,
      required this.itemSource,
      required this.author,
      required this.bodyString,
      required this.loadCommentAt,
      this.comments});

  String toHtmlString() {
    String html = _kHtmlTemplateString.replaceAll(r'{{title}}', title);
    html = html.replaceAll(r'{{itemSource}}', itemSource);
    html = html.replaceAll(r'{{author}}', author);
    html = html.replaceAll(r'{{body}}', bodyString);
    return html;
  }
}
