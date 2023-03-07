//import 'package:elseifekol/appbloc/appvar.dart';
//import 'package:flutter/material.dart';
//
//import 'package:mypackage/mywidgets.dart';
//import 'package:mcg_extension/mcg_extension.dart';
//
//class TermOfUse extends StatelessWidget {
//  final String invoiceNumber;
//  TermOfUse({this.invoiceNumber});
//
//  @override
//  Widget build(BuildContext context) {
//    if (invoiceNumber == '100') {
//      return Invoice100TermOfUse();
//    }
//    return   Scaffold();
//  }
//}
//
//class Invoice100TermOfUse extends StatelessWidget  {
//  Invoice100TermOfUse();
//
//  @override
//  Widget build(BuildContext context) {
//    return   MyScaffold(
//        appBar: MyAppBar(
//          visibleBackButton: true,
//          title: 'Üyelik (Abonelik) Sözleşmesi:',
//        ),
//        body: SingleChildScrollView(
//          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Text(
//                'Madde-1: Taraflar',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Eser Akademi & Golden Bilişim Yazılım Medya',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 16, decoration: TextDecoration.underline),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Unvan',
//                value: 'Eser Akademi - İş Güvenliği Uzmanlığı Eğitimi ve Kursu',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Adres',
//                value: 'Ceyhun Atuf Kansu Cad. Gözde Plaza No : 130/62 Balgat Çankaya / ANKARA',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Telefon',
//                value: '0850 346 58 29 - 0533 400 19 39',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'E-posta',
//                value: 'bilgi@eserakademi.com',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Bundan sonra ESER AKADEMİ olarak anılacaktır.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Unvan',
//                value: 'Golden Bilişim Yazılım Medya Ltd. Şti.',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Adres',
//                value: 'Ostim Teknik Üniversitesi, Teknoloji Geliştirme Bölgesi Osb Mh. Cevat Dündar Cd. No:1/1/48 Yenimahalle / ANKARA',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Telefon',
//                value: '0552 951 43 30',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'E-posta',
//                value: 'goldenyazilim@gmail.com',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Bundan sonra Golden Bilişim olarak anılacaktır.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Abone:',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 16, decoration: TextDecoration.underline),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Ad Soyad / Unvan',
//                value: '',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Adres',
//                value: '',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'Telefon',
//                value: '',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'E-posta',
//                value: '',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Bundan sonra ABONE olarak anılacaktır.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-2: Sözleşme Konusu',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'İşbu sözleşmenin konusu, ABONE’nin Eser Akademi ve Golden Bilişim Firmasına ait eğitim destek içeriklerinin yer aldığı online mobil uygulamalarına elektronik ortamda yaptığı abonelik başvurusunun kapsamı, süresi, abonelik ücreti, dahil tüm temel özellikleri ile ilgili olarak yürürlükteki Tüketicilerin Koruması Hakkındaki Kanun ve Abonelik Sözleşmeleri Yönetmeliği hükümleri gereğince tarafların hak ve yükümlülüklerinin saptanmasıdır.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-3: Abonelik Kapsamı',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'İSG Hazırlık aboneliği, Eser Akademi ve Golden Bilişim Firmasının fikri ve sınai mülkiyeti hakkına sahip olduğu, İşyeri Hekimliği sınavları, İSG sınavları ve İSG eğitim kurumlarına ait eğitim destek içeriğinin kullanıcı haklarını kapsar. Bu kullanma hakkı, ABONE tarafından seçilmiş olan erişim paketinin sağladığı kullanma biçimi ile sınırlıdır.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-4: Abonelik Süresince Sağlanacak Hizmetler',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'ABONE tarafından seçilmiş olan erişim paketinde;',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              MyKeyValueText(
//                textKey: '🔘',
//                value: 'Konu tarama testleri, tema-ünite sınavları,',
//                fontSize: 14,
//              ),
//              MyKeyValueText(
//                textKey: '🔘',
//                value: 'Ara değerlendirme ve genel değerlendirme sınavları,',
//                fontSize: 14,
//              ),
//              MyKeyValueText(
//                textKey: '🔘',
//                value: 'Ölçme değerlendirme ve raporlama,',
//                fontSize: 14,
//              ),
//              MyKeyValueText(
//                textKey: '🔘',
//                value: 'Elektronik kitaplar yer almaktadır.',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-5: Abonelik Ücreti Ödeme Şekli',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''İSG Hazırlık abonelik ücreti ödemesi internet üzerinden kredi kartı ile, banka, PTT havalesi / EFT ile satın alınarak yapılabilir.\n\nKredi Kartı
//      \nİnternet üzerinden kredi kartı ile İSG Hazırlık’a hemen ABONE olunabilir. Kredi kartı işlemleri güvenli ve şifreli bir kanal üzerinden doğrudan bankaya iletilir ve tüm işlemler banka tarafından yapılır.
//      \nKredi kartı ile abonelik satın alan ABONE, sözleşme kurulduktan sonra abonelik sözleşmesinin sonraki yıllar için uzatılmasını isteyebilir. Sözleşme kurulduktan sonraki aşamada ABONE, kurulmuş olan abonelik sözleşmesinin izleyen yıllar için de geçerli olmak üzere uzatılmasını isterse abonelik sözleşmesi kendiliğinden 1 (Bir) yıl için, o an geçerli olan abonelik ücreti kredi kartından tahsil edilerek var olan sözleşme koşullarıyla yenilenir. Bu hüküm devam eden yıllar için de geçerlidir. ABONE, sözleşme bitim tarihinden önce yazılı olarak sözleşmeyi yenilemek istemediğini Eser Akademi ve Golden Bilişim Firmasına bildirme hakkına sahiptir.
//      \nBanka, PTT Havalesi / EFT
//      \nAbonelik ücreti, belirtilen banka, PTT hesap numaralarına havale / EFT yapılarak ödenebilir. Ödeme dekontu Eser Akademi ve Golden Bilişim Firması Çağrı Merkezi’ne ulaştırıldığında ABONEye elektronik ortamda aktivasyon kodu gönderilerek abonelik başlatılır.
//\nŞifreli Üyelik Kartı
//\nŞifreli Üyelik Kartı, yetkili eğitim danışmanlarından, bayilerden ve üye eğitim kurumlarından temin edilebilir. Üyelik kartının arkasında yer alan “Aktivasyon Kodu” kullanılarak abonelik başlatılır.
//''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-6: Tarafların Hak Ve Yükümlülükleri',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''6.1. ABONE, İSG hazırlık uygulamasına abone olurken verdiği bilgilerin gerçeği yansıttığını, Eser Akademi ve Golden Bilişim Firması’nın bu bilgilerin gerçeğe aykırılığı nedeniyle zararının doğması hâlinde uğrayacağı tüm zararları aynen ve derhal tazmin edeceğini beyan ve taahhüt eder.
//
//6.2. ABONE, uygulamaya girerken “kullanıcı adı” ve abone olurken oluşturduğu “şifre”sini kullanmalıdır. ABONE, şifresini başka kişi ya da kuruluşlara veremez. ABONE’nin söz konusu şifreyi kullanma hakkı bizzat kendisine aittir. Bu kullanma hakkı, seçmiş olduğu erişim paketinin sağladığı kullanma biçimi ile sınırlı olup, üçüncü kişilere bedelli-bedelsiz kiralanamaz, satılamaz. Bu sebeple doğabilecek tüm sorumluluk ABONE’ye aittir. Eser Akademi ve Golden Bilişim Firması’nın ABONEnin söz konusu izinsiz kullanımdan kaynaklanan her türlü tazminat vesair talep hakkı saklıdır.
//
//6.3. ABONE, Eser Akademi ve Golden Bilişim Firması mobil uygulaması ve internet sitesini hiçbir şekilde kamu düzenini bozucu, genel ahlaka ve kişilik haklarına aykırı, başkalarını/üyeleri rahatsız ve taciz edici şekilde, yasalara aykırı bir amaç için, başkalarının fikri ve telif haklarına tecavüz edecek şekilde kullanamaz, içerik veya mesaj gönderemez. Ayrıca, ABONE başkalarının hizmetleri kullanmasını önleyici veya zorlaştırıcı faaliyet (spam, virus vb.) ve işlemlerde bulunamaz. Böyle durumlarda her türlü hukuki, cezai, idari ve mali sorumluluk ABONE’ye/üyeye aittir.
//
//6.4. Eser Akademi ve Golden Bilişim Firması almış olduğu tüm idari ve teknik tedbirlere rağmen, abone verilerinin yetkili olmayan kişilerce okunması ve abone yazılım ve verilerine gelebilecek Eser Akademi ve Golden Bilişim Firması’nın hafif kusuru sebebiyle ortaya çıkan zararlardan dolayı sorumlu olmayacaktır. Abone, İSG hazırlık uygulamasının kullanılmasından dolayı uğrayabileceği Eser Akademi ve Golden Bilişim Firması’nın sadece hafif kusuru sebebiyle meydana gelebilecek zararlar yüzünden Eser Akademi ve Golden Bilişim Firması’ndan tazminat talep etmemeyi peşinen kabul etmiştir.
//
//6.5. Eser Akademi ve Golden Bilişim Firması, uygulamanın içeriğini dilediği zaman değiştirme, kullanıcılara sağlanan herhangi bir hizmeti değiştirme ya da sona erdirme hakkını saklı tutar.
//
//6.6. Eser Akademi ve Golden Bilişim Firması, bu sözleşme kapsamında verilecek hizmetlerle ilgili olarak hafif kusuru sebebiyle ortaya çıkan teknik arıza ya da sorun nedeni ile işlemlerin tamamlanamaması, iptal edilmesi hâlinde sorumlu olmayacaktır. Sağlanan hizmet ile ilgili olarak, resmi kurumların kararlarıyla veya yasal uygulamalar veya hukuki teknik sorunlar, zorunluluklar nedeniyle hizmetin kesintiye uğraması, durdurulması gibi haller mücbir sebep olarak kabul edilmiş olup, bu gibi hallerde Eser Akademi ve Golden Bilişim Firması'nın sorumluluğu doğmayacaktır.
//
//6.7. Eser Akademi ve Golden Bilişim Firması, Ticari İletişim ve Ticari Elektronik İletiler Hakkında Yönetmelik madde 6/2 çerçevesinde ve işbu abonelik sözleşmesi uyarınca ABONE’lerinin kendisinde kayıtlı elektronik posta adreslerine bilgilendirme mailleri ve cep telefonlarına bilgilendirme SMS’leri gönderme yetkisine sahiptir.
//
//6.8. Taraflar, Eser Akademi ve Golden Bilişim Firmasına ait tüm bilgisayar kayıtlarının, muteber, bağlayıcı, kesin ve münhasır delil olarak Hukuk Muhakemeleri Kanunu’nun 193. maddesine uygun şekilde esas alınacağını ve söz konusu kayıtların bir delil sözleşmesi teşkil ettiği hususunu kabul ve beyan eder.
//
//6.9. ABONE, www.goldenyazilim.net sitesinde yer alan tüm ürün ve hizmetlerin, bilgilerin, görsel ve işitsel unsurların, elektronik materyallerin telif hakkının Golden Bilişim Yazılım Medya Ltd. Şti’ye ve Eser Akademiye ait olduğunu kabul ve beyan eder. Mobil uygulama içerisinde yer alan hiç bir içeriği, dosyayı, görsel ve işitsel unsuru, elektronik materyali, bilgiyi, tüm ürün ve hizmetleri kopyalamayacağını, çoğaltmayacağını, aktarmayacağını, değiştirmeyeceğini, uyarlamayacağını, çevirmeyeceğini, kaynak koduna dönüştürmeyeceğini, tersine mühendislik uygulamayacağını, parçalarına ayırmayacağını, ticari bir amaçla kullanmayacağını kabul etmektedir. Aksi takdirde 5846 sayılı FSEK hükümleri çerçevesinde hakkında yasal işlemlere başlanacağını kabul eder.''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-7: Cayma Hakkı',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'ABONE’nin hiçbir hukuki ve cezai sorumluluk üstlenmeksizin ve hiçbir gerekçe göstermeksizin sözleşmenin imzalandığı tarihten itibaren 14 (on dört) gün içerisinde satın aldığı hizmeti reddederek sözleşmeden cayma hakkı vardır. Cayma bildiriminin e-posta, posta ve benzeri bir yolla Eser Akademi ve Golden Bilişim Firmasına ulaşmasından itibaren abonelik iptal edilir ve ödenen abonelik ücreti yedi gün içinde bildirilen banka hesabına iade edilir. Cayma bildirimi aşağıdaki adreslerden birine iletilebilir.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Cayma Bildirimi',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              MyKeyValueText(
//                textKey: 'E-posta',
//                value: 'goldenyazilim@gmail.com',
//                fontSize: 14,
//              ),
//              MyKeyValueText(
//                textKey: 'Posta Adresi',
//                value: 'Ostim Teknik Üniversitesi, Teknoloji Geliştirme Bölgesi Osb Mh. Cevat Dündar Cd. No:1/1/48 Yenimahalle / ANKARA',
//                fontSize: 14,
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-8: Sözleşmenin Feshi',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Eser Akademi ve Golden Bilişim Firması, ABONE’nin şifresini sözleşme hükümlerine aykırı olarak kullandığı, hizmetten hatalı, yasalara ve dürüstlük kurallarına aykırı olarak istifade ettiği ve işbu sözleşme konusu yükümlülüklerine aykırı davrandığı kanaatine varırsa sebep göstermeksizin ve ihbarda bulunmaksızın ABONE’nin aboneliğini iptal ederek sözleşmeyi tek taraflı feshedebilir. ABONE, bu hususları kabul ettiğini ve aboneliğin bu şekilde sona erdirilmesinden dolayı Eser Akademi ve Golden Bilişim Firmasın’dan her ne ad altında olursa olsun herhangi bir tazminat vesair talepte bulunmayacağını kabul ve taahhüt eder.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-9: Uyuşmazlıkların Çözümü',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'ABONE, şikâyet ve itirazları konusunda başvurularını Gümrük ve Ticaret Bakanlığı tarafından her yıl aralık ayında belirlenen parasal sınırlar dâhilinde mal veya hizmeti satın aldığı veya ikametgâhının bulunduğu yerdeki Tüketici Hakem Heyetine veya Tüketici Mahkemesine yapabilir.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-10: Yürürlük',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'ABONE’nin, abonelik kaydı yapması, işbu abonelik sözleşmesinde yer alan tüm maddeleri okuduğu ve kabul ettiği anlamına gelir. İşbu sözleşme ABONE’nin abone olması anında elektronik ortamda akdedilmiş ve karşılıklı olarak yürürlüğe girmiştir.İşbu sözleşme abonelik süresinin hitamı, ABONE’nin aboneliğini iptal etmesi veya Eser Akademi ve Golden Bilişim Firması tarafından aboneliğinin iptal edilmesine kadar yürürlükte kalacaktır.',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-11:',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              GestureDetector(
//                  onTap: () async {
//                    'https://www.iyzico.com/gizlilik-politikasi/'.launch(context, LaunchType.URL);
//                  },
//                  child: RichText(
//                    text: TextSpan(style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 16, fontWeight: FontWeight.normal), children: [
//                      TextSpan(text: 'ABONE, ödeme yöntemine, üyeliğine ve siparişine ilişkin bilgilerin, ödemenin gerçekleştirilebilmesi ve ödeme usulsüzlüklerinin önlenmesi, araştırılması ve tespit edilmesini temin amacıyla iyzico Ödeme Hizmetleri A.Ş.’ye aktarılmasına ve iyzico tarafından '),
//                      TextSpan(text: 'https://www.iyzico.com/gizlilik-politikasi/', style: TextStyle(color: Colors.blue)),
//                      TextSpan(text: ' adresindeki Gizlilik Politikası’nın en güncel halinde açıklandığı şekilde işlenmesine ve saklanmasına rıza göstermektedir.'),
//                    ]),
//                  )),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-12: Gizlilik Politikası',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'GİZLİLİK VE GÜVENLİK POLİTİKASI',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''Uygulama mağazamızda hizmete sunulan tüm ürünler, Ostim Teknik Üniversitesi, Teknoloji Geliştirme Bölgesi Osb Mh. Cevat Dündar Cd. No:1/1/48 Yenimahalle - ANKARA adresinde kayıtlı Golden Bilişim Yazılım Medya Ltd. Şti. firmamıza aittir ve firmamız tarafından işletilir. Firmamız, çeşitli amaçlarla kişisel veriler toplayabilir. Aşağıda, toplanan kişisel verilerin nasıl ve ne şekilde toplandığı, bu verilerin nasıl ve ne şekilde korunduğu belirtilmiştir. Üyelik veya uygulamamız üzerindeki bilgilerin doldurulması suretiyle üyelerin kendileriyle ilgili bir takım kişisel bilgileri (isim-soy isim, firma bilgileri, telefon, adres veya e-posta adresleri gibi) uygulama mağazamız tarafından işin doğası gereği toplanmaktadır.
//Firmamız bazı dönemlerde müşterilerine ve üyelerine kampanya bilgileri, yeni ürünler hakkında bilgiler, promosyon teklifleri gönderebilir. Üyelerimiz bu gibi bilgileri alıp almama konusunda her türlü seçimi üye olurken yapabilir, sonrasında üye girişi yaptıktan sonra hesap bilgileri bölümünden bu seçimi değiştirilebilir ya da kendisine gelen bilgilendirme iletisindeki linkle bildirim yapabilir.
//Mağazamız üzerinden veya eposta ile gerçekleştirilen onay sürecinde, üyelerimiz tarafından mağazamıza elektronik ortamdan iletilen kişisel bilgiler, Üyelerimiz ile yaptığımız "Kullanıcı Sözleşmesi" ile belirlenen amaçlar ve kapsam dışında üçüncü kişilere açıklanmayacaktır.
//Firmamız, gizli bilgileri kesinlikle özel ve gizli tutmayı, bunu bir sır saklama yükümü olarak addetmeyi ve gizliliğin sağlanması ve sürdürülmesi, gizli bilginin tamamının veya herhangi bir kısmının kamu alanına girmesini veya yetkisiz kullanımını veya üçüncü bir kişiye ifşasını önlemek için gerekli tüm tedbirleri almayı ve gerekli özeni göstermeyi taahhüt etmektedir.
//  ''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'KREDİ KARTI GÜVENLİĞİ',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''Firmamız, uygulama mağazamızdan alışveriş yapan kredi kartı sahiplerinin güvenliğini ilk planda tutmaktadır. Kredi kartı bilgileriniz hiçbir şekilde sistemimizde saklanmamaktadır.
//İşlemler sürecine girdiğinizde güvenli bir sitede olduğunuzu anlamak için dikkat etmeniz gereken iki şey vardır. Bunlardan biri tarayıcınızın en alt satırında bulunan bir anahtar ya da kilit simgesidir. Bu güvenli bir internet sayfasında olduğunuzu gösterir ve her türlü bilgileriniz şifrelenerek korunur. Bu bilgiler, ancak satış işlemleri sürecine bağlı olarak ve verdiğiniz talimat istikametinde kullanılır. Alışveriş sırasında kullanılan kredi kartı ile ilgili bilgiler alışveriş sitelerimizden bağımsız olarak 128 bit SSL (Secure Sockets Layer) protokolü ile şifrelenip sorgulanmak üzere ilgili bankaya ulaştırılır. Kartın kullanılabilirliği onaylandığı takdirde alışverişe devam edilir. Kartla ilgili hiçbir bilgi tarafımızdan görüntülenemediğinden ve kaydedilmediğinden, üçüncü şahısların herhangi bir koşulda bu bilgileri ele geçirmesi engellenmiş olur.
//Online olarak kredi kartı ile verilen siparişlerin ödeme/fatura/teslimat adresi bilgilerinin güvenilirliği firmamiz tarafından Kredi Kartları Dolandırıcılığı'na karşı denetlenmektedir. Bu yüzden, alışveriş sitelerimizden ilk defa sipariş veren müşterilerin siparişlerinin tedarik ve teslimat aşamasına gelebilmesi için öncelikle finansal ve adres/telefon bilgilerinin doğruluğunun onaylanması gereklidir. Bu bilgilerin kontrolü için gerekirse kredi kartı sahibi müşteri ile veya ilgili banka ile irtibata geçilmektedir.
//Üye olurken verdiğiniz tüm bilgilere sadece siz ulaşabilir ve siz değiştirebilirsiniz. Üye giriş bilgilerinizi güvenli koruduğunuz takdirde başkalarının sizinle ilgili bilgilere ulaşması ve bunları değiştirmesi mümkün değildir. Bu amaçla, üyelik işlemleri sırasında 128 bit SSL güvenlik alanı içinde hareket edilir. Bu sistem kırılması mümkün olmayan bir uluslararası bir şifreleme standardıdır.
//Bilgi hattı veya müşteri hizmetleri servisi bulunan ve açık adres ve telefon bilgilerinin belirtildiği İnternet alışveriş siteleri günümüzde daha fazla tercih edilmektedir. Bu sayede aklınıza takılan bütün konular hakkında detaylı bilgi alabilir, online alışveriş hizmeti sağlayan firmanın güvenirliği konusunda daha sağlıklı bilgi edinebilirsiniz.
//Not: İnternet alışveriş sitelerinde firmanın açık adresinin ve telefonun yer almasına dikkat edilmesini tavsiye ediyoruz. Alışveriş yapacaksanız alışverişinizi yapmadan ürünü aldığınız mağazanın bütün telefon / adres bilgilerini not edin. Eğer güvenmiyorsanız alışverişten önce telefon ederek teyit edin. Firmamıza ait tüm online alışveriş sitelerimizde firmamıza dair tüm bilgiler ve firma yeri belirtilmiştir.
//''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'İSTİSNAİ HALLER',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''Aşağıda belirtilen sınırlı hallerde Firmamız, işbu "Gizlilik Politikası" hükümleri dışında kullanıcılara ait bilgileri üçüncü kişilere açıklayabilir. Bu durumlar sınırlı sayıda olmak üzere;
//1.Kanun, Kanun Hükmünde Kararname, Yönetmelik v.b. yetkili hukuki otorite tarafından çıkarılan ve yürürlülükte olan hukuk kurallarının getirdiği zorunluluklara uymak;
//2.Mağazamızın kullanıcılarla akdettiği "Üyelik Sözleşmesi"'nin ve diğer sözleşmelerin gereklerini yerine getirmek ve bunları uygulamaya koymak amacıyla;
//3.Yetkili idari ve adli otorite tarafından usulüne göre yürütülen bir araştırma veya soruşturmanın yürütümü amacıyla kullanıcılarla ilgili bilgi talep edilmesi;
//4.Kullanıcıların hakları veya güvenliklerini korumak için bilgi vermenin gerekli olduğu hallerdir.
//''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'E-POSTA GÜVENLİĞİ',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''Mağazamızın Müşteri Hizmetleri’ne, herhangi bir siparişinizle ilgili olarak göndereceğiniz e-postalarda, asla kredi kartı numaranızı veya şifrelerinizi yazmayınız. E-postalarda yer alan bilgiler üçüncü şahıslar tarafından görülebilir. Firmamız e-postalarınızdan aktarılan bilgilerin güvenliğini hiçbir koşulda garanti edemez.''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'TARAYICI ÇEREZLERİ',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''Firmamız, mağazamızı ziyaret eden kullanıcılar ve kullanıcıların web sitesini kullanımı hakkındaki bilgileri teknik bir iletişim dosyası (Çerez-Cookie) kullanarak elde edebilir. Bahsi geçen teknik iletişim dosyaları, ana bellekte saklanmak üzere bir internet sitesinin kullanıcının tarayıcısına (browser) gönderdiği küçük metin dosyalarıdır. Teknik iletişim dosyası site hakkında durum ve tercihleri saklayarak İnternet'in kullanımını kolaylaştırır.
//Teknik iletişim dosyası, siteyi kaç kişinin ziyaret ettiğini, bir kişinin siteyi hangi amaçla, kaç kez ziyaret ettiğini ve ne kadar sitede kaldıkları hakkında istatistiksel bilgileri elde etmeye ve kullanıcılar için özel tasarlanmış kullanıcı sayfalarından dinamik olarak reklam ve içerik üretilmesine yardımcı olur. Teknik iletişim dosyası, ana bellekte veya e-postanızdan veri veya başkaca herhangi bir kişisel bilgi almak için tasarlanmamıştır. Tarayıcıların pek çoğu başta teknik iletişim dosyasını kabul eder biçimde tasarlanmıştır ancak kullanıcılar dilerse teknik iletişim dosyasının gelmemesi veya teknik iletişim dosyasının gönderildiğinde uyarı verilmesini sağlayacak biçimde ayarları değiştirebilirler.
//Firmamız, işbu "Gizlilik Politikası" hükümlerini dilediği zaman sitede yayınlamak veya kullanıcılara elektronik posta göndermek veya sitesinde yayınlamak suretiyle değiştirebilir. Gizlilik Politikası hükümleri değiştiği takdirde, yayınlandığı tarihte yürürlük kazanır.
//Gizlilik politikamız ile ilgili her türlü soru ve önerileriniz için goldenyazilim@gmail.com adresine email gönderebilirsiniz. Firmamız’a ait aşağıdaki iletişim bilgilerinden ulaşabilirsiniz.
//''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Divider(),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                'Madde-13: Hakkımızda',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''İSG Hazırlık soru bankası uygulaması Golden Bilişim Yazılım Medya Ltd. Şti. markası olup İş Yeri Hekimliği ve İş Güvenliği Uzmanlığı Sınavına hazırlanan öğrenciler için hazırlanmış dijital eğitim platformudur. İSG Sınavlarına hazırlayan eğitim kurumlarında da kullanılabilen uygulama sayesinde İSG sınavlarına hazırlanmak artık çok kolay. Özgün yazılımı ve tasarımı sayesinde pek çok kitabı ve binlerce soruyu tabletinize ya da cep telefonlarınıza taşıyor, İSG eğitimini hızlı, eğlenceli ve pratik hale getiriyoruz. Çözemediğiniz veya çözdüğünüz halde emin olamadığınız soruların cevaplarına video veya yazılı olarak uygulama içerisinden ulaşabilirsiniz.
//Sektördeki 10 yılı aşkın deneyimini yenilikçi bir anlayışla birleştiren Golden Bilişim Yazılım uygulamaları yeni ve yenilikçi geliştirmelere devam edecektir.
//''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//              Text(
//                'Madde-13: İletşim',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Text(
//                '''Firma Ünvanı:  Golden Bilişim Yazılım Medya Ltd. Şti.
//Adres: Ostim Teknik Üniversitesi, Teknoloji Geliştirme Bölgesi Osb Mh. Cevat Dündar Cd. No:1/1/48 Yenimahalle - ANKARA
//Eposta: goldenyazilim@gmail.com
//Tel: 0552 951 43 30
//Fax: --- --- -- --
//''',
//                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14, fontWeight: FontWeight.normal),
//              ),
//            ],
//          ),
//        ));
//  }
//}
