import 'package:mcg_extension/devicemanager.dart';

import 'appbloc/appvar.dart';

const autoFillIsSuperadmin = false;

bool get isDebugAccount => isDebugMode || AppVar.appBloc.hesapBilgileri.kurumID.startsWith('demo') == true;
const int socialNetworkMaxDay = 180;
