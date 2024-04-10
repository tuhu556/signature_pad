import 'dart:convert';
import 'dart:io';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:signature_pad/overlayedSignature.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFViewerPage extends StatefulWidget {
  final String signature;
  final String filePath;
  const PDFViewerPage({
    super.key,
    required this.signature,
    required this.filePath,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage>
    with WidgetsBindingObserver {
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final pdf = pw.Document();
  double _currentScale = 1.0;
  Offset? signatureOffset;
  final pdfController = pdfx.PdfController(
    document: pdfx.PdfDocument.openAsset('assets/pdf/example.pdf'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.share,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                pdfx.PdfView(
                  controller: pdfController,
                  renderer: (page) {
                    return page.render(
                      width: page.width,
                      height: page.height,
                      format: pdfx.PdfPageImageFormat.png,
                      backgroundColor: '#FFFFFF',
                      quality: 100,
                    );
                  },
                ),
                OverlaySignature(
                  child: Image.memory(
                    base64Decode(widget.signature),
                    height: 100,
                    width: 100,
                  ),
                  onDragStart: () {},
                  onDragEnd: () {},
                  onDragUpdate: (offset) {
                    signatureOffset = offset;
                  },
                ),
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                createPDF();
                savePDF();
                // final pdf = pw.Document();
                // final Uint8List signatureBytes =
                //     base64Decode(widget.signature);
                // final signatureImage = pw.MemoryImage(signatureBytes);
                // final signatureWidget = pw.Image(signatureImage);
                // pdf.addPage(pw.Page(
                //   pageFormat: PdfPageFormat.a4,
                //   build: (context) {
                //   },
                // ));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
              ),
              child: const Text(
                "EXPORT",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  // handleSourcePDF() async {
  //   var file = pdfRender.PdfImageRendererPdf(path: 'assets/pdf/example.pdf');
  //   await file.open();
  //   int count = await file.getPageCount();
  //   List<PdfRawImage> images = [];
  // }

  createPDF() {
    final image = pw.MemoryImage(base64Decode(widget.signature));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // return pw.Center(
          //   child: pw.Image(image),
          // ); // Center
          return pw.Stack(children: [
            pw.Positioned(
                left: signatureOffset?.dx ?? 0,
                top: signatureOffset?.dy ?? 0,
                child: pw.Image(image)),
          ]);
        }));
  }

  savePDF() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir?.path}/result.pdf');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      DocumentFileSavePlus().saveMultipleFiles(
        dataList: [
          pdfBytes,
        ],
        fileNameList: [
          "example.pdf",
        ],
        mimeTypeList: [
          "example/pdf",
        ],
      );
    } catch (e) {
      print(e);
    }
  }
}
