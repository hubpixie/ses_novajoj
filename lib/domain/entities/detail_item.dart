import 'package:ses_novajoj/foundation/data/user_types.dart';
import 'package:ses_novajoj/foundation/data/date_util.dart';

class DetailItem {
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
        <script>
          function double_tap_listen(elm, normal_func_param, double_func_param) {
            var timeout;
            var lastTap = 0;
            function double_touch_proc(e) {
                var currentTime = new Date().getTime();
                var tapDiff = currentTime - lastTap;

                e.preventDefault();
                clearTimeout(timeout);
                if (tapDiff < 600 && tapDiff >= 100) {
                    //Double Tap/Click
                    console.log('double tap!');
                    double_func_param(elm);
                    timeout = setTimeout(function () {
                        //Single Tap/Click code here
                        console.log('single tap!');
                        clearTimeout(timeout);
                    }, 100);
                } else {
                    //Single Tap/Click
                    timeout = setTimeout(function() {
                        //Single Tap/Click code here
                        console.log('single tap!');
                        clearTimeout(timeout);
                    }, 600);
                }
                lastTap = currentTime;
              }

            elm.addEventListener('touchend', function(e) {
                double_touch_proc(e);
            });
            elm.addEventListener('click', function(e) {
                double_touch_proc(e);
            });
          }

          function normal_tap_func(elm) {
          }
          function double_tap_func(elm) {
              port.postMessage(JSON.stringify({node: 'IMG', src: elm.src}));
          }          

          function startLoadImages() {
            // Run your code here
          var imgs = document.querySelectorAll("img");
          imgs.forEach(function(elm) {
              elm.addEventListener('load', function(evt) {
                  // current image is loaded.
                  double_tap_listen(elm, normal_tap_func, double_tap_func);
              });
              // load a image after a while.
              setTimeout(function() {
                elm.src = elm.getAttribute('data-src');
              }, 100);
            });
          }
          // DOMContentLoaded, load
          window.addEventListener('DOMContentLoaded', function () {
              startLoadImages()
          });
        </script>        
      </head>
    <body>
    <div style="margin:14px;"><p style="background-color:#ceebfd;">{{title}}</p></div>
    <hr style="border-top: 1px solid #bbb;">  
    <div style="text-align:center;">
<!-- itemSource -->
      {{itemSource}}&nbsp;&nbsp;Upated:{{createAt}}&nbsp;&nbsp;<font size='2px'>{{reads}}</font>
    </div>      
    <hr style="border-top: 1px solid #bbb;">  
        <div id='shownewsc' style="margin:15px;">
<!-- Body Text -->
      {{body}}
<!-- Author -->
        <div style="text-align:right;">(&nbsp;{{author}}&nbsp;)</div>
      <div>
        <div class="OUTBRAIN" data-src="DROP_PERMALINK_HERE" data-widget-id="AR_1"></div> <script type="text/javascript" async="async" src="//widgets.outbrain.com/outbrain.js"></script>
      </div>
      </div>    
      <script>
          // variable that will represents the port used to communicate with the Dart side
          var port;
          // listen for messages
          window.addEventListener('message', function (event) {
              if (event.data == 'capturePort') {
                  // capture port2 coming from the Dart side
                  if (event.ports[0] != null) {
                      // the port is ready for communication,
                      // so you can use port.postMessage(message); wherever you want
                      port = event.ports[0];
                      // To listen to messages coming from the Dart side, set the onmessage event listener
                      port.onmessage = function (event) {
                          // event.data contains the message data coming from the Dart side 
                          console.log(event.data);
                      };
                  }
              }
          }, false);
      </script>
    </body>
</html>
''';

  NovaItemInfo itemInfo;
  String bodyString;

  DetailItem({
    required this.itemInfo,
    required this.bodyString,
  });

  String toHtmlString() {
    if (bodyString.contains('</html>')) {
      return bodyString;
    }
    String html = _kHtmlTemplateString.replaceAll(r'{{title}}', itemInfo.title);
    html = html.replaceAll(r'{{itemSource}}', itemInfo.source);
    if (itemInfo.reads > 0) {
      html = html.replaceAll('{{reads}}', "(${itemInfo.reads}&nbsp;reads)");
    } else {
      html = html.replaceAll('{{reads}}', "");
    }
    html = html.replaceAll(
        r'{{createAt}}',
        DateUtil()
            .getDateString(date: itemInfo.createAt, format: 'yyyy-MM-dd H:mm'));
    html = html.replaceAll(r'{{author}}', itemInfo.author);
    html = html.replaceAll(r'{{body}}', bodyString);
    return html;
  }
}
