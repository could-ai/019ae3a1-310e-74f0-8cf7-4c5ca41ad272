import 'package:image_picker/image_picker.dart';

class OcrService {
  // Mock delay to simulate network request
  Future<String> extractLabels(List<XFile> images) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock CSV response based on the number of images
    // In a real app, this would upload images to the backend API
    
    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('filename,label,confidence,date_processed');
    
    for (var image in images) {
      final name = image.name;
      // Generate some mock data
      csvBuffer.writeln('$name,INVOICE,0.98,2023-10-27');
      csvBuffer.writeln('$name,TOTAL_AMOUNT,0.95,2023-10-27');
    }
    
    return csvBuffer.toString();
  }
}
