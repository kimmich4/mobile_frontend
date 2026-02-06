import 'base_view_model.dart';
import '../data/models/diet_model.dart';

/// ViewModel for Diet Screen
class DietViewModel extends BaseViewModel {
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  DateTime get selectedDate => _selectedDate;
  int get selectedDayIndex => _selectedDayIndex;

  // Sample diet data for each day of the week
  final Map<int, Map<String, dynamic>> dietData = {
    0: {
      'calories': '1,650',
      'protein': '105g',
      'carbs': '170g',
      'fats': '55g',
      'meals': [
        {
          'title': 'Breakfast',
          'cal': '400 cal',
          'items': [
            {'name': 'Eggs & Toast', 'cal': '350 cal'},
            {'name': 'Orange Juice', 'cal': '50 cal'}
          ]
        },
        {
          'title': 'Lunch',
          'cal': '600 cal',
          'items': [
            {'name': 'Turkey Sandwich', 'cal': '450 cal'},
            {'name': 'Side Salad', 'cal': '150 cal'}
          ]
        },
        {
          'title': 'Dinner',
          'cal': '650 cal',
          'items': [
            {'name': 'Steak & Veggies', 'cal': '650 cal'}
          ]
        }
      ]
    },
    1: {
      'calories': '1,710',
      'protein': '111g',
      'carbs': '180g',
      'fats': '58g',
      'meals': [
        {
          'title': 'Breakfast',
          'cal': '420 cal',
          'items': [
            {'name': 'Oatmeal with Berries', 'cal': '350 cal'},
            {'name': 'Coffee with Milk', 'cal': '70 cal'}
          ]
        },
        {
          'title': 'Lunch',
          'cal': '650 cal',
          'items': [
            {'name': 'Grilled Chicken Salad', 'cal': '450 cal'},
            {'name': 'Apple', 'cal': '80 cal'},
            {'name': 'Yogurt', 'cal': '120 cal'}
          ]
        },
        {
          'title': 'Snacks',
          'cal': '200 cal',
          'items': [
            {'name': 'Almonds', 'cal': '150 cal'},
            {'name': 'Dark Chocolate', 'cal': '50 cal'}
          ]
        },
        {
          'title': 'Dinner',
          'cal': '440 cal',
          'items': [
            {'name': 'Salmon with Asparagus', 'cal': '440 cal'}
          ]
        }
      ]
    },
    2: {
      'calories': '1,800',
      'protein': '120g',
      'carbs': '190g',
      'fats': '60g',
      'meals': [
        {
          'title': 'Breakfast',
          'cal': '450 cal',
          'items': [
            {'name': 'Greek Yogurt Bowl', 'cal': '400 cal'},
            {'name': 'Honey', 'cal': '50 cal'}
          ]
        },
        {
          'title': 'Lunch',
          'cal': '700 cal',
          'items': [
            {'name': 'Beef Stir Fry', 'cal': '600 cal'},
            {'name': 'Brown Rice', 'cal': '100 cal'}
          ]
        },
        {
          'title': 'Dinner',
          'cal': '650 cal',
          'items': [
            {'name': 'Pasta with Shrimp', 'cal': '650 cal'}
          ]
        }
      ]
    },
  };

  /// Get current day's diet data
  Map<String, dynamic> get currentDietData {
    return dietData[_selectedDayIndex] ?? dietData[0]!;
  }

  /// Select a specific day
  void selectDay(int dayIndex) {
    _selectedDayIndex = dayIndex;
    // Calculate new date based on day index
    final int difference = dayIndex - (_selectedDate.weekday - 1);
    _selectedDate = _selectedDate.add(Duration(days: difference));
    notifyListeners();
  }

  /// Set a specific date
  void setDate(DateTime date) {
    _selectedDate = date;
    _selectedDayIndex = date.weekday - 1;
    notifyListeners();
  }

  /// Get formatted date string
  String getFormattedDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final day = _selectedDate.day.toString();
    String suffix = 'th';
    if (day.endsWith('1') && day != '11') {
      suffix = 'st';
    } else if (day.endsWith('2') && day != '12') {
      suffix = 'nd';
    } else if (day.endsWith('3') && day != '13') {
      suffix = 'rd';
    }
    return "${dayNames[_selectedDate.weekday - 1]}, ${months[_selectedDate.month - 1]} $day$suffix";
  }
}
