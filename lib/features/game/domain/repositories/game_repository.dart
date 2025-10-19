import 'package:wordshool/core/resorces/data_state.dart';

abstract class GameRepository {
  Future<DataState<String>> loadTodayWord();
  Future<DataState<String>> submitWord(String word);
}
