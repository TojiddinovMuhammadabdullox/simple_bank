import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_bank/controller/card_controller.dart';
import 'package:simple_bank/models/card_model.dart';
import 'package:simple_bank/views/screens/history_screen.dart';
import 'package:simple_bank/views/screens/home_screen.dart';
import 'package:simple_bank/views/screens/otkazmalar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CardController _cardController = CardController();
  final List<CardModel> _cards = [];
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OtkazmalarScreen(),
    const TarixScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  void _fetchCards() async {
    List<CardModel> fetchedCards = await _cardController.fetchCards();
    setState(() {
      _cards.addAll(fetchedCards);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "O'tkazmalar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Tarix',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;

    for (int i = 0; i < newValue.text.length; i++) {
      if (i % 5 == 4) {
        if (newValue.text.length > usedSubstringIndex) {
          newText.write(' ');
          if (newValue.selection.end > i) selectionIndex++;
        }
      }
      newText.write(newValue.text[usedSubstringIndex]);
      usedSubstringIndex++;
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;

    if (newValue.text.length > 2) {
      newText.write(newValue.text.substring(0, 2));
      newText.write('/');
      newText.write(newValue.text.substring(2, newValue.text.length));
      selectionIndex++;
    } else {
      newText.write(newValue.text);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
