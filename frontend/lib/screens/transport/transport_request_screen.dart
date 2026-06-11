import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TransportRequestScreen extends StatefulWidget {
  final int? childId;
  final String? childName;
  
  const TransportRequestScreen({Key? key, this.childId, this.childName}) : super(key: key);
  
  @override
  _TransportRequestScreenState createState() => _TransportRequestScreenState();
}

class _TransportRequestScreenState extends State<TransportRequestScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Transport'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.childName != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Child: ${widget.childName}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _pickupController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  hintText: 'Enter current location of the child',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter pickup location' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Orphanage or hospital name',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter destination' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'Any special requirements or additional information',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSubmitting 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Transport Request', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),
              Text(
                'Note: Transport request will be reviewed by orphanage staff',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        final transportData = {
          'pickup_location': _pickupController.text,
          'destination': _destinationController.text,
          'notes': _notesController.text,
        };
        
        if (widget.childId != null) {
          await _apiService.requestTransport(widget.childId!, transportData);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transport request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}