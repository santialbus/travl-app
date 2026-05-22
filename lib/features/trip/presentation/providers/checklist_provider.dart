import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/checklist_remote_datasource.dart';
import '../../domain/entities/checklist_item_entity.dart';

final checklistDataSourceProvider = Provider<ChecklistRemoteDataSource>((ref) {
  return ChecklistRemoteDataSource();
});

final tripChecklistProvider =
StreamProvider.family<List<ChecklistItemEntity>, String>((ref, tripId) {
  final dataSource = ref.watch(checklistDataSourceProvider);
  return dataSource.getTripChecklist(tripId);
});

final checklistControllerProvider =
StateNotifierProvider<ChecklistController, ChecklistState>((ref) {
  final dataSource = ref.watch(checklistDataSourceProvider);
  return ChecklistController(dataSource);
});

class ChecklistState {
  final bool isLoading;
  final String? error;

  ChecklistState({this.isLoading = false, this.error});

  ChecklistState copyWith({bool? isLoading, String? error}) {
    return ChecklistState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChecklistController extends StateNotifier<ChecklistState> {
  final ChecklistRemoteDataSource _dataSource;

  ChecklistController(this._dataSource) : super(ChecklistState());

  Future<bool> createItem({
    required String tripId,
    required String title,
    required ChecklistType type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.createItem(
        tripId: tripId,
        title: title,
        type: type,
      );
      state = ChecklistState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleItem(String itemId, bool isDone) async {
    try {
      await _dataSource.toggleItem(itemId, isDone);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _dataSource.deleteItem(itemId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}