import 'package:firebase_auth/firebase_auth.dart';
import 'base_view_model.dart';
import '../data/models/progress_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/user_repository.dart';

/// ViewModel for Progress Tracking Screen — computes real progress data
class ProgressTrackingViewModel extends BaseViewModel {
  final ProgressRepository _progressRepository;
  final UserRepository _userRepository;

  ProgressTrackingViewModel({
    ProgressRepository? progressRepository,
    UserRepository? userRepository,
  })  : _progressRepository = progressRepository ?? ProgressRepository(),
        _userRepository = userRepository ?? UserRepository();

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

  // User data for computing dynamic subtitles
  UserModel? _currentUser;

  // Weight progress data
  final List<WeightDataPoint> weightData = [];

  // Calories data
  final List<CalorieDataPoint> caloriesData = [];

  // Consistency data
  ConsistencyData _consistencyData = ConsistencyData(days: []);
  ConsistencyData get consistencyData => _consistencyData;

  /// Dynamic subtitle for weight progress
  String get weightProgressSubtitle {
    if (_currentUser == null) return '';
    final initial = _currentUser!.weightKg;
    final current = _currentUser!.currentWeightKg;
    if (initial != null && current != null) {
      final diff = current - initial;
      final sign = diff >= 0 ? '+' : '';
      return '${sign}${diff.toStringAsFixed(1)} kg this week';
    }
    return 'No weight data';
  }

  /// Dynamic subtitle for workout consistency
  String get consistencySubtitle {
    final rate = _consistencyData.completionRate;
    return '${(rate * 100).round()}% completion rate';
  }

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

      // Fetch user data for dynamic calculations
      _currentUser = await _userRepository.getUserProfile(userId!);

    } catch (e) {
      setError('Failed to load progress data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Set selected period
  void setSelectedPeriod(int period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
