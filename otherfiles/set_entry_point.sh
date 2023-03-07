
# jsx ile baslayip sonuna 3 karakter ekleyen bir klasor olsutruru. Maindartjs dosyasini bu klasore tasir

harfler="qwxabcdefghijkl0123456789"

random=$(echo $harfler | fold -w1 | shuf | tr -d '\n' | head -c3)
js_path="jsx$random"


cd ./build/web

sed -i.bak "s/main.dart.js/${js_path}\/main.dart.js/g" index.html
rm index.html.bak

rm -rf jsx*/
mkdir $js_path
chmod u+w $js_path

find . -name "main.dar*" -a -name "*t.js" -print0 | while read -d $'\0' file
do
  filename=$(echo $file | cut -c 3-)
  mkdir -p "$js_path/$(dirname $filename)"
  mv "$filename" "$js_path/$filename"
done



FILENAME=$js_path/main.dart.js
FILESIZE=$(stat  -f%z "$FILENAME")
echo "main.dart.js Size $FILESIZE bytes in $js_path folder"