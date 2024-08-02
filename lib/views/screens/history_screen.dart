import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TarixScreen extends StatelessWidget {
  const TarixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarix"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text('${data['fromCard']} -> ${data['toCard']}'),
                subtitle: Text('Amount: ${data['amount']}'),
                trailing: Text(data['date'].toDate().toString()),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
