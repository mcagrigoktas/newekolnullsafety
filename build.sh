echo "Platforms: 1.web auto, 2.appbundle, 3.apk, 4.ios,5 ipa, 10.web html 11.web canvaskit ,20 userdatainfo"
read platform
if [ ${platform} != "1" ] && [ ${platform} != "10" ] && [ ${platform} != "11" ] && [ ${platform} != "20" ] 
then
echo "Flavors: elseif,speedsis,elseifekid,qbank,aci,acilim,muradiye,golbasi,taktikbende,tarea,teknokent,datatac,datatacekid,smatqbank,tua"
read flavor
fi

if [ ${platform} == "1" ]
then
echo ...web building auto...
flutter build web  --web-renderer auto
./otherfiles/set_entry_point.sh
elif [ ${platform} == "10" ]
then
echo ...web building html...
flutter build web  --web-renderer html
./otherfiles/set_entry_point.sh
elif [ ${platform} == "11" ]
then
echo ...web building canvaskit...
flutter build web  --web-renderer canvaskit
./otherfiles/set_entry_point.sh
elif [ ${platform} == "20" ]
then
echo ...web building canvaskit...
flutter build web -t lib/flavors/market_info/main.dart --web-renderer canvaskit
FILENAME=build/web/main.dart.js
FILESIZE=$(stat  -f%z "$FILENAME")
echo "Javascript dosya boyutu $FILESIZE bytes."
elif [ ${platform} == "2" ]
then
echo ...${flavor}flavor appbundle building...
flutter build appbundle  -t lib/flavors/main_${flavor}.dart --flavor ${flavor}flavor
open build/app/outputs/bundle/${flavor}flavorRelease
elif [ ${platform} == "3" ]
then
echo ...${flavor}flavor apk building...
flutter build apk  -t lib/flavors/main_${flavor}.dart --flavor ${flavor}flavor
open build/app/outputs/flutter-apk
elif [ ${platform} == "5" ]
then
echo ...${flavor}flavor ipa building...
flutter build ipa  -t lib/flavors/main_${flavor}.dart --flavor ${flavor}flavor
open build/ios/ipa
elif [ ${platform} == "4" ]
then
echo ...${flavor}flavor ios building...
flutter build ios  -t lib/flavors/main_${flavor}.dart --flavor ${flavor}flavor
fi 

# github control 2
