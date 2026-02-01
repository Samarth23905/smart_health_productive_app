import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Health'**
  String get appTitle;

  /// No description provided for @login_as.
  ///
  /// In en, this message translates to:
  /// **'Login As'**
  String get login_as;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @placeholder_citizen.
  ///
  /// In en, this message translates to:
  /// **'Name / Email / Phone'**
  String get placeholder_citizen;

  /// No description provided for @placeholder_hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get placeholder_hospital;

  /// No description provided for @placeholder_ambulance.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get placeholder_ambulance;

  /// No description provided for @placeholder_government.
  ///
  /// In en, this message translates to:
  /// **'Admin Username'**
  String get placeholder_government;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get no_account;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials or server error'**
  String get invalid_credentials;

  /// No description provided for @enter_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please enter all fields'**
  String get enter_all_fields;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @hospital_name.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get hospital_name;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @total_beds.
  ///
  /// In en, this message translates to:
  /// **'Total Beds'**
  String get total_beds;

  /// No description provided for @icu_beds.
  ///
  /// In en, this message translates to:
  /// **'ICU Beds'**
  String get icu_beds;

  /// No description provided for @oxygen_available.
  ///
  /// In en, this message translates to:
  /// **'Oxygen Available'**
  String get oxygen_available;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @auto_fetch_location.
  ///
  /// In en, this message translates to:
  /// **'📍 Auto-fetch Location'**
  String get auto_fetch_location;

  /// No description provided for @add_photo.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get add_photo;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get take_photo;

  /// No description provided for @choose_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get choose_gallery;

  /// No description provided for @add_profile_picture.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Picture'**
  String get add_profile_picture;

  /// No description provided for @registration_successful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registration_successful;

  /// No description provided for @registration_failed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registration_failed;

  /// No description provided for @fill_required_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields'**
  String get fill_required_fields;

  /// No description provided for @valid_lat_lng.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid latitude and longitude'**
  String get valid_lat_lng;

  /// No description provided for @location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get location_permission_denied;

  /// No description provided for @location_fetched.
  ///
  /// In en, this message translates to:
  /// **'Location fetched successfully'**
  String get location_fetched;

  /// No description provided for @camera_error.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get camera_error;

  /// No description provided for @gallery_error.
  ///
  /// In en, this message translates to:
  /// **'Gallery error'**
  String get gallery_error;

  /// No description provided for @photo_captured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully'**
  String get photo_captured;

  /// No description provided for @image_selected.
  ///
  /// In en, this message translates to:
  /// **'Image selected successfully'**
  String get image_selected;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome_back;

  /// No description provided for @health_priority.
  ///
  /// In en, this message translates to:
  /// **'Your health is our priority. Quick access to healthcare services.'**
  String get health_priority;

  /// No description provided for @emergency_sos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergency_sos;

  /// No description provided for @dispatch_ambulance.
  ///
  /// In en, this message translates to:
  /// **'Tap to dispatch ambulance immediately'**
  String get dispatch_ambulance;

  /// No description provided for @healthcare_services.
  ///
  /// In en, this message translates to:
  /// **'Healthcare Services'**
  String get healthcare_services;

  /// No description provided for @symptom_checker.
  ///
  /// In en, this message translates to:
  /// **'Symptom Checker'**
  String get symptom_checker;

  /// No description provided for @instant_assessment.
  ///
  /// In en, this message translates to:
  /// **'Get instant health assessment'**
  String get instant_assessment;

  /// No description provided for @find_hospital.
  ///
  /// In en, this message translates to:
  /// **'Find Hospital'**
  String get find_hospital;

  /// No description provided for @locate_facility.
  ///
  /// In en, this message translates to:
  /// **'Locate nearest medical facility'**
  String get locate_facility;

  /// No description provided for @health_records.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get health_records;

  /// No description provided for @medical_history.
  ///
  /// In en, this message translates to:
  /// **'View your medical history'**
  String get medical_history;

  /// No description provided for @about_app.
  ///
  /// In en, this message translates to:
  /// **'About Smart Health'**
  String get about_app;

  /// No description provided for @learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn more about our platform'**
  String get learn_more;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @smart_health.
  ///
  /// In en, this message translates to:
  /// **'Smart Health'**
  String get smart_health;

  /// No description provided for @ambulance_dispatch.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert sent! Ambulance en route.'**
  String get ambulance_dispatch;

  /// No description provided for @dispatch_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send emergency alert'**
  String get dispatch_failed;

  /// No description provided for @hospital_operations.
  ///
  /// In en, this message translates to:
  /// **'Hospital Operations'**
  String get hospital_operations;

  /// No description provided for @active_alerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get active_alerts;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @edit_hospital_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Hospital Profile'**
  String get edit_hospital_profile;

  /// No description provided for @beds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get beds;

  /// No description provided for @icu_beds_label.
  ///
  /// In en, this message translates to:
  /// **'ICU Beds'**
  String get icu_beds_label;

  /// No description provided for @oxygen.
  ///
  /// In en, this message translates to:
  /// **'Oxygen'**
  String get oxygen;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @no_hospitals_found.
  ///
  /// In en, this message translates to:
  /// **'No hospitals found'**
  String get no_hospitals_found;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @or_text.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or_text;

  /// No description provided for @your_trusted_healthcare.
  ///
  /// In en, this message translates to:
  /// **'Your trusted healthcare companion'**
  String get your_trusted_healthcare;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'kn': return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
