import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/log_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/log_service.dart';
import 'package:simandika/theme.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  _ActivityLogPageState createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  late Future<List<ActivityLogModel>> futureLogs;
  final TextEditingController _searchController = TextEditingController();

  List<ActivityLogModel> _logs = [];
  List<ActivityLogModel> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    futureLogs = ActivityLogService().getActivityLogs(token!);

    // Fetch logs and update state
    futureLogs.then((data) {
      setState(() {
        _logs = data;
        _filteredLogs = data; // Initialize the filtered logs
      });
    }).catchError((error) {
      // Handle error if any
      setState(() {
        _filteredLogs = []; // Handle empty or error state
      });
    });

    // Listen for search input changes to filter logs
    _searchController.addListener(_filterLogs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLogs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLogs = _logs.where((log) {
        final descriptionLower = log.description.toLowerCase();
        final causedByLower = log.causedBy.toLowerCase();
        return descriptionLower.contains(query) ||
            causedByLower.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Log Aktivitas User',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar for filtering
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Filtering handled by listener
              },
              decoration: InputDecoration(
                hintText: 'Search logs...',
                suffixIcon: const Icon(Icons.search),
                filled: true, // Enable filling
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Display the logs
            Expanded(
              child: FutureBuilder<List<ActivityLogModel>>(
                future: futureLogs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No logs found.'));
                  } else {
                    return ListView.builder(
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        var log = _filteredLogs[index];
                        return Card(
                          color: primaryColor,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              log.description,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              'By: ${log.causedBy}\n${log.createdAt}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              log.logName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              // Implement tap handler if needed
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
