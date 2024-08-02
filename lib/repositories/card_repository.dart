import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_bank/models/card_model.dart';

class CardRepository {
  final CollectionReference _cardCollection =
      FirebaseFirestore.instance.collection('cards');

  Future<void> addCard(CardModel card) async {
    await _cardCollection.add(card.toMap());
  }

  Future<List<CardModel>> fetchCards() async {
    QuerySnapshot querySnapshot = await _cardCollection.get();
    return querySnapshot.docs
        .map((doc) => CardModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateCardBalance(String cardNumber, String newBalance) async {
    QuerySnapshot querySnapshot =
        await _cardCollection.where('cardNumber', isEqualTo: cardNumber).get();
    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      await _cardCollection.doc(docId).update({'balance': newBalance});
    }
  }

  Future<void> deleteCard(String cardNumber) async {
    QuerySnapshot querySnapshot =
        await _cardCollection.where('cardNumber', isEqualTo: cardNumber).get();
    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      await _cardCollection.doc(docId).delete();
    }
  }

  Future<void> addTransaction(
      String fromCard, String toCard, String amount, DateTime date) async {
    await FirebaseFirestore.instance.collection('transactions').add({
      'fromCard': fromCard,
      'toCard': toCard,
      'amount': amount,
      'date': date,
    });
  }
}
