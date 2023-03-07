echo "1 eokuldeneme \n2 ecollmeet \n3 class-724 \n4 ecolines \n20 marketinfo \n30 tuaacademy"
read no

if [ $no == "1" ]
then
echo "..eokuldeneme deploying..."
firebase deploy --only hosting:eokuldeneme
elif [ $no == "2" ]
then
echo "..ecollmeet deploying..."
firebase deploy --only hosting:ecollmeet
elif [ $no == "3" ]
then
echo "..class-724 deploying..."
firebase deploy --only hosting:class-724
elif [ $no == "4" ]
then
echo "..ecolines deploying..."
firebase deploy --only hosting:ecolines
elif [ $no == "20" ]
then
echo "..marketinfo deploying..."
firebase deploy --only hosting:userdatainfo
elif [ $no == "30" ]
then
echo "..tuaacademy deploying..."
firebase deploy --only hosting:tuaacademy
elif [ $no == "ios" ]
then
echo "wrong number"
fi