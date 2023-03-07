import 'package:flutter/foundation.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../jitsihelper.dart';

class JitsiMeeting {
  JitsiMeeting._();
  static String getHtml(JitsiConfigData config) {
    String device = kIsWeb ? 'web' : 'mobile';

    return '''
		
<html itemscope itemtype="http://schema.org/Product" prefix="og: http://ogp.me/ns#" xmlns="http://www.w3.org/1999/html">

<head>
    <meta charset="utf-8">
    <meta http-equiv="content-type" content="text/html;charset=utf-8"> 
    $loaderStyle
</head>

<body style="background-color: rgba(0, 0, 0, 0.0);" id="back">

    <div class="loader-wrapper"> </div>
    
    <script src="https://ecollmeet.web.app/splash.js"></script>
    <script src="https://meet.jit.si/external_api.js"></script>

    $removeLoaderScript

    <script>
        var device = '$device';
   


        function sendMessage(message) {
            if (device == 'web') {
                window.parent.postMessage(JSON.stringify(message), '*');
            } else {
                window.flutter_inappwebview.callHandler('message', JSON.stringify(message));
            }

        }

           window.addEventListener('message', (event) => {
                var receiving = event.data;
           try {
        var  parsedData = JSON.parse(receiving);
        
                   otherFunction(parsedData);
    } catch(e) {
 
    }

        }, false);



        var api;
        var disposeJitsi = function() {
            console.log('Dispose live');
            api.executeCommand('hangup');
            setTimeout(function() {
                api.dispose();
            }, 100);
        }

        var startMeeting = function(domain,roomName,jwt) {
     
            var displayKeyName='${config.edittedKey}';
            var domain = domain;
            var roomName = roomName;
            var jwt = jwt;
             var scaffoldBackgorundColor = '${config.backgorundColor}';
             var isStudent = '${config.girisTuru}' == '30';
             
            
   
             
            var options;
            var logData = [];
            var nameId = {};
            var myId = '';
           

                var bodyBackgroundColor = '#0F0F12';
                if (scaffoldBackgorundColor != null && scaffoldBackgorundColor != 'null') {
                    bodyBackgroundColor = "#" + scaffoldBackgorundColor;
                    document.getElementById("back").style.backgroundColor = bodyBackgroundColor;
                }
      
                options = {
                    roomName: roomName,
                   ${config.jwtToken.safeLength < 6 ? '' : 'jwt: jwt,'}
                    parentNode: undefined,
                     ${configOverwrite()}
                    
                    
                    userInfo: {
                        email: '-',
                        displayName: displayKeyName
                    },
                    ${interfaceConfigOverwrite(config.userName)}
                }
            
       api = new JitsiMeetExternalAPI(domain, options);
                 
            setTimeout(function() {
                var participantss = api.getParticipantsInfo();
                for (var i = 0; i < participantss.length; i++) {
                    var item = participantss[i];
                    if (item.displayName == displayKeyName) {
                        myId = item.participantId;
                        nameId[myId] = displayKeyName;
                    }
                };
            }, 5000);
            
            
            
            api.on('displayNameChange', (sdf) => {
                if (sdf.id == myId && sdf.displayname.split('*').length < 3) {
                    api.executeCommand('displayName', displayKeyName);
                }
            });
            
            api.getAvailableDevices().then(devices => {
    sendMessage({id:28,data:devices});
     api.on('deviceListChanged', (sdf) => {
               sendMessage({id:28,data:sdf.devices});
            });
   });
   
           
            
            if (!isStudent) {
                api.on('participantJoined', (sdf) => {

                    nameId[sdf['id']] = sdf['displayName'];
                    logData.push(['participantJoined', sdf['displayName'], new Date().getTime()]);
                    sendMessage({id:5,data:api._participants});
                    sendMessage({id:4,data:logData});
                    
               
                });
                api.on('participantLeft', (sdf) => {
                    logData.push(['participantLeft', nameId[sdf['id']], new Date().getTime()]);
              sendMessage({id:5,data:api._participants});
                    sendMessage({id:4,data:logData});
                });
                api.on('participantKickedOut', (sdf) => {
                    logData.push(['participantKickedOut', nameId[sdf['kicker']['id']], nameId[sdf['kicked']['id']], new Date().getTime()]);
                       sendMessage({id:4,data:logData});
                });
            }
            api.on('videoMuteStatusChanged', (sdf) => {
                       sendMessage({id:6,data:sdf['muted'] == false});
            
            });
            api.on('audioMuteStatusChanged', (sdf) => {
              sendMessage({id:7,data:sdf['muted'] == false});
            
            });
            api.on('tileViewChanged', (sdf) => {
                         sendMessage({id:8,data:sdf['enabled']});
        
            });



            removeLoader();
        }
     console.log('aaaa');
        var otherFunction = function(comingData) {
            
            var type = comingData['id'];
            var data = comingData['data'];
            
            ///Herkesi sessize al
            if (type == 0) {
                api.executeCommand('muteEveryone');
            } else
                ///Youtube yayini baslat     
                if (type == 1) {
                    api.executeCommand('startRecording', {
                        mode: 'stream',
                        youtubeStreamKey: data
                    });
                } ///Youtube yayini durdur     
            if (type == 2) {
                api.executeCommand('stopRecording', 'stream');
            }
            ///    Ekran paylasimini acar
            if (type == 3) {
                api.executeCommand('toggleShareScreen');
            }
            if (type == 6) {
                api.executeCommand('toggleVideo');
            }
            if (type == 7) {
                api.executeCommand('toggleAudio');
            }
            if (type == 8) {
                api.executeCommand('toggleTileView');
            }
            if (type == 10) {
                disposeJitsi();
            }
            if (type == 27) {
              api.setAudioInputDevice(data['deviceLabel'], data['deviceId']);
            } 
            if (type == 28) {
              api.setAudioOutputDevice(data['deviceLabel'], data['deviceId']);
            } 
            if (type == 29) {
         
              api.setVideoInputDevice(data['deviceLabel'], data['deviceId']);
            }
            if (type == 300) {
                startMeeting(comingData['domain'],comingData['roomName'],comingData['jwt']);
            }

            if (type == 400) {
                //api.executeCommand('kickParticipant',arg1);

            }

        }
       


        var mobileIsReady = false;
        var DOMContentLoaded = false;

        if (device == 'web') {
            window.addEventListener('DOMContentLoaded', function(event) {
                          sendMessage({id:300,data:null});
            });
        } else {
            window.addEventListener('DOMContentLoaded', function(event) {

                DOMContentLoaded = true;
                if (mobileIsReady == true) {
               sendMessage({id:300,data:null});
                }
            });
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {

                mobileIsReady = true;
                if (DOMContentLoaded == true) {
                     sendMessage({id:300,data:null});
                }
            });

        }

    </script>

    <style>


    </style>
</body>

</html>

		
		
		
		''';
  }

  static String configOverwrite() {
    return '''
  configOverwrite: {
    
                        subject: "---",
                        e2eping: {
                            pingInterval: -1
                        },
                        prejoinPageEnabled: false,
                        desktopSharingChromeDisabled: true,
                        desktopSharingFirefoxDisabled: true,
                        disableDeepLinking: true,
                        defaultLanguage: 'tr',
                        hideLobbyButton: true,
                        enableNoAudioDetection: false,
                        enableTalkWhileMuted: false,
                        disableAudioLevels: false,
                        enableNoisyMicDetection: false,
                        disableRecordAudioNotification: true,
                        startWithAudioMuted: isStudent,
                        startWithVideoMuted: isStudent,
                        noticeMessage: '',
                        remoteVideoMenu: {
                            disableKick: true //isStudent,
                        },
                        disableRemoteMute: true, //isStudent,
                        LOBBY_MODE_ENABLED: false,
                        hiddenDomain: true
                    },
    
    ''';
  }

  static String interfaceConfigOverwrite(String? userName) {
    return '''
    interfaceConfigOverwrite: {
                        //   SET_FILMSTRIP_ENABLED: false,
                        LOBBY_MODE_ENABLED: false,
                        DISABLE_PRIVATE_MESSAGES: true,
                        DEFAULT_BACKGROUND: bodyBackgroundColor,
                        DISABLE_VIDEO_BACKGROUND: true,
                        INITIAL_TOOLBAR_TIMEOUT: 20000,
                        TOOLBAR_TIMEOUT: 4000,
                        TOOLBAR_ALWAYS_VISIBLE: false,
                        DEFAULT_REMOTE_DISPLAY_NAME: 'User',
                        DEFAULT_LOCAL_DISPLAY_NAME: '$userName',
                        SHOW_JITSI_WATERMARK: false,
                        SHOW_WATERMARK_FOR_GUESTS: false,
                        SHOW_BRAND_WATERMARK: false,
                        BRAND_WATERMARK_LINK: '',
                        SHOW_POWERED_BY: false,
                        SHOW_DEEP_LINKING_IMAGE: false,
                        GENERATE_ROOMNAMES_ON_WELCOME_PAGE: false,
                        DISPLAY_WELCOME_PAGE_CONTENT: false,
                        DISPLAY_WELCOME_PAGE_TOOLBAR_ADDITIONAL_CONTENT: false,
                        APP_NAME: 'Live',
                        NATIVE_APP_NAME: 'Live',
                        PROVIDER_NAME: 'User',
                        LANG_DETECTION: true,
                        INVITATION_POWERED_BY: true,
                        AUTHENTICATION_ENABLE: true,
                        TOOLBAR_BUTTONS: [],
                        SETTINGS_SECTIONS: [],
                        VIDEO_LAYOUT_FIT: 'both',
                        filmStripOnly: false,
                        VERTICAL_FILMSTRIP: true,
                        CLOSE_PAGE_GUEST_HINT: false,
                        SHOW_PROMOTIONAL_CLOSE_PAGE: false,
                        RANDOM_AVATAR_URL_PREFIX: false,
                        RANDOM_AVATAR_URL_SUFFIX: false,
                        FILM_STRIP_MAX_HEIGHT: 120,
                        ENABLE_FEEDBACK_ANIMATION: false,
                        DISABLE_FOCUS_INDICATOR: true,
                        DISABLE_DOMINANT_SPEAKER_INDICATOR: true,
                        DISABLE_TRANSCRIPTION_SUBTITLES: true,
                        DISABLE_RINGING: false,
                        AUDIO_LEVEL_PRIMARY_COLOR: 'rgba(236,109,118,0.8)',
                        AUDIO_LEVEL_SECONDARY_COLOR: 'rgba(238,151,87,0.6)',
                        POLICY_LOGO: null,
                        LOCAL_THUMBNAIL_RATIO: 16 / 9, // 16:9
                        REMOTE_THUMBNAIL_RATIO: 16 / 9, // 1:1
                        LIVE_STREAMING_HELP_LINK: '',
                        MOBILE_APP_PROMO: false,
                        MAXIMUM_ZOOMING_COEFFICIENT: 1.3,
                        SUPPORT_URL: '',
                        CONNECTION_INDICATOR_AUTO_HIDE_ENABLED: false,
                        CONNECTION_INDICATOR_AUTO_HIDE_TIMEOUT: 5000,
                        CONNECTION_INDICATOR_DISABLED: true,
                        VIDEO_QUALITY_LABEL_DISABLED: true,
                        RECENT_LIST_ENABLED: false,
                        OPTIMAL_BROWSERS: ['chrome', 'chromium', 'firefox', 'nwjs', 'electron','safari','ios'],
                        UNSUPPORTED_BROWSERS: [],
                        AUTO_PIN_LATEST_SCREEN_SHARE: 'remote-only',
                        DISABLE_PRESENCE_STATUS: false,
                        DISABLE_JOIN_LEAVE_NOTIFICATIONS: true,
                        SHOW_CHROME_EXTENSION_BANNER: false,
                        HIDE_KICK_BUTTON_FOR_GUESTS: false
                    }
    
    ''';
  }

  static String get loaderStyle {
    return '''
    <style>
   html, body {margin: 0; height: 100%; width: 100%;overflow: hidden}
        .loader-wrapper {
            width: 100%;
            height: 100%;
            position: absolute;
            top: 0;
            left: 0;
            background-color: rgba(0, 0, 0, 0.0);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 999
        }

        .loader-wrapper.hidden {
            animation: fadeOut 1s;
            animation-fill-mode: forwards
        }

    </style>
    ''';
  }

  static String get removeLoaderScript {
    return '''
      <script>
        var removeLoader = function() {
            const loader = document.querySelector(".loader-wrapper");
            if (loader == null || loader.className.includes('hidden')) {
                return;
            };
            loader.className += " hidden";
            setTimeout(function() {
                loader.parentNode.removeChild(loader);
            }, 2000);
        }

    </script>
    ''';
  }
}
