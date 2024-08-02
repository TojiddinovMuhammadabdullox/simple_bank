import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_bank/controller/card_controller.dart';
import 'package:simple_bank/models/card_model.dart';
import 'package:simple_bank/views/screens/main_screen.dart';

class OtkazmalarScreen extends StatefulWidget {
  const OtkazmalarScreen({super.key});

  @override
  _OtkazmalarScreenState createState() => _OtkazmalarScreenState();
}

class _OtkazmalarScreenState extends State<OtkazmalarScreen> {
  final CardController _cardController = CardController();
  final TextEditingController _fromCardController = TextEditingController();
  final TextEditingController _toCardController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<CardModel> _userCards = [];
  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    _fetchUserCards();
  }

  void _fetchUserCards() async {
    List<CardModel> fetchedCards = await _cardController.fetchCards();
    setState(() {
      _userCards = fetchedCards;
      if (_userCards.isNotEmpty) {
        _selectedCard = _userCards[0];
        _fromCardController.text = _selectedCard!.cardNumber;
      }
    });
  }

  void _performTransaction() async {
    if (_selectedCard == null) {
      _showErrorDialog('Please select a card to transfer from.');
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;
    double currentBalance = double.tryParse(_selectedCard!.balance) ?? 0;

    if (amount <= 0) {
      _showErrorDialog('Please enter a valid amount.');
      return;
    }

    if (amount > currentBalance) {
      _showErrorDialog('Insufficient funds.');
      return;
    }

    // Perform the transaction
    double newBalance = currentBalance - amount;
    await _cardController.updateCardBalance(
        _selectedCard!.cardNumber, newBalance.toString());

    // Save the transaction to history
    await _cardController.addTransaction(
      _selectedCard!.cardNumber,
      _toCardController.text,
      amount.toString(),
      DateTime.now(),
    );

    // Show success message and clear fields
    _showSuccessDialog('Transaction successful!');
    _toCardController.clear();
    _amountController.clear();

    // Refresh user cards
    _fetchUserCards();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("O'tkazmalar"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<CardModel>(
              value: _selectedCard,
              items: _userCards.map((card) {
                return DropdownMenuItem<CardModel>(
                  value: card,
                  child: Text('${card.cardNumber} - ${card.balance}'),
                );
              }).toList(),
              onChanged: (CardModel? newValue) {
                setState(() {
                  _selectedCard = newValue;
                  _fromCardController.text = newValue?.cardNumber ?? '';
                });
              },
              hint: Text('Select a card'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _fromCardController,
              decoration: InputDecoration(
                labelText: 'From Card',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _toCardController,
              decoration: InputDecoration(
                labelText: 'To Card',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [CardNumberInputFormatter()],
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _performTransaction,
              child: Text('Send Money'),
            ),
          ],
        ),
      ),
    );
  }
}
