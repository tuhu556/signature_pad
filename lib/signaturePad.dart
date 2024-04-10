import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:signature_pad/pdfViewer.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  GlobalKey viewKey = GlobalKey();
  int _radioValue = 0;
  bool _showSlider = false;
  double _penStrokeWith = 1;
  String filePath = "";

  Color _penColor = Colors.black;
  late SignatureController _controller;
  final StrokeJoin strokeJoin = StrokeJoin.miter;
  final StrokeCap strokeCap = StrokeCap.round;
  @override
  void initState() {
    super.initState();
    fromAsset('assets/pdf/example.pdf', 'example.pdf').then((f) {
      setState(() {
        filePath = f.path;
      });
    });
    _controller = SignatureController(
      penColor: _penColor,
      exportBackgroundColor: Colors.transparent,
      penStrokeWidth: _penStrokeWith,
      strokeJoin: strokeJoin,
      strokeCap: strokeCap,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleText(),
          const Divider(
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    undoButton(),
                    const SizedBox(
                      width: 10,
                    ),
                    redoButton(),
                    verticalDivider(),
                    lineButton(),
                    verticalDivider(),
                    radioBtnRow(),
                    verticalDivider(),
                    clearButton(),
                  ],
                )),
          ),
          _showSlider
              ? sliderContainer(
                  (value) => setState(() {
                    _penStrokeWith = value;
                    _controller = SignatureController(
                      penStrokeWidth: _penStrokeWith,
                      exportBackgroundColor: Colors.transparent,
                      penColor: _penColor,
                      strokeJoin: strokeJoin,
                      strokeCap: strokeCap,
                    );
                  }),
                )
              : Container(),
          signatureWidget(),
          const Divider(
            color: Colors.black,
          ),
          btnRow(),
        ],
      ),
    );
  }

  Widget titleText() {
    return const Padding(
      padding: EdgeInsets.only(top: 15, bottom: 5),
      child: Center(
        child: Text(
          "Adsasd",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  Widget signatureWidget() {
    return Signature(
      controller: _controller,
      backgroundColor: Colors.white,
      height: 350,
      width: 310,
    );
  }

  Widget btnRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              Uint8List signatureExport = (await _controller.toPngBytes())!;
              String base64 = base64Encode(signatureExport);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PDFViewerPage(
                            signature: base64,
                            filePath: filePath,
                          )));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
            child: const Text(
              "Let's go",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
          // Expanded(
          //   child:
          // ),
          // const SizedBox(
          //   width: 20,
          // ),
          // Expanded(
          //   child: DefaultButton(
          //     text: tr(LocaleKeys.signing, context: context),
          //     press: () async {
          //       if (_controller.isEmpty) {
          //         PushFlushbar(context)
          //             .notiFlushbar("Vui lòng vẽ chữ ký của bạn");
          //         return;
          //       }
          //       Uint8List signatureExport = (await _controller.toPngBytes())!;
          //       String base64 = base64Encode(signatureExport);

          //       // ignore: use_build_context_synchronously
          //       wrapperNavigator.pop(context: context, data: base64);
          //     },
          //     width: 140,
          //     backgroundColor: PrimaryColor.darkBlue100,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget sliderContainer(Function(double) onChanged) {
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    "Weight",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Slider(
                      value: _penStrokeWith,
                      activeColor: _penColor,
                      max: 8,
                      min: 1,
                      divisions: 7,
                      onChanged: onChanged),
                ),
                Expanded(
                  child: Text(
                    '${_penStrokeWith.toInt()}px',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void changeColorPen(int value) {
    switch (value) {
      case 0:
        setState(() {
          _penColor = Colors.black;
          _controller = SignatureController(
            penStrokeWidth: _penStrokeWith,
            exportBackgroundColor: Colors.transparent,
            penColor: _penColor,
            strokeJoin: strokeJoin,
            strokeCap: strokeCap,
          );
        });
        break;
      case 1:
        setState(() {
          _penColor = Colors.blue;
          _controller = SignatureController(
            penStrokeWidth: _penStrokeWith,
            exportBackgroundColor: Colors.transparent,
            penColor: _penColor,
            strokeJoin: strokeJoin,
            strokeCap: strokeCap,
          );
        });
        break;
      case 2:
        setState(() {
          _penColor = Colors.red;
          _controller = SignatureController(
            penStrokeWidth: _penStrokeWith,
            exportBackgroundColor: Colors.transparent,
            penColor: _penColor,
            strokeJoin: strokeJoin,
            strokeCap: strokeCap,
          );
        });
        break;
      default:
    }
  }

  Widget radioBtnRow() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            radioBtn(0, Colors.black, (value) {
              setState(() {
                _radioValue = value!;
                changeColorPen(_radioValue);
              });
            }),
            radioBtn(1, Colors.blue, (value) {
              setState(() {
                _radioValue = value!;
                changeColorPen(_radioValue);
              });
            }),
            radioBtn(2, Colors.red, (value) {
              setState(() {
                _radioValue = value!;
                changeColorPen(_radioValue);
              });
            }),
          ],
        );
      },
    );
  }

  Widget radioBtn(
    int value,
    Color color,
    Function(dynamic) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Radio(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity,
          ),
          fillColor: MaterialStateProperty.all(color),
          value: value,
          groupValue: _radioValue,
          onChanged: onChanged),
    );
  }

  Widget verticalDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: VerticalDivider(
        color: Colors.grey,
        thickness: 1.5,
        width: 18,
      ),
    );
  }

  Widget clearButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _controller.clear();
          });
        },
        child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: const Icon(Icons.autorenew)),
      ),
    );
  }

  Widget undoButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.undo();
        });
      },
      child: Container(
          height: 30,
          width: 30,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: const Icon(Icons.undo)),
    );
  }

  Widget redoButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.redo();
        });
      },
      child: Container(
        height: 30,
        width: 30,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: const Icon(Icons.redo),
      ),
    );
  }

  Widget lineButton() {
    return GestureDetector(
      onTap: () => setState(() {
        _showSlider = !_showSlider;
      }),
      child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              "╱",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _penColor),
            ),
          )),
    );
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }
}
