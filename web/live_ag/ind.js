console.log('hey1');
var ADataFunction;
var ADataFunctionInitialize = function (fun) {
    ADataFunction = fun;
}
var ADataFunctionCall = function (id, data) {
    ADataFunction(id, JSON.stringify(data));
}
var AExtraFunctionCall = function (type, arg1, arg2, arg3, arg4, arg5) {
    console.log('hey2');
    if (type == 100) {
        data = JSON.parse(arg1);
        localeView = arg4;
        getWebElement = arg2;
        removeWebElement = arg3;
        init();
    }
    if (type == 10) {
        leave();
    }
    ///Herkesi sessize al
    if (type == 0) {
        api.executeCommand('muteEveryone');
    } else
        ///Youtube yayini baslat
        if (type == 1) {
            api.executeCommand('startRecording', {
                mode: 'stream',
                youtubeStreamKey: arg1
            });
        } ///Youtube yayini durdur
    if (type == 2) {
        api.executeCommand('stopRecording', 'stream');
    }
    ///    Ekran paylasimini acar
    if (type == 3) {
        if (screenShareClient == null) {
            startScreenShare();
        } else {
            stopScreenShare();
        }
    }
    if (type == 6) {
        if (preferences.videoEnable == true) {
            localTracks.videoTrack.setEnabled(false);
            preferences.videoEnable = false;
        } else {
            localTracks.videoTrack.setEnabled(true);
            preferences.videoEnable = true;
        }
        ADataFunctionCall(6, preferences.videoEnable);
    }
    if (type == 7) {
        if (preferences.audioEnable == true) {
        //    client.unpublish(localTracks.audioTrack);
            localTracks.audioTrack.setEnabled(false);
            preferences.audioEnable = false;
        } else {
         //    client.publish(localTracks.audioTrack);
            localTracks.audioTrack.setEnabled(true);
            preferences.audioEnable = true;
        }
        ADataFunctionCall(7, preferences.audioEnable);
    }
    if (type == 8) {
        api.executeCommand('toggleTileView');
    }
}
var client;
var screenShareClient;
var screenTrack = null;
var localTracks = {
    videoTrack: null,
    audioTrack: null
};
var preferences = {
    videoEnable: true,
    audioEnable: true
}
var data = {
    n: null,
    k: null,
    d: null,
    rn: null,
    t: null,
    gt: null,
    sh: null,
    res: null
};
var localeView;
var logData = [];
var nameId = {};
var myId = '';
var api;
var getWebElement;
var removeWebElement;
var participantsData = {};
var init = async function () {
    
    if (client != null) {
        await client.leave();
    }
    client = AgoraRTC.createClient({
        mode: "rtc",
        codec: "vp8"
    });
    client.on("user-published", handleUserPublished);
    client.on("user-unpublished", handleUserUnpublished);
    join();
}
async function startScreenShare() {
    screenShareClient = AgoraRTC.createClient({
        mode: "rtc",
        codec: "vp8"
    });
    await screenShareClient.join(data.d, data.rn, data.t || null, 'ScreenShare');
    screenTrack = await AgoraRTC.createScreenVideoTrack(
        //    {
        //        encoderConfig: "720p_1"
        //    }
    );
    await screenShareClient.publish(screenTrack);
}
async function stopScreenShare() {
    if (screenShareClient != null) {
        if (screenTrack != null) {
            screenTrack.stop();
            screenTrack.close();
            screenTrack = null;
        }
        await screenShareClient.leave();
        screenShareClient = null;
    }
}
async function join() {
    var uid = data.n + '*' + data.k + '*W*' + data.gt;
            [data.k, localTracks.audioTrack, localTracks.videoTrack] = await Promise.all([
                client.join(data.d, data.rn, data.t || null, uid)
                , AgoraRTC.createMicrophoneAudioTrack()
                , AgoraRTC.createCameraVideoTrack({
            encoderConfig: data.gt < 25 ? "240p_1" : "180p_1"
        })
            ]);
    console.log(data.gt < 25 ? "480p_1" : "240p_1");
    localTracks.videoTrack.play(localeView);
    await client.publish(Object.values(localTracks));
}
async function leave() {
    stopScreenShare();
    for (trackName in localTracks) {
        var track = localTracks[trackName];
        if (track) {
            track.stop();
            track.close();
            localTracks[trackName] = undefined;
        }
    }
    //Burda participantHolders listesini temizleyebilirsin
    await client.leave();
}
async function subscribe(user, mediaType) {
   console.log('Logum: subscribe');
   console.log(user);
   console.log(mediaType);
    const uid = user.uid;
    await client.subscribe(user, mediaType);

    if (mediaType === 'video') {
            const player = getWebElement(uid);
        user.videoTrack.play(player);
    }
    if (mediaType === 'audio') {
        user.audioTrack.play();
    }
}

function handleUserPublished(user, mediaType) {
     console.log('Logum: handleUserPublished');
   console.log(user);
   console.log(mediaType);
    //todo ogrenci kamera kapatip actigindada cikip girmis gozukuyor
    const id = user.uid;
    if (id != 'ScreenShare') {
        participantsData[id] = {
            'displayName': id
        };
        logData.push(['participantJoined' + mediaType.substring(0, 1), id, new Date().getTime()]);
        ADataFunctionCall(5, participantsData);
        ADataFunctionCall(4, logData);
    }
    subscribe(user, mediaType);
}

function handleUserUnpublished(user) {
     console.log('Logum: handleUserUnpublished');
   console.log(user);
    //todo ogrenci kamera kapatip actigindada cikip girmis gozukuyor
    const id = user.uid;
    if (id != 'ScreenShare') {
        delete participantsData[id];
        logData.push(['participantLeft', id, new Date().getTime()]);
        ADataFunctionCall(5, participantsData);
        ADataFunctionCall(4, logData);
    }
    removeWebElement(id);
}
//        var disposeJitsi = function() {
//            api.executeCommand('hangup');
//            setTimeout(function() {
//                api.dispose();
//            }, 100);
//        }
//        setTimeout(function() {
//            var participantss = api.getParticipantsInfo();
//            for (var i = 0; i < participantss.length; i++) {
//                var item = participantss[i];
//                if (item.displayName == data.n + '*' + data.k + '*W') {
//                    myId = item.participantId;
//                    nameId[myId] = data.n + '*' + data.k + '*W';
//                }
//            };
//
//        }, 5000);
//        api.on('displayNameChange', (sdf) => {
//
//            if (sdf.id == myId && sdf.displayname.split('*').length < 3) {
//                api.executeCommand('displayName', data.n + '*' + data.k + '*W');
//            }
//        });
//        if (data.gt != '30') {
//
//            api.on('participantKickedOut', (sdf) => {
//
//                logData.push(['participantKickedOut', nameId[sdf['kicker']['id']], nameId[sdf['kicked']['id']], new Date().getTime()]);
//                window.parent.JDataFunctionCall(4, logData);
//            });
//
//        }
//        api.on('tileViewChanged', (sdf) => {
//            window.parent.JDataFunctionCall(8, sdf['enabled']);
//        });
