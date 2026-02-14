import 'package:firebase_auth/firebase_auth.dart';
import 'base_view_model.dart';
import '../data/models/progress_model.dart';
import '../data/repositories/progress_repository.dart';

/// ViewModel for Progress Tracking Screen
class ProgressTrackingViewModel extends BaseViewModel {
  final ProgressRepository _progressRepository;
  
  ProgressTrackingViewModel({ProgressRepository? progressRepository})
      : _progressRepository = progressRepository ?? ProgressRepository();

  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  int get selectedPeriod => _selectedPeriod;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Get current period type
  ProgressPeriod get currentPeriod {
    switch (_selectedPeriod) {
      case 0:
        return ProgressPeriod.week;
      case 1:
        return ProgressPeriod.month;
      case 2:
        return ProgressPeriod.year;
      default:
        return ProgressPeriod.week;
    }
  }

  // Stats data
  ProgressStats? _stats;
  ProgressStats? get stats => _stats;

  // Weight progress data (placeholder for now, needs graph data model in repo)
  final List<WeightDataPoint> weightData = [];

  // Calories data (placeholder)
  final List<CalorieDataPoint> caloriesData = [];

  // Consistency data
  ConsistencyData _consistencyData = ConsistencyData(days: []);
  ConsistencyData get consistencyData => _consistencyData;
  
  /// Initialize
  Future<void> init() async {
    await fetchProgressData();
  }
  
  /// Fetch all progress data
  Future<void> fetchProgressData() async {
    if (userId == null) return;
    
    setLoading(true);
    clearError();
    
    try {
      _stats = await _progressRepository.getProgressStats(userId!);
      
      final days = await _progressRepository.getWeeklyConsistency(userId!);
      _consistencyData = ConsistencyData(days: days);
      
      // Fetch graph data... implementation depends on exact repo methods
      
    } catch (e) {
      setError('Failed to load progress data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Set selected period
  void setSelectedPeriod(int period) {
    _selectedPeriod = period;
    // In a real app, this would trigger data loading for the selected period
    notifyListeners();
  }
}
