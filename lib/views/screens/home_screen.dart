import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_bank/bloc/card_bloc.dart'; // Adjust the import based on your project structure
import 'package:simple_bank/models/card_model.dart';
import 'package:simple_bank/views/screens/login_screen.dart';
import 'package:simple_bank/views/widgets/card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  void _fetchCards() {
    BlocProvider.of<CardBloc>(context).add(FetchCards());
  }

  void _showAddCardDialog() {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();
    final TextEditingController cardHolderNameController =
        TextEditingController();
    final TextEditingController expiryDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Balance'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cardHolderNameController,
                decoration:
                    const InputDecoration(labelText: 'Card Holder Name'),
              ),
              TextField(
                controller: expiryDateController,
                decoration:
                    const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                CardModel newCard = CardModel(
                  cardNumber: cardNumberController.text,
                  balance: balanceController.text,
                  cardHolderName: cardHolderNameController.text,
                  expiryDate: expiryDateController.text,
                );
                BlocProvider.of<CardBloc>(context).add(AddCard(newCard));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (context, state) {
          if (state is CardLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CardLoaded) {
            final cards = state.cards;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return CardWidget(
                        cardModel: cards[index],
                        onDelete: () {
                          BlocProvider.of<CardBloc>(context)
                              .add(DeleteCard(cards[index].cardNumber));
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )),
                      onPressed: _showAddCardDialog,
                      child: const Text(
                        'Add Card',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is CardError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
