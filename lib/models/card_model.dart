class CardModel {
  final String cardNumber;
  final String balance;
  final String cardHolderName;
  final String expiryDate;

  CardModel({
    required this.cardNumber,
    required this.balance,
    required this.cardHolderName,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'balance': balance,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      cardNumber: map['cardNumber'] ?? '',
      balance: map['balance'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
    );
  }
}
