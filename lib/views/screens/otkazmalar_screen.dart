import 'package:flutter/material.dart';
import 'package:simple_bank/controller/card_controller.dart';
import 'package:simple_bank/models/card_model.dart';

class OtkazmalarScreen extends StatefulWidget {
  const OtkazmalarScreen({super.key});

  @override
  _OtkazmalarScreenState createState() => _OtkazmalarScreenState();
}

class _OtkazmalarScreenState extends State<OtkazmalarScreen> {
  final CardController _cardController = CardController();
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

    double newBalance = currentBalance - amount;
    await _cardController.updateCardBalance(
        _selectedCard!.cardNumber, newBalance.toString());

    await _cardController.addTransaction(
      _selectedCard!.cardNumber,
      _toCardController.text,
      amount.toString(),
      DateTime.now(),
    );

    _showSuccessDialog('Transaction successful!');
    _toCardController.clear();
    _amountController.clear();

    _fetchUserCards();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer Money"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'From Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButton<CardModel>(
                  value: _selectedCard,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _userCards.map((card) {
                    return DropdownMenuItem<CardModel>(
                      value: card,
                      child: Text('${card.cardNumber} - ${card.balance}'),
                    );
                  }).toList(),
                  onChanged: (CardModel? newValue) {
                    setState(() {
                      _selectedCard = newValue;
                    });
                  },
                  hint: const Text('Select a card'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'To Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _toCardController,
                decoration: InputDecoration(
                  hintText: 'Enter card number',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text(
                'Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _performTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Send Money', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
