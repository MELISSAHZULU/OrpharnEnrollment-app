import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CaseNotesScreen extends StatefulWidget {
  final int childId;
  final String childName;
  
  const CaseNotesScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);
  
  @override
  _CaseNotesScreenState createState() => _CaseNotesScreenState();
}

class _CaseNotesScreenState extends State<CaseNotesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _caseNotes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCaseNotes();
  }
  
  Future<void> _loadCaseNotes() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _caseNotes = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  void _addCaseNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        _caseNotes.insert(0, {
          'note': _noteController.text,
          'date': DateTime.now().toString(),
          'author': 'Current User',
        });
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Case note added!'), backgroundColor: Colors.green),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Case Notes - ${widget.childName}'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _caseNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No case notes yet'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _caseNotes.length,
                        itemBuilder: (context, index) {
                          final note = _caseNotes[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(Icons.note, color: Colors.green),
                              ),
                              title: Text(note['note']),
                              subtitle: Text(
                                '${note['author']} - ${DateTime.parse(note['date']).toString().split(' ')[0]}',
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Add a case note...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _addCaseNote,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}