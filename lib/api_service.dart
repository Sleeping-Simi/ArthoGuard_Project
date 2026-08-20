// Import the service at the top of your screen file
import 'api_service.dart';
import 'package:image_picker/image_picker.dart';

// Inside your Stateful Widget...

XFile? selectedPrescription;
XFile? selectedXray;

// Example function to call when the user clicks 'Submit'
void _submitForm() async {
  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  // Call our backend
  bool success = await ApiService.submitPatientProfile(
    patientName: "Aditya Naskar", // Replace with your text controller values
    age: 25,                      // e.g., int.parse(ageController.text)
    gender: "Male",               // Remember the backend expects lowercase 'male'
    weight: 70.5,
    height: 175.0,
    bmi: 23.0,
    painLevel: 5,                 // From your slider
    totalDuration: "1-2 years",   // From dropdown
    painTiming: "Morning",        // From dropdown
    avgPainDuration: 45,
    arthritisType: "Osteoarthritis", 
    prescriptionImage: selectedPrescription,
    xrayImage: selectedXray,
  );

  // Close loading indicator
  Navigator.pop(context);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Saved Successfully!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save profile. Check console.')),
    );
  }
}