import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_bank/models/card_model.dart';
import 'package:simple_bank/repositories/card_repository.dart';

abstract class CardEvent {}

class FetchCards extends CardEvent {}

class AddCard extends CardEvent {
  final CardModel card;
  AddCard(this.card);
}

class UpdateCardBalance extends CardEvent {
  final String cardNumber;
  final String newBalance;
  UpdateCardBalance(this.cardNumber, this.newBalance);
}

class DeleteCard extends CardEvent {
  final String cardNumber;
  DeleteCard(this.cardNumber);
}

abstract class CardState {}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final List<CardModel> cards;
  CardLoaded(this.cards);
}

class CardError extends CardState {
  final String message;
  CardError(this.message);
}

class CardBloc extends Bloc<CardEvent, CardState> {
  final CardRepository repository;

  CardBloc(this.repository) : super(CardInitial()) {
    on<FetchCards>((event, emit) async {
      emit(CardLoading());
      try {
        final cards = await repository.fetchCards();
        emit(CardLoaded(cards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });

    on<AddCard>((event, emit) async {
      emit(CardLoading());
      try {
        await repository.addCard(event.card);
        final cards = await repository.fetchCards();
        emit(CardLoaded(cards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });

    on<UpdateCardBalance>((event, emit) async {
      emit(CardLoading());
      try {
        await repository.updateCardBalance(event.cardNumber, event.newBalance);
        final cards = await repository.fetchCards();
        emit(CardLoaded(cards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });

    on<DeleteCard>((event, emit) async {
      emit(CardLoading());
      try {
        await repository.deleteCard(event.cardNumber);
        final cards = await repository.fetchCards();
        emit(CardLoaded(cards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });
  }
}
