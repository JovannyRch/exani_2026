# Test Suite Documentation

## Overview

Comprehensive test suite for EXANI app before Play Store launch.

## Test Structure

```
test/
├── unit/                    # Unit tests for services and models
│   ├── cache_service_test.dart
│   ├── question_selector_test.dart
│   ├── session_engine_test.dart
│   └── question_model_test.dart
├── widgets/                 # Widget tests for UI components
│   ├── duo_button_test.dart
│   ├── app_loader_test.dart
│   ├── exam_selection_screen_test.dart
│   └── app_theme_test.dart
└── widget_test.dart        # Legacy test file

integration_test/
└── app_integration_test.dart  # End-to-end integration tests
```

## Running Tests

### Run All Unit Tests

```bash
flutter test test/unit/
```

### Run All Widget Tests

```bash
flutter test test/widgets/
```

### Run All Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter test integration_test/
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

## Test Coverage

### Unit Tests (test/unit/)

#### cache_service_test.dart

- ✅ Store and retrieve data
- ✅ TTL expiration handling
- ✅ Clear expired entries
- ✅ Clear all data
- ✅ Handle null values
- ✅ Use default TTL from CacheKeys

#### question_selector_test.dart

- ✅ Select questions respecting limit
- ✅ Handle requesting more than available
- ✅ Avoid recently answered questions
- ✅ Prioritize weak areas
- ✅ Return empty list when no questions
- ✅ Shuffle questions for variety

#### session_engine_test.dart

- ✅ Create diagnostic config
- ✅ Create practice config with filters (section/area/skill)
- ✅ Create simulation config with time limit
- ✅ SessionMode labels
- ✅ Mode identification (isPractice, isDiagnostic, isSimulation)

#### question_model_test.dart

- ✅ Create question with required fields
- ✅ Create from Supabase data
- ✅ Handle skillId (optional)
- ✅ Shuffle options
- ✅ Limit shuffled options
- ✅ Handle optional fields (image, explanation, difficulty, tags)
- ✅ Option model with image support

### Widget Tests (test/widgets/)

#### duo_button_test.dart

- ✅ Render with text
- ✅ Trigger callback on tap
- ✅ Respect custom color
- ✅ Disabled state
- ✅ Show icon when provided
- ✅ Full width by default

#### app_loader_test.dart

- ✅ Render bouncing dots loader
- ✅ Show custom message
- ✅ AppLoading.show displays dialog
- ✅ AppPulseLoader animation
- ✅ AppSpinnerLoader rotation

#### exam_selection_screen_test.dart

- ✅ Display exam options
- ✅ Trigger callback on selection
- ✅ Show exam descriptions

#### app_theme_test.dart

- ✅ Light theme configuration
- ✅ Dark theme configuration
- ✅ AppColors consistency
- ✅ Theme switching

### Integration Tests (integration_test/)

#### app_integration_test.dart

- ✅ Complete auth and onboarding flow
- ✅ Navigation through main screens
- ✅ Theme switching

## Manual Testing Checklist

### Authentication

- [ ] User can register with email/password
- [ ] User can login with existing credentials
- [ ] User can login anonymously
- [ ] Password reset link works
- [ ] Logout works and redirects to AuthScreen
- [ ] Error messages display correctly in Spanish

### Onboarding

- [ ] Exam selection shows EXANI-I and EXANI-II
- [ ] Date picker works
- [ ] Module selection (EXANI-II only) works
- [ ] Can select exactly 2 modules
- [ ] Progress bar updates correctly
- [ ] "Omitir por ahora" skips optional steps
- [ ] Data saves to Supabase correctly

### Dashboard (ExaniHomeScreen)

- [ ] Stats load correctly (sessions, accuracy, streak)
- [ ] Weakest area displays
- [ ] "Práctica por tema" navigates correctly
- [ ] "Simulacro completo" navigates correctly
- [ ] "Guía de estudio" loads questions from Supabase
- [ ] Leaderboard preview shows
- [ ] Days countdown shows if exam date set
- [ ] Theme toggle works
- [ ] Profile menu shows
- [ ] Logout confirmation works

### Practice Setup

- [ ] Sections load from Supabase
- [ ] Areas load when section selected
- [ ] Skills load when area selected
- [ ] Question counts display correctly
- [ ] "Empezar práctica" loads questions
- [ ] Navigation breadcrumb works
- [ ] Back navigation preserves state

### Simulation

- [ ] Exam rules display correctly
- [ ] Config loads from database (168 questions, 270 min)
- [ ] Questions load from all sections
- [ ] Timer starts when simulation begins
- [ ] Can navigate between questions
- [ ] Can mark questions for review
- [ ] Submit shows confirmation dialog
- [ ] Results screen shows correct stats

### Performance

- [ ] App launches < 3 seconds
- [ ] Screens load smoothly
- [ ] No jank or frame drops
- [ ] Cache reduces duplicate queries
- [ ] Images load progressively
- [ ] Animations are smooth (60fps)

### Offline Behavior

- [ ] Cached data loads when offline
- [ ] Proper error messages when no connection
- [ ] Retry mechanisms work
- [ ] No crashes when offline

### Ads & Monetization

- [ ] Banner ads display correctly
- [ ] Interstitial ads show at appropriate times
- [ ] Pro version removes ads
- [ ] In-app purchase flow works
- [ ] Purchase restoration works

### Edge Cases

- [ ] Empty states display properly
- [ ] Error states show helpful messages
- [ ] Very long user names display well
- [ ] Special characters in text handled
- [ ] Rapid tapping doesn't break navigation
- [ ] Memory doesn't leak over long sessions
- [ ] Back button behavior is intuitive

## Known Limitations

1. **Database Content**: Only 3 questions seeded (needs full content)
2. **Integration Tests**: Require Supabase configuration
3. **Mock Data**: Removed entirely (100% Supabase now)

## Pre-Launch Requirements

✅ All unit tests passing  
✅ All widget tests passing  
✅ Integration tests passing  
⚠️ Database seeded with real EXANI questions  
⚠️ Manual testing checklist completed  
⚠️ Performance profiling done  
⚠️ Crash analytics configured  
⚠️ Privacy policy added  
⚠️ Terms of service added

## CI/CD Recommendations

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter test integration_test/
```

## Coverage Goals

- **Unit Tests**: > 80% coverage
- **Widget Tests**: > 70% coverage
- **Integration Tests**: Critical flows covered

## Reporting Issues

When tests fail:

1. Check error message and stack trace
2. Verify Supabase connection (for integration tests)
3. Ensure all dependencies installed
4. Check for breaking API changes
5. Report to development team with logs

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
