import 'package:flutter/foundation.dart';

class ZoomMeeting {
  ZoomMeeting._();
  //  <script src="https://source.zoom.us/zoom-meeting-1.9.1.min.js"></script>
  static String getHtml(String config) {
    String device = kIsWeb ? 'web' : 'mobile';

    return '''
    
    <!DOCTYPE html>

<head>
    <title>Zoom WebSDK</title>
    <meta charset="utf-8" />
    <link type="text/css" rel="stylesheet" href="https://source.zoom.us/1.9.1/css/bootstrap.css" />
    <link type="text/css" rel="stylesheet" href="https://source.zoom.us/1.9.1/css/react-select.css" />
    <meta name="format-detection" content="telephone=no">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <meta http-equiv="origin-trial" content="">
</head>

<body>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/react.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/react-dom.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/redux.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/redux-thunk.min.js"></script>
    <script src="https://source.zoom.us/1.9.1/lib/vendor/lodash.min.js"></script>

    <script src="https://ecollmeet.web.app/live_z/zoom191.js"></script>
    <script>
        const simd = async () => WebAssembly.validate(new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0, 1, 4, 1, 96, 0, 0, 3, 2, 1, 0, 10, 9, 1, 7, 0, 65, 0, 253, 15, 26, 11]))
        simd().then((res) => {
          console.log("simd check", res);
        });
    </script>
    <script >
    
    var config = '$config';
          var device = '$device';
     function sendMessage(message) {
    if(device == 'web')  {
       window.parent.postMessage(JSON.stringify(message), '*');
       }else{
         window.flutter_inappwebview.callHandler('message', JSON.stringify(message));
       }
           
            }
            
               window.addEventListener('message', (event) => {
               // console.log(event.data);
               // console.log('Message geldi');
            }, false);
    
function startMeeting() {
   var meetingConfig = JSON.parse(config);

    
    console.log(JSON.stringify(ZoomMtg.checkSystemRequirements()));


     ZoomMtg.setZoomJSLib("https://source.zoom.us/1.9.1/lib", "/av"); // CDN version defaul
    
    ZoomMtg.preLoadWasm();
    ZoomMtg.prepareJssdk();
   setTimeout(function(){ join(); }, 10);
 
       var join =  function (){
            ZoomMtg.init({
            leaveUrl: meetingConfig.leaveUrl,
            webEndpoint: meetingConfig.webEndpoint,
            success: function () {
                ZoomMtg.i18n.load(meetingConfig.lang);
                ZoomMtg.i18n.reload(meetingConfig.lang);
                ZoomMtg.join({
                    meetingNumber: (Number.isInteger(meetingConfig.mn) ? meetingConfig.mn:parseInt(meetingConfig.mn)).toString(),
                    userName: meetingConfig.name,
                    signature: meetingConfig.signature,
                    apiKey: meetingConfig.ak,
                    userEmail: meetingConfig.email,
                    passWord: meetingConfig.pwd,
                    success: function (res) {
                       
                        ZoomMtg.getAttendeeslist({});
                        ZoomMtg.getCurrentUser({
                            success: function (res) {
                                console.log("success getCurrentUser", res.result.currentUser);
                            },
                        });
                    },
                    error: function (res) {
                        console.log(res);
           
                           sendMessage({id:123,data:res});
                    },
                });
            },
            error: function (res) {
                console.log(res);
            },
        });

        ZoomMtg.inMeetingServiceListener('onUserJoin', function (data) {
        });

        ZoomMtg.inMeetingServiceListener('onUserLeave', function (data) {
        });

        ZoomMtg.inMeetingServiceListener('onUserIsInWaitingRoom', function (data) {
        });

        ZoomMtg.inMeetingServiceListener('onMeetingStatus', function (data) {
          console.log('onMeetingStatus');
          console.log(data);
        });
        }
    


};

   var  mobileIsReady = false;
        var  DOMContentLoaded = false;
      
     if(device == 'web')   {
  window.addEventListener('DOMContentLoaded', function(event) {
  startMeeting();
});
     }else {
      window.addEventListener('DOMContentLoaded', function(event) {
      DOMContentLoaded = true;
      if(mobileIsReady == true){ startMeeting();}
});
       window.addEventListener("flutterInAppWebViewPlatformReady", function (event) {
       mobileIsReady = true;
         if(DOMContentLoaded == true){ startMeeting();}
        });
         
     }
    
    </script>

    
    
    

    
</body>

</html>
    
    
    
    
    
    ''';
  }
}
