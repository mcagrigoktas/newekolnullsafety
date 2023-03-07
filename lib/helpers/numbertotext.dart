class NumberToText {
  NumberToText._();
  static String change(num arg) => turkish(arg);
  static String turkish(num arg) {
    String sayi = arg.toString();

    var bolum1 = ["", "Bir", "İki", "Üç", "Dört", "Beş", "Altı", "Yedi", "Sekiz", "Dokuz"];
    var bolum2 = ["", "On", "Yirmi", "Otuz", "Kırk", "Elli", "Altmış", "Yetmiş", "Seksen", "Doksan"];
    var bolum3 = ["", "Yüz", "Bin", "Milyon", "Milyar", "Trilyon", "Katrilyon"];

    String sayi1; //tam kısım
    //var sayi2 = ""; // ondalıklı kısım
    var sonuc = "";

    sayi = sayi.replaceAll(",", "."); //virgül girilirse noktaya dönüştürülüyor

    if (sayi.indexOf(".") > 0) {
      // nokta varsa (kuruş)
      sayi1 = sayi.substring(0, sayi.indexOf(".")); // tam kısım
      //sayi2 = sayi.substring(sayi.indexOf("."), sayi.length); // ondalıklı kısım

    } else {
      sayi1 = sayi; // ondalık yok
    }

    var rk = sayi1.split(""); // rakamlara ayırma

    String son;
    var w = 1; // işlenen basamak
    var sonaekle = 0; // binler on binler yüzbinler vs. için sona bin (milyon,trilyon...) eklenecek mi?
    var kac = rk.length; // kaç rakam var?
    int sonint; // işlenen basamağın rakamsal değeri
    var uclubasamak = 0; // hangi basamakta (birler onlar yüzler gibi)
    var artan = 0; // binler milyonlar milyarlar gibi artışları yapar
    String gecici;

    if (kac > 0) {
      // virgül öncesinde rakam var mı?

      for (var i = 0; i < kac; i++) {
        son = rk[kac - 1 - i]; // son karakterden başlayarak çözümleme yapılır.
        sonint = int.parse(son); // işlenen rakam
        if (w == 1) {
          // birinci basamak bulunuyor
          sonuc = bolum1[sonint] + sonuc;
        } else if (w == 2) {
          // ikinci basamak
          sonuc = bolum2[sonint] + sonuc;
        } else if (w == 3) {
          // 3. basamak
          if (sonint == 1) {
            sonuc = bolum3[1] + sonuc;
          } else if (sonint > 1) {
            sonuc = bolum1[sonint] + bolum3[1] + sonuc;
          }
          uclubasamak++;
        }
        if (w > 3) {
          // 3. basamaktan sonraki işlemler
          if (uclubasamak == 1) {
            if (sonint > 0) {
              sonuc = bolum1[sonint] + bolum3[2 + artan] + sonuc;
              if (artan == 0) {
                // birbin yazmasını engelle
                if (kac - 1 == i) {
                  //
                  sonuc = sonuc.replaceAll(bolum1[1] + bolum3[2], bolum3[2]);
                }
              }
              sonaekle = 1; // sona bin eklendi
            } else {
              sonaekle = 0;
            }
            uclubasamak++;
          } else if (uclubasamak == 2) {
            if (sonint > 0) {
              if (sonaekle > 0) {
                sonuc = bolum2[sonint] + sonuc;
                sonaekle++;
              } else {
                sonuc = bolum2[sonint] + bolum3[2 + artan] + sonuc;
                sonaekle++;
              }
            }
            uclubasamak++;
          } else if (uclubasamak == 3) {
            if (sonint > 0) {
              if (sonint == 1) {
                gecici = bolum3[1];
              } else {
                gecici = bolum1[sonint] + bolum3[1];
              }
              if (sonaekle == 0) {
                gecici = gecici + bolum3[2 + artan];
              }
              sonuc = gecici + sonuc;
            }
            uclubasamak = 1;
            artan++;
          }
        }
        w++; // işlenen basamak
      }
    }

    return sonuc;
  }
}
