import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeltsBloc {
  final _repository = Repository();
  final _id = BehaviorSubject<String>();
  final _beltname = BehaviorSubject<String>();
  final _level = BehaviorSubject<String>();
  final _showProgress = BehaviorSubject<bool>();

  Observable<String> get id => _id.stream;
  Observable<String> get beltname => _beltname.stream.transform(_validateName);
  Observable<String> get level => _level.stream.transform(_validateLevel);
  Observable<bool> get showProgress => _showProgress.stream;
  Function(String) get changeBeltName => _beltname.sink.add;
  Function(String) get changeLevel => _level.sink.add;

  final _validateName = StreamTransformer<String, String>.fromHandlers(
    handleData: (beltname, sink) {
      if (beltname.length > 3 && RegExp(r'[a-zA-Z]').hasMatch(beltname)) {
        sink.add(beltname);
      } else {
        sink.addError("beltname should have 3 characters or more and letters only");
      }
    }
  );

  final _validateLevel = StreamTransformer<String, String>.fromHandlers(
    handleData: (level, sink) {
      if (int.parse(level) > 0) {
        sink.add(level);
      } else {
        sink.addError("level must be greater than 0");
      }
    }
  );

  void submit() {
    _showProgress.sink.add(true);
    Belt _belt = Belt(beltname: _beltname.value, level: int.parse(_level.value));
    _repository.addBelt(_belt)
    .then((value) {
      _id.sink.add(value);
      _showProgress.sink.add(false);
    });
  }

  Stream<QuerySnapshot> getAllBelts() {
    return _repository.getAllBelts();
  }

  Stream<DocumentSnapshot> getBelt(String id) {
    return _repository.getBelt(id);
  }

  void dispose() async {
    await _id.drain();
    _id.close();
    await _beltname.drain();
    _beltname.close();
    await _level.drain();
    _level.close();
    await _showProgress.drain();
    _showProgress.close();
  }

}