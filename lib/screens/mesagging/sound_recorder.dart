import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:record/record.dart';

import '../../appbloc/appvar.dart';

//! Web de gonderilen mesajlar mobilde acilmadigindan (Enocder) sorunu web kapali
class SoundRecorder extends StatelessWidget {
  final Color? iconColor;
  final Function(String)? audioUploaded;
  SoundRecorder({this.iconColor, this.audioUploaded});

  Future<void> showDialog() async {
    final _url = await Get.dialog(
        Material(
          child: _SoundRecorder(),
          color: Colors.transparent,
        ),
        barrierColor: Colors.black87,
        barrierDismissible: false,
        useSafeArea: true);

    if (_url is String) {
      audioUploaded!(_url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icons.mic.icon.color(iconColor!).onPressed(showDialog).padding(6).make();
  }
}

class _SoundRecorder extends StatefulWidget {
  _SoundRecorder();
  @override
  __SoundRecorderState createState() => __SoundRecorderState();
}

class __SoundRecorderState extends State<_SoundRecorder> {
  bool _isRecording = false;
  // ignore: unused_field
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;

  final Record _audioRecorder = Record();

  bool _isSending = false;

  String? _path;
  final player = AudioPlayer();
  @override
  void initState() {
    PermissionManager.microphone();

    Future.microtask(() {
      _start();
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    //  _ampTimer?.cancel();
    _audioRecorder.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: [
                32.widthBox,
                ClipOval(
                  child: Material(
                    color: Colors.red.withOpacity(0.1),
                    child: InkWell(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icons.cancel.icon.color(Colors.red).make(),
                      ),
                      onTap: () async {
                        if (_isRecording) await _stop();
                        Get.back();
                      },
                    ),
                  ),
                ),
                16.widthBox,
                Expanded(child: Center(child: _buildTimer())),
                16.widthBox,
                ClipOval(
                  child: Material(
                    color: Colors.blue.withOpacity(0.1),
                    child: InkWell(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icons.hearing_rounded.icon.color(Colors.blue).make(),
                      ),
                      onTap: () async {
                        if (_isRecording) await _stop();

                        player.onPositionChanged.listen((Duration d) {
                          if (mounted) setState(() => _recordDuration = d.inSeconds);
                        });
                        await player.play(DeviceFileSource(_path!));
                      },
                    ),
                  ),
                ),
                16.widthBox,
                ClipOval(
                  child: Material(
                    color: Colors.green.withOpacity(0.1),
                    child: InkWell(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: _isSending
                            ? MyProgressIndicator(
                                isCentered: true,
                                color: Colors.green,
                                size: 24,
                              )
                            : Icons.send.icon.color(Colors.green).make(),
                      ),
                      onTap: _send,
                    ),
                  ),
                ),
                32.widthBox,
              ],
            ),
            (MediaQuery.of(context).padding.bottom + 8).heightBox,
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     _buildRecordStopControl(),
            //     const SizedBox(width: 20),
            //     _buildPauseResumeControl(),
            //     const SizedBox(width: 20),
            //     _buildText(),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (Fav.noConnection()) return;
    if (_isSending) return;
    if (_isRecording) await _stop();
    final _targetPath = "aa_MF" + '/' + DateTime.now().dateFormat("yyyy-MM") + '/' + 'Aud' + '/' + AppVar.appBloc.hesapBilgileri.kurumID;

    setState(() {
      _isSending = true;
    });
    if (!isWeb) {
      Uint8List _source;
      try {
        final _file = File(_path!);
        _source = _file.readAsBytesSync();
      } catch (e) {
        final _file = File.fromUri(Uri.file(_path!));
        _source = _file.readAsBytesSync();
      }

      final _fileName = '${6.makeKey}.m4a';

      final _url = await Storage().uploadBytes(MyFile(mobilePath: _path, byteData: _source, name: _fileName), _targetPath, _fileName, dataImportance: DataImportance.medium, progressWidget: false);
      Get.back(result: _url);
    } else {
      final _fileName = '${6.makeKey}.m4a';
      final _source = await DownloadManager.downloadWithHttp(_path!);
      final _url = await Storage().uploadBytes(MyFile(byteData: _source, name: _fileName), _targetPath, _fileName, dataImportance: DataImportance.medium, progressWidget: false);
      Get.back(result: _url);
    }
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  String _formatNumber(int number) => number.toString().padLeft(2, '0');

  Future<void> _start() async {
    _path = isWeb ? 'audio.m4a' : (await path_provider.getTemporaryDirectory()).path + '/audio.m4a';
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(path: _path, encoder: !isWeb ? AudioEncoder.aacLc : AudioEncoder.pcm16bit);

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      log(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();

    _path = await _audioRecorder.stop();

    setState(() => _isRecording = false);
  }

  // ignore: unused_element
  Future<void> _pause() async {
    _timer?.cancel();
    //  _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  // ignore: unused_element
  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) setState(() => _recordDuration++);
      if (_recordDuration > 120) _stop();
    });
  }
}
