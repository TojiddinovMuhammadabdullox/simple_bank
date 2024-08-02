import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel cardModel;

  const CardWidget({super.key, required this.cardModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cardModel.cardNumber,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                child: Icon(
                  Icons.sd_card,
                  color: Colors.amber,
                ),
              ),
              Text(
                "BALANCE: ${cardModel.balance}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Text(cardModel.cardHolderName),
              Text(cardModel.expiryDate),
            ],
          ),
        ),
      ),
    );
  }
}
