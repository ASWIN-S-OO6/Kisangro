import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Uint8List
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // NEW: Import the PDF viewer

class DocumentViewerScreen extends StatelessWidget {
  final Uint8List? documentBytes;
  final bool isImage;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.documentBytes,
    required this.isImage,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: documentBytes != null
            ? (isImage
            ? InteractiveViewer( // Allows zooming and panning for images
          child: Image.memory(
            documentBytes!,
            fit: BoxFit.contain, // Ensure image scales to fit
          ),
        )
            : // NEW: PDF Viewer integration
        SfPdfViewer.memory(
          documentBytes!,
          // You can add various properties here to control the viewer:
          // pageSpacing: 8,
          // enableDoubleTapZooming: true,
          // enableHyperlinkNavigation: true,
          // initialZoomLevel: 1.0,
          // controller: PdfViewerController(), // If you need programmatic control
          // onDocumentLoadFailed: (details) {
          //   print('PDF load failed: ${details.description}');
          //   // Optionally show an error message to the user
          // },
          // onDocumentLoaded: (details) {
          //   print('PDF loaded successfully!');
          // },
        )
        )
            : Column( // Display if no document is available
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.grey[400],
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'No document available',
              style: GoogleFonts.poppins(
                  fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
