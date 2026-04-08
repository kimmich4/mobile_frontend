import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/viewmodels/onboarding_view_model.dart';

void main() {
  group('OnboardingViewModel', () {
    test('setCurrentPage should update state', () {
      final viewModel = OnboardingViewModel();
      viewModel.setCurrentPage(1);
      expect(viewModel.currentPage, 1);
    });
  });
}
