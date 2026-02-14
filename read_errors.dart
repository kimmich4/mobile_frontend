
import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('analysis_v3.txt');
  if (await file.exists()) {
    try {
      // Try UTF-8 first
      final lines = await file.readAsLines();
      printErrors(lines);
    } catch (e) {
      print('Failed with default encoding, trying Latin1...');
       try {
        final bytes = await file.readAsBytes();
        final content = latin1.decode(bytes);
        printErrors(content.split('\n'));
      } catch (e2) {
         print('Failed with Latin1, trying UTF-16LE...');
         // Simple heuristic for UTF-16LE: remove null bytes from analysis output which is often UTF-16 on Windows PowerShell redirection
         final bytes = await file.readAsBytes();
         final content = String.fromCharCodes(bytes.where((b) => b != 0));
         printErrors(content.split('\n'));
      }
    }
  } else {
    print('File not found');
  }
}

void printErrors(List<String> lines) {
  for (var line in lines) {
    if (line.toLowerCase().contains('error')) {
      print(line);
    }
  }
}
