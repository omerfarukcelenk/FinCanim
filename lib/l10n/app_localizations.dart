import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Coffee Readings'**
  String get appTitle;

  /// No description provided for @falResult.
  ///
  /// In en, this message translates to:
  /// **'Your Coffee Reading'**
  String get falResult;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'My History'**
  String get historyTitle;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'You have no history yet'**
  String get noHistory;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get backToHome;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @commentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Comment'**
  String get commentTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @newReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'New Reading'**
  String get newReadingTitle;

  /// No description provided for @newReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a cup photo'**
  String get newReadingSubtitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your old readings'**
  String get historySubtitle;

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it Works'**
  String get howItWorksTitle;

  /// No description provided for @howItWorksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get howItWorksSubtitle;

  /// No description provided for @lookTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get lookTitle;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery or take photo'**
  String get choosePhoto;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get welcomeGreeting;

  /// No description provided for @welcomePrompt.
  ///
  /// In en, this message translates to:
  /// **'Is your coffee cup ready?'**
  String get welcomePrompt;

  /// No description provided for @readFortune.
  ///
  /// In en, this message translates to:
  /// **'Read My Fortune'**
  String get readFortune;

  /// No description provided for @lookStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Drink Your Coffee'**
  String get lookStep1Title;

  /// No description provided for @lookStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your Turkish coffee'**
  String get lookStep1Subtitle;

  /// No description provided for @lookStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Turn the Cup Over'**
  String get lookStep2Title;

  /// No description provided for @lookStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Place it on the saucer and let it cool'**
  String get lookStep2Subtitle;

  /// No description provided for @lookStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get lookStep3Title;

  /// No description provided for @lookStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a clear, well-lit photo'**
  String get lookStep3Subtitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s discover your future together'**
  String get splashSubtitle;

  /// No description provided for @homeCallToAction.
  ///
  /// In en, this message translates to:
  /// **'Let\'s read your fortune!'**
  String get homeCallToAction;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo of your coffee cup and get an AI-assisted reading'**
  String get homeSubtitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo? This action cannot be undone.'**
  String get deleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @pleaseRestart.
  ///
  /// In en, this message translates to:
  /// **'Please fully restart the app to apply updates.'**
  String get pleaseRestart;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to create an account'**
  String get registerSubtitle;

  /// No description provided for @googleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleContinue;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your readings'**
  String get loginWelcomeSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get nameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 555 555 5555'**
  String get phoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @maritalLabel.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalLabel;

  /// No description provided for @maritalSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get maritalSingle;

  /// No description provided for @maritalMarried.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get maritalMarried;

  /// No description provided for @maritalOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get maritalOther;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get ageRequired;

  /// No description provided for @ageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get ageInvalid;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly'**
  String get fillAllFields;

  /// No description provided for @otpInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number. Verify with the SMS code to link your account.'**
  String get otpInstruction;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get codeHint;

  /// No description provided for @phoneNotEditable.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed'**
  String get phoneNotEditable;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @profileTotalReadings.
  ///
  /// In en, this message translates to:
  /// **'Total Readings'**
  String get profileTotalReadings;

  /// No description provided for @profileRemainingRights.
  ///
  /// In en, this message translates to:
  /// **'Remaining Rights'**
  String get profileRemainingRights;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm sign out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirmMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get menuPremium;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get menuHelp;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
