importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

//? bu kisim register ederken firebase config bilgilerini sadece eskola projesi icin aliyor
//? ilerleyen zamanlarda kod icinden gelecek sekilde degistir
// var messaging;

// if (self.location.search !== undefined) {
//     var configText = self.location.search.substring(1);

//     if (configText.length > 6) {
//         const params = {};
//         configText.split('&').forEach(pair => {
//             params[pair.split('=')[0]] = pair.split('=')[1];
//         });
//         console.log(params);
//         if (firebase.apps.length == 0) {
//             firebase.initializeApp(params);
//         }
//         messaging = firebase.messaging();
//     }
// }


firebase.initializeApp({
    apiKey: 'AIzaSyApi5aGPiEmN-LxIAbrfkN92Px_7Fe2GCY',
    appId: '1:309980956561:web:6c0d9cb89839f576',
    messagingSenderId: '309980956561',
    projectId: 'class-724',
    authDomain: 'class-724.firebaseapp.com',
    databaseURL: 'https://class-724.firebaseio.com',
    storageBucket: 'class-724.appspot.com',
    measurementId: 'G-4K49YWN356',
});


const messaging = firebase.messaging();
