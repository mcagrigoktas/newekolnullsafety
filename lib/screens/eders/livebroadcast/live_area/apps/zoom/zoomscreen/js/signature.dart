import 'package:flutter/foundation.dart';

class ZoomSignature {
  ZoomSignature._();

  static String getHtml(String config) {
    String device = kIsWeb ? 'web' : 'mobile';

    return '''
		
<!DOCTYPE html>

<head>
    <title>Zoom</title>
    <meta charset="utf-8" />
    <link type="text/css" rel="stylesheet" href="https://source.zoom.us/1.9.1/css/bootstrap.css" />
    <link type="text/css" rel="stylesheet" href="https://source.zoom.us/1.9.1/css/react-select.css" />
    <meta name="format-detection" content="telephone=no">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">

    <style>
        .loader-wrapper {
            width: 100%;
            height: 100%;
            position: fixed;
            top: 0;
            left: 0;
            background-color: rgba(0, 0, 0, 0.0);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999999999999;
        }

        #zmmtg-root {
            opacity: 0;
        }

    </style>

</head>

<body style="background-color: rgba(0, 0, 0, 0.0);" id="back">

    <div class="loader-wrapper"> </div>
    <script src="https://ecollmeet.web.app/splash.js"></script>

    <script src="https://source.zoom.us/1.9.1/lib/vendor/react.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/react-dom.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/redux.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/redux-thunk.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/lodash.min.js"></script>
   
 <script src="https://ecollmeet.web.app/live_z/zoom191.js"></script>
    <script>
        var config = '$config';
        var device = '$device';



        function sendMessage(message) {
            if (device == 'web') {
                window.parent.postMessage(JSON.stringify(message), '*');
            } else {
                window.flutter_inappwebview.callHandler('message', JSON.stringify(message));
            }

        }

        function prepareMeeting() {



            if (config == null) {
                return;
            }

            var meetingConfig = JSON.parse(config);

            ZoomMtg.preLoadWasm();

            var signature = ZoomMtg.generateSignature({
                meetingNumber: meetingConfig.mn,
                apiKey: meetingConfig.ak,
                apiSecret: meetingConfig.as,
                role: meetingConfig.role,
                success: function(res) {
                    console.log('Buradaaaa');
                    sendMessage({
                        id: 120,
                        data: res.result
                    });
                },
            });


        }

        var mobileIsReady = false;
        var DOMContentLoaded = false;

        if (device == 'web') {
            window.addEventListener('DOMContentLoaded', function(event) {
                prepareMeeting();
            });
        } else {
            window.addEventListener('DOMContentLoaded', function(event) {
                DOMContentLoaded = true;
                if (mobileIsReady == true) {
                    prepareMeeting();
                }
            });
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                mobileIsReady = true;
                if (DOMContentLoaded == true) {
                    prepareMeeting();
                }
            });

        }

    </script>



</body>

</html>
		
		''';
  }
}
