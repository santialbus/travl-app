import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/checklist_remote_datasource.dart';
import '../../data/repositories/checklist_repository_impl.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../../domain/repositories/checklist_repository.dart';

final checklistDataSourceProvider = Provider<ChecklistRemoteDataSource>((ref) {
  return ChecklistRemoteDataSource();
});

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final dataSource = ref.watch(checklistDataSourceProvider);
  return ChecklistRepositoryImpl(dataSource);
});

final tripChecklistProvider =
    StreamProvider.family<List<ChecklistItemEntity>, String>((ref, tripId) {
  final repository = ref.watch(checklistRepositoryProvider);
  return repository.getTripChecklist(tripId);
});

final checklistControllerProvider =
    StateNotifierProvider<ChecklistController, ChecklistState>((ref) {
  final repository = ref.watch(checklistRepositoryProvider);
  return ChecklistController(repository);
});

class ChecklistState {
  final bool isLoading;
  final String? error;

  ChecklistState({this.isLoading = false, this.error});

  ChecklistState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ChecklistState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChecklistController extends StateNotifier<ChecklistState> {
  final ChecklistRepository _repository;

  ChecklistController(this._repository) : super(ChecklistState());

  Future<bool> createItem({
    required String tripId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createItem(
        tripId: tripId,
        title: title,
        type: type,
        assignedTo: assignedTo,
      );

      state = ChecklistState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateItem({
    required String itemId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateItem(
        itemId: itemId,
        title: title,
        type: type,
        assignedTo: assignedTo,
      );

      state = ChecklistState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> toggleItem(String itemId, bool isDone) async {
    try {
      await _repository.toggleItem(itemId, isDone);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _repository.deleteItem(itemId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
