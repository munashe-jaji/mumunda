import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exhibitor_details_screen.dart';

class ExhibitorsScreen extends StatelessWidget {
  const ExhibitorsScreen({super.key});
  static String id = 'exhibitors_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibitors'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'exhibitor')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exhibitors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: exhibitors.length,
            itemBuilder: (context, index) {
              final exhibitorDoc = exhibitors[index];
              final exhibitor = exhibitorDoc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      exhibitor['name']?.substring(0, 1) ?? 'N',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    exhibitor['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(exhibitor['email'] ?? 'No Email'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExhibitorDetailsScreen(
                          exhibitorId: exhibitorDoc.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
