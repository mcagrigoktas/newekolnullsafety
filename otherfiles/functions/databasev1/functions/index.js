const functions = require('firebase-functions');
//const Iyzipay = require('./node_modules/iyzipay/lib/Iyzipay.js');
const request = require('request');
const serviceAccount = require('./serviceAccount.json');
// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();
var app2 = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
}, 'app2');



/* Flutterda örnek çağırma
 // Bir istekte en fazla 1000 bildirim atabilirsin
    CloudFunctions.instance.call(functionName: "sendNotificationFromApp",
        parameters: {"baslik":"Başlık","mesaj":"Duyuru İçeriği",
          "tokenList":["cVfm2wkevFU:APA91bHP0Mr3E-8G66JnJIcWqPF1T36ppRXJWmZUTjT8wQb14j302G6xbTvIYWbbLYBxFE14CuR_W-8s5bb60CdJD6_5FsqPgS9KqypcQ6HFfpldqNHWSgrdexBSUOPbb7WVaFYYpM7t",
          "drdulb1H0Hw:APA91bEG7yCxfwkwaTRSCZqkjdR5HUagsQE-b0B_WKzVnFKMbLeI9TvcmbA87brLRReRCUu82jdh9Cfz394B0SUuAoyEsFApai4x3iTehuMV23zJ64DWz29A4G4hWp2uqFjqRaIzZSNs"]})
        .catchError((err){print(err.message);});
*/

exports.getToken = functions.https.onCall(async (data, context) => {


    const userId = data.uid;
    const additionalClaims = data.claims;

    var customToken = null;
    await admin
        .auth(app2)
        .createCustomToken(userId, additionalClaims)
        .then((token) => {
            customToken = token;
            return customToken;
        })
        .catch((error) => {
            console.log('Error creating custom token:', error);
            return null;
        });
    return customToken;
});


exports.sendNotificationFromApp = functions.https.onCall((data, context) => {

    const baslik = data.baslik;
    const mesaj = data.mesaj;
    const tokenList = data.tokenList;

    const tag = data.tag === null || data.tag === undefined ? 'notification' : data.tag ;
    const android_channel_id = data.android_channel_id === null || data.android_channel_id === undefined  ? 'default' : data.android_channel_id ;
     const sound = data.sound === null || data.sound === undefined  ? 'default' : data.sound ;

    if (!(typeof baslik === 'string') || baslik.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Baslik Hatalı.');
    }

    if (!(typeof mesaj === 'string') || mesaj.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Mesaj Haatalı');
    }
    if (!(tokenList.length > 0) || tokenList.length > 1000) {
        throw new functions.https.HttpsError('invalid-argument', 'Token listesi hatalı.');
    }

    console.log("Bildirim " + tokenList.length + " kişiye atılıyor.");
//    let payload = {
//        notification: {
//            title: baslik,
//            body: mesaj,
//            sound: 'default',
//            badge: '1',
//            tag: 'notification'
//        }
//    };
let payload = {
            notification: {
                title: baslik,
                body: mesaj,
                sound: sound,
                  android_channel_id: android_channel_id,
             //   click_action: click_action,
               badge: '1'
            //    tag: tag
            },
            data: {
               click_action: 'FLUTTER_NOTIFICATION_CLICK',
                 sound: sound,
                 tag: tag

            }
        };

    return admin.messaging().sendToDevice(tokenList, payload);
    /*.then(response => {
          // For each message check if there was an error.
          const tokensToRemove = [];
          response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
              console.error('Failure sending notification to', tokenList[index], error);
              // Cleanup the tokens who are not registered anymore.
              if (error.code === 'messaging/invalid-registration-token' ||
                  error.code === 'messaging/registration-token-not-registered') {
                tokensToRemove.push(tokensSnapshot.ref.child(tokenList[index]).remove());
              }
            }
          });
          return Promise.all(tokensToRemove);
        });*/

});


/*
 Flutterda örnek çağırma
    CloudFunctions.instance.call(functionName: "sendTopicNotification",
        parameters: {"baslik":"Başlık","mesaj":"Duyuru İçeriği","topic":"TOPIC"})
        .catchError((err){print(err.message);});
*/

exports.sendTopicNotification = functions.https.onCall((data, context) => {

    const baslik = data.baslik;
    const mesaj = data.mesaj;
    const topic = data.topic;

    const tag = data.tag === null || data.tag === undefined  ? 'notification' : data.tag ;
        const android_channel_id = data.android_channel_id === null || data.android_channel_id === undefined  ? 'default' : data.android_channel_id ;

    const sound = data.sound === null || data.sound === undefined  ? 'default' : data.sound ;

    if (!(typeof baslik === 'string') || baslik.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Baslik Hatalı.');
    }

    if (!(typeof mesaj === 'string') || mesaj.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Mesaj Haatalı');
    }
    if (!(typeof topic === 'string') || topic.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Topic Haatalı');
    }
    console.log("Topic mesaj atılıyor.");

//    let payload = {
//        notification: {
//            title: baslik,
//            body: mesaj,
//            sound: 'default',
//            badge: '1',
//            tag: 'notification'
//        }
//    };
let payload = {
            notification: {
                title: baslik,
                body: mesaj,
                  sound: sound,
                android_channel_id: android_channel_id,
         //        click_action: click_action,
                badge: '1'
          //   tag: tag
            },
            data: {
               click_action: 'FLUTTER_NOTIFICATION_CLICK',
                 sound: sound,
                 tag: tag
            }
        };
    const options = {
        priority: "high",
        timeToLive: 60 * 60 * 2
    };

    return admin.messaging().sendToTopic(topic, payload, options);


});





//exports.onPaymentCreate = functions.https.onCall((data, context) => {
//
//
//    const cardHolderName = data.cardHolderName;
//    const cardNumber = data.cardNumber;
//    const expireMonth = data.expireMonth;
//    const expireYear = data.expireYear;
//    const cvc = data.cvc;
//    const registerCard = 0;
//
//
//
//    if (!(typeof cardHolderName === 'string') || cardHolderName.length === 0) {
//        throw new functions.https.HttpsError('invalid-argument', 'Girilen Bilgiler Hatalı.');
//    }
//    if (!(typeof cardNumber === 'string') || cardNumber.length === 0) {
//        throw new functions.https.HttpsError('invalid-argument', 'Girilen Bilgiler Hatalı.');
//    }
//    if (!(typeof expireMonth === 'string') || expireMonth.length === 0) {
//        throw new functions.https.HttpsError('invalid-argument', 'Girilen Bilgiler Hatalı.');
//    }
//    if (!(typeof expireYear === 'string') || expireYear.length === 0) {
//        throw new functions.https.HttpsError('invalid-argument', 'Girilen Bilgiler Hatalı.');
//    }
//    if (!(typeof cvc === 'string') || cvc.length === 0) {
//        throw new functions.https.HttpsError('invalid-argument', 'Girilen Bilgiler Hatalı.');
//    }
//
//
//
//
//    const iyzipay = new Iyzipay({
//        apiKey: 'sandbox-BZjKML2QdjywincCc6W5ngDiwzPWTygw',
//        secretKey: 'sandbox-uLaOvcqAbD740xS2ovkGz97zHRuUGJcc',
//        uri: 'https://sandbox-api.iyzipay.com'
//    });
//    const request = {
//        locale: Iyzipay.LOCALE.TR,
//        conversationId: '123456789',
//        price: '1',
//        paidPrice: '1.2',
//        currency: Iyzipay.CURRENCY.TRY,
//        installment: '1',
//        basketId: 'B67832',
//        paymentChannel: Iyzipay.PAYMENT_CHANNEL.WEB,
//        paymentGroup: Iyzipay.PAYMENT_GROUP.PRODUCT,
//        paymentCard: {
//            cardHolderName: cardHolderName,
//            cardNumber: cardNumber,
//            expireMonth: expireMonth,
//            expireYear: expireYear,
//            cvc: cvc,
//            registerCard: registerCard
//        },
//        buyer: {
//            id: 'BY789',
//            name: 'John',
//            surname: 'Doe',
//            gsmNumber: '+905350000000',
//            email: 'email@email.com',
//            identityNumber: '74300864791',
//            lastLoginDate: '2015-10-05 12:43:35',
//            registrationDate: '2013-04-21 15:12:09',
//            registrationAddress: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
//            ip: '85.34.78.112',
//            city: 'Istanbul',
//            country: 'Turkey',
//            zipCode: '34732'
//        },
//        shippingAddress: {
//            contactName: 'Jane Doe',
//            city: 'Istanbul',
//            country: 'Turkey',
//            address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
//            zipCode: '34742'
//        },
//        billingAddress: {
//            contactName: 'Jane Doe',
//            city: 'Istanbul',
//            country: 'Turkey',
//            address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
//            zipCode: '34742'
//        },
//        basketItems: [{
//                id: 'BI101',
//                name: 'Binocular',
//                category1: 'Collectibles',
//                category2: 'Accessories',
//                itemType: Iyzipay.BASKET_ITEM_TYPE.PHYSICAL,
//                price: '0.3'
//            },
//            {
//                id: 'BI102',
//                name: 'Game code',
//                category1: 'Game',
//                category2: 'Online Game Items',
//                itemType: Iyzipay.BASKET_ITEM_TYPE.VIRTUAL,
//                price: '0.5'
//            },
//            {
//                id: 'BI103',
//                name: 'Usb',
//                category1: 'Electronics',
//                category2: 'Usb / Cable',
//                itemType: Iyzipay.BASKET_ITEM_TYPE.PHYSICAL,
//                price: '0.2'
//            }
//        ]
//    };
//    console.log(iyzipay);
//    iyzipay.payment.create(request, function(err, result) {
//        console.log(err);
//        console.log(result);
//    });
//
//});

exports.databaseSmsTrigger = functions.database.ref('/Other/SmsRecords/{key}}')
    .onCreate((snapshot, context) => {

      const data = snapshot.val();

      const numbers = data.numbers;
      const u = data.u;
      const sms = data.sms;
    const type = data.type;

         if (!(typeof numbers === 'string') || numbers.length === 0) {
             throw new functions.https.HttpsError('invalid-argument', 'Numara listesi Hatalı.');
         }

         if (!(typeof sms === 'string') || sms.length === 0) {
             throw new functions.https.HttpsError('invalid-argument', 'Mesaj Hatalı');
         }

         if (!(typeof u === 'string') || u.length === 0) {
                 throw new functions.https.HttpsError('invalid-argument', 'Kullanici adi Haatalı');
             }
//https://www.bulksmsnigeria.com/api/v1/sms/create?api_token=N7ZPNMHqQ9Rs9PlzVfr17xo3syFM0HekM86iZ12uEbnSq7EM5HSt2htyCPMo&from=SMATAPP&to=08092179005&body=sms

    if(type===2){
      ///Smat message  
          var nigerianUrl = 'https://www.bulksmsnigeria.com/api/v1/sms/create?api_token='+'N7ZPNMHqQ9Rs9PlzVfr17xo3syFM0HekM86iZ12uEbnSq7EM5HSt2htyCPMo'+'&from='+'SMATAPP'+'&to='+numbers+'&body='+sms;

         var nigerioanOptions = {
                method: 'POST',
                url: nigerianUrl
             //,
//                headers: {
//                  'content-type': 'text/xml;charset=turkish'
//                },
//                body: xml,
              //  gzip: true //depending on the webservice, this has to be false
              };
       var nigerioanOptionsResult = request(nigerioanOptions, function (error, response, body) {
                if(error!==null){console.log(error);}
     console.log('Nigeria StatusCode:'+response.statusCode);

           });
    }else{
        ///Elseif message
         var xml = '<?xml version="1.0" encoding="UTF-8"?> <smspack ka="'+u+'" pwd="Ankara06." org="908505543729"> <mesaj> <metin>'+sms+'</metin> <nums>'+numbers+'</nums></mesaj> </smspack>';

         var options = {
                method: 'POST',
             //   keepAlive: false,
                url: 'https://smsgw.mutlucell.com/smsgw-ws/sndblkex',
                headers: {
                  'content-type': 'text/xml;charset=turkish'
                },
                body: xml
              //  gzip: true //depending on the webservice, this has to be false
              };
       var x = request(options, function (error, response, body) {
                if(error!==null){console.log(error);}
     console.log('StatusCode:'+response.statusCode);

           });
    }
    
        
               return true;
    });




exports.callFirebaseHttp = functions.https.onCall( async (data, context) => {

    const method = data.method;
    const url = data.url;
    const headers = data.headers;
    const body = data.body;

    if (!(typeof method === 'string') || method.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Baslik Hatalı.');
    }

    if (!(typeof url === 'string') || url.length === 0) {
        throw new functions.https.HttpsError('invalid-argument', 'Mesaj Haatalı');
    }
   
    var options = {
                method: method,
                url: url,
                headers: headers,
                body: body
              };
    
    
    
    var resp = await new Promise(async(resolve, reject) => {
        await request(options, function (error, response, body) {

             resolve({
                 'error':error,
                 'body':body
             });
           });
  
        
  });

    return resp;
});