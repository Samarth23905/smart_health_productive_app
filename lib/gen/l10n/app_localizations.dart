import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('hi'),
    Locale('kn'),
    Locale('mr')
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

  /// No description provided for @proposed_solution.
  ///
  /// In en, this message translates to:
  /// **'Proposed Solution'**
  String get proposed_solution;

  /// No description provided for @unified_health_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Unified Health Dashboard'**
  String get unified_health_dashboard;

  /// No description provided for @digital_records_history.
  ///
  /// In en, this message translates to:
  /// **'Digital health records & history'**
  String get digital_records_history;

  /// No description provided for @all_health_info.
  ///
  /// In en, this message translates to:
  /// **'All health info in one place'**
  String get all_health_info;

  /// No description provided for @preventive_health_alerts.
  ///
  /// In en, this message translates to:
  /// **'Preventive Health Alerts'**
  String get preventive_health_alerts;

  /// No description provided for @area_based_outbreak.
  ///
  /// In en, this message translates to:
  /// **'Area-based outbreak alerts'**
  String get area_based_outbreak;

  /// No description provided for @city_wide_warnings.
  ///
  /// In en, this message translates to:
  /// **'City-wide health warnings'**
  String get city_wide_warnings;

  /// No description provided for @one_touch_sos.
  ///
  /// In en, this message translates to:
  /// **'One-touch SOS button'**
  String get one_touch_sos;

  /// No description provided for @quick_emergency_help.
  ///
  /// In en, this message translates to:
  /// **'Quick emergency help'**
  String get quick_emergency_help;

  /// No description provided for @smart_integrated_system.
  ///
  /// In en, this message translates to:
  /// **'Smart, Accessible & Integrated Health Management System'**
  String get smart_integrated_system;

  /// No description provided for @hospital_label.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital_label;

  /// No description provided for @app_label.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app_label;

  /// No description provided for @government_label.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government_label;

  /// No description provided for @no_patients.
  ///
  /// In en, this message translates to:
  /// **'No Patients Yet'**
  String get no_patients;

  /// No description provided for @awaiting_ambulance.
  ///
  /// In en, this message translates to:
  /// **'Awaiting incoming ambulance alerts'**
  String get awaiting_ambulance;

  /// No description provided for @no_active_alerts.
  ///
  /// In en, this message translates to:
  /// **'No Active Alerts'**
  String get no_active_alerts;

  /// No description provided for @waiting_dispatch.
  ///
  /// In en, this message translates to:
  /// **'Waiting for emergency dispatch'**
  String get waiting_dispatch;

  /// No description provided for @health_analytics.
  ///
  /// In en, this message translates to:
  /// **'Health Analytics Dashboard'**
  String get health_analytics;

  /// No description provided for @government_analytics.
  ///
  /// In en, this message translates to:
  /// **'Government Analytics'**
  String get government_analytics;

  /// No description provided for @active_hospitals.
  ///
  /// In en, this message translates to:
  /// **'Active Hospitals'**
  String get active_hospitals;

  /// No description provided for @ambulance_count.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Count'**
  String get ambulance_count;

  /// No description provided for @avg_eta.
  ///
  /// In en, this message translates to:
  /// **'Average ETA (min)'**
  String get avg_eta;

  /// No description provided for @completed_alerts.
  ///
  /// In en, this message translates to:
  /// **'Completed Alerts'**
  String get completed_alerts;

  /// No description provided for @refresh_data.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refresh_data;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @failed_load_analytics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics'**
  String get failed_load_analytics;

  /// No description provided for @digital_adoption.
  ///
  /// In en, this message translates to:
  /// **'Digital Adoption (%)'**
  String get digital_adoption;

  /// No description provided for @oxygen_hospitals.
  ///
  /// In en, this message translates to:
  /// **'Oxygen-ready Hospitals'**
  String get oxygen_hospitals;

  /// No description provided for @registered_citizens.
  ///
  /// In en, this message translates to:
  /// **'Registered Citizens'**
  String get registered_citizens;

  /// No description provided for @total_alerts.
  ///
  /// In en, this message translates to:
  /// **'Total Alerts'**
  String get total_alerts;

  /// No description provided for @total_citizens.
  ///
  /// In en, this message translates to:
  /// **'Total Citizens'**
  String get total_citizens;

  /// No description provided for @not_set.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get not_set;

  /// No description provided for @personal_information.
  ///
  /// In en, this message translates to:
  /// **'👤 Personal Information'**
  String get personal_information;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'💾 Save Changes'**
  String get save_changes;

  /// No description provided for @hospital_resources.
  ///
  /// In en, this message translates to:
  /// **'🏥 Hospital Resources'**
  String get hospital_resources;

  /// No description provided for @bed_capacity.
  ///
  /// In en, this message translates to:
  /// **'Bed Capacity'**
  String get bed_capacity;

  /// No description provided for @medical_supplies.
  ///
  /// In en, this message translates to:
  /// **'Medical Supplies'**
  String get medical_supplies;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'✓ Available'**
  String get available;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'✗ Not available'**
  String get not_available;

  /// No description provided for @oxygen_info_message.
  ///
  /// In en, this message translates to:
  /// **'Enable oxygen if available for emergency SOS dispatch'**
  String get oxygen_info_message;

  /// No description provided for @symptom_check.
  ///
  /// In en, this message translates to:
  /// **'🩺 Symptom Check'**
  String get symptom_check;

  /// No description provided for @select_symptoms_with_details.
  ///
  /// In en, this message translates to:
  /// **'Expand categories and select symptoms with details:'**
  String get select_symptoms_with_details;

  /// No description provided for @selected_symptoms.
  ///
  /// In en, this message translates to:
  /// **'✅ Selected Symptoms:'**
  String get selected_symptoms;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submit_symptoms.
  ///
  /// In en, this message translates to:
  /// **'Submit Symptoms'**
  String get submit_symptoms;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @how_many_days.
  ///
  /// In en, this message translates to:
  /// **'How many days?'**
  String get how_many_days;

  /// No description provided for @enter_number_of_days.
  ///
  /// In en, this message translates to:
  /// **'Enter number of days'**
  String get enter_number_of_days;

  /// No description provided for @severity_level.
  ///
  /// In en, this message translates to:
  /// **'Severity Level:'**
  String get severity_level;

  /// No description provided for @mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @add_symptom.
  ///
  /// In en, this message translates to:
  /// **'Add Symptom'**
  String get add_symptom;

  /// No description provided for @ambulance_tracking.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Tracking'**
  String get ambulance_tracking;

  /// No description provided for @hospital_delivery.
  ///
  /// In en, this message translates to:
  /// **'Hospital Delivery'**
  String get hospital_delivery;

  /// No description provided for @patient_delivery_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Patient delivery in progress'**
  String get patient_delivery_in_progress;

  /// No description provided for @tracking_timeline.
  ///
  /// In en, this message translates to:
  /// **'Tracking Timeline'**
  String get tracking_timeline;

  /// No description provided for @dispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get dispatched;

  /// No description provided for @on_the_way.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get on_the_way;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get in_progress;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @ambulance_dispatched.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Dispatched'**
  String get ambulance_dispatched;

  /// No description provided for @arrived_at_location.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Location'**
  String get arrived_at_location;

  /// No description provided for @confirm_arrival.
  ///
  /// In en, this message translates to:
  /// **'Confirm Arrival'**
  String get confirm_arrival;

  /// No description provided for @mark_ambulance_as_arrived.
  ///
  /// In en, this message translates to:
  /// **'Mark ambulance as arrived at hospital?'**
  String get mark_ambulance_as_arrived;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @patient_delivered_successfully.
  ///
  /// In en, this message translates to:
  /// **'Patient delivered successfully!'**
  String get patient_delivered_successfully;

  /// No description provided for @failed_complete_delivery.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete delivery'**
  String get failed_complete_delivery;

  /// No description provided for @could_not_open_maps.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps'**
  String get could_not_open_maps;

  /// No description provided for @error_unable_fetch_ambulance.
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to fetch ambulance status'**
  String get error_unable_fetch_ambulance;

  /// No description provided for @cardiovascular_system.
  ///
  /// In en, this message translates to:
  /// **'❤️ Heart (Cardiovascular System)'**
  String get cardiovascular_system;

  /// No description provided for @nervous_system.
  ///
  /// In en, this message translates to:
  /// **'🧠 Brain & Nerves (Nervous System)'**
  String get nervous_system;

  /// No description provided for @respiratory_system.
  ///
  /// In en, this message translates to:
  /// **'🫁 Lungs (Respiratory System)'**
  String get respiratory_system;

  /// No description provided for @digestive_system.
  ///
  /// In en, this message translates to:
  /// **'🍽️ Stomach & Digestion (Digestive System)'**
  String get digestive_system;

  /// No description provided for @urinary_system.
  ///
  /// In en, this message translates to:
  /// **'🚽 Urine & Private Parts (Urinary System)'**
  String get urinary_system;

  /// No description provided for @musculoskeletal_system.
  ///
  /// In en, this message translates to:
  /// **'🦴 Bones & Muscles'**
  String get musculoskeletal_system;

  /// No description provided for @blood_system.
  ///
  /// In en, this message translates to:
  /// **'🩸 Blood-Related Problems'**
  String get blood_system;

  /// No description provided for @general_hormone_system.
  ///
  /// In en, this message translates to:
  /// **'🌡️ General & Hormone-Related'**
  String get general_hormone_system;

  /// No description provided for @chest_pain.
  ///
  /// In en, this message translates to:
  /// **'Chest pain or pressure'**
  String get chest_pain;

  /// No description provided for @heart_beating_fast.
  ///
  /// In en, this message translates to:
  /// **'Feeling your heart beating fast or irregularly'**
  String get heart_beating_fast;

  /// No description provided for @breathlessness.
  ///
  /// In en, this message translates to:
  /// **'Getting breathless easily'**
  String get breathlessness;

  /// No description provided for @trouble_breathing_lying.
  ///
  /// In en, this message translates to:
  /// **'Trouble breathing when lying flat'**
  String get trouble_breathing_lying;

  /// No description provided for @waking_breathless.
  ///
  /// In en, this message translates to:
  /// **'Waking up at night feeling breathless'**
  String get waking_breathless;

  /// No description provided for @fainting.
  ///
  /// In en, this message translates to:
  /// **'Fainting or feeling like you may faint'**
  String get fainting;

  /// No description provided for @swelling_extremities.
  ///
  /// In en, this message translates to:
  /// **'Swelling of feet or ankles'**
  String get swelling_extremities;

  /// No description provided for @bluish_lips.
  ///
  /// In en, this message translates to:
  /// **'Bluish lips or fingers'**
  String get bluish_lips;

  /// No description provided for @very_tired.
  ///
  /// In en, this message translates to:
  /// **'Feeling very tired'**
  String get very_tired;

  /// No description provided for @leg_pain_walking.
  ///
  /// In en, this message translates to:
  /// **'Leg pain while walking'**
  String get leg_pain_walking;

  /// No description provided for @headache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get headache;

  /// No description provided for @dizziness.
  ///
  /// In en, this message translates to:
  /// **'Feeling dizzy or spinning'**
  String get dizziness;

  /// No description provided for @blacking_out.
  ///
  /// In en, this message translates to:
  /// **'Blacking out'**
  String get blacking_out;

  /// No description provided for @seizures.
  ///
  /// In en, this message translates to:
  /// **'Fits / seizures'**
  String get seizures;

  /// No description provided for @weakness_limbs.
  ///
  /// In en, this message translates to:
  /// **'Weakness in arms or legs'**
  String get weakness_limbs;

  /// No description provided for @numbness.
  ///
  /// In en, this message translates to:
  /// **'Numbness or \'pins and needles\' feeling'**
  String get numbness;

  /// No description provided for @trouble_speaking.
  ///
  /// In en, this message translates to:
  /// **'Trouble speaking'**
  String get trouble_speaking;

  /// No description provided for @blurred_vision.
  ///
  /// In en, this message translates to:
  /// **'Blurred or double vision'**
  String get blurred_vision;

  /// No description provided for @memory_problems.
  ///
  /// In en, this message translates to:
  /// **'Memory problems or confusion'**
  String get memory_problems;

  /// No description provided for @shaking_hands.
  ///
  /// In en, this message translates to:
  /// **'Shaking of hands'**
  String get shaking_hands;

  /// No description provided for @difficulty_walking.
  ///
  /// In en, this message translates to:
  /// **'Difficulty walking or keeping balance'**
  String get difficulty_walking;

  /// No description provided for @cough.
  ///
  /// In en, this message translates to:
  /// **'Cough'**
  String get cough;

  /// No description provided for @mucus_cough.
  ///
  /// In en, this message translates to:
  /// **'Mucus/phlegm while coughing'**
  String get mucus_cough;

  /// No description provided for @blood_cough.
  ///
  /// In en, this message translates to:
  /// **'Blood in cough'**
  String get blood_cough;

  /// No description provided for @whistling_breathing.
  ///
  /// In en, this message translates to:
  /// **'Whistling sound while breathing'**
  String get whistling_breathing;

  /// No description provided for @chest_pain_breathing.
  ///
  /// In en, this message translates to:
  /// **'Chest pain while breathing deeply'**
  String get chest_pain_breathing;

  /// No description provided for @noisy_breathing.
  ///
  /// In en, this message translates to:
  /// **'Noisy breathing'**
  String get noisy_breathing;

  /// No description provided for @fever_cough.
  ///
  /// In en, this message translates to:
  /// **'Fever with cough'**
  String get fever_cough;

  /// No description provided for @night_sweating.
  ///
  /// In en, this message translates to:
  /// **'Night sweating'**
  String get night_sweating;

  /// No description provided for @weight_loss.
  ///
  /// In en, this message translates to:
  /// **'Weight loss'**
  String get weight_loss;

  /// No description provided for @poor_appetite.
  ///
  /// In en, this message translates to:
  /// **'Poor appetite'**
  String get poor_appetite;

  /// No description provided for @feeling_nausea.
  ///
  /// In en, this message translates to:
  /// **'Feeling like vomiting'**
  String get feeling_nausea;

  /// No description provided for @vomiting.
  ///
  /// In en, this message translates to:
  /// **'Vomiting'**
  String get vomiting;

  /// No description provided for @burning_chest.
  ///
  /// In en, this message translates to:
  /// **'Burning in chest or throat (acidity)'**
  String get burning_chest;

  /// No description provided for @stomach_pain.
  ///
  /// In en, this message translates to:
  /// **'Stomach pain'**
  String get stomach_pain;

  /// No description provided for @bloated_stomach.
  ///
  /// In en, this message translates to:
  /// **'Bloated stomach'**
  String get bloated_stomach;

  /// No description provided for @difficulty_swallowing.
  ///
  /// In en, this message translates to:
  /// **'Difficulty swallowing food'**
  String get difficulty_swallowing;

  /// No description provided for @loose_motions.
  ///
  /// In en, this message translates to:
  /// **'Loose motions'**
  String get loose_motions;

  /// No description provided for @constipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get constipation;

  /// No description provided for @blood_stools.
  ///
  /// In en, this message translates to:
  /// **'Blood in stools or black stools'**
  String get blood_stools;

  /// No description provided for @jaundice.
  ///
  /// In en, this message translates to:
  /// **'Yellowing of eyes/skin (jaundice)'**
  String get jaundice;

  /// No description provided for @burning_urination.
  ///
  /// In en, this message translates to:
  /// **'Burning while passing urine'**
  String get burning_urination;

  /// No description provided for @frequent_urination.
  ///
  /// In en, this message translates to:
  /// **'Going to the toilet very often'**
  String get frequent_urination;

  /// No description provided for @sudden_urge.
  ///
  /// In en, this message translates to:
  /// **'Sudden urge to pass urine'**
  String get sudden_urge;

  /// No description provided for @nocturia.
  ///
  /// In en, this message translates to:
  /// **'Waking up at night to pass urine'**
  String get nocturia;

  /// No description provided for @blood_urine.
  ///
  /// In en, this message translates to:
  /// **'Blood in urine'**
  String get blood_urine;

  /// No description provided for @low_urine.
  ///
  /// In en, this message translates to:
  /// **'Passing very little urine'**
  String get low_urine;

  /// No description provided for @lower_back_pain.
  ///
  /// In en, this message translates to:
  /// **'Pain in lower back or sides'**
  String get lower_back_pain;

  /// No description provided for @urine_leakage.
  ///
  /// In en, this message translates to:
  /// **'Leakage of urine'**
  String get urine_leakage;

  /// No description provided for @sexual_problems.
  ///
  /// In en, this message translates to:
  /// **'Sexual problems'**
  String get sexual_problems;

  /// No description provided for @joint_pain.
  ///
  /// In en, this message translates to:
  /// **'Joint pain'**
  String get joint_pain;

  /// No description provided for @joint_swelling.
  ///
  /// In en, this message translates to:
  /// **'Swelling of joints'**
  String get joint_swelling;

  /// No description provided for @morning_stiffness.
  ///
  /// In en, this message translates to:
  /// **'Stiffness in the morning'**
  String get morning_stiffness;

  /// No description provided for @muscle_pain.
  ///
  /// In en, this message translates to:
  /// **'Muscle pain'**
  String get muscle_pain;

  /// No description provided for @weak_muscles.
  ///
  /// In en, this message translates to:
  /// **'Weak muscles'**
  String get weak_muscles;

  /// No description provided for @difficulty_joint_movement.
  ///
  /// In en, this message translates to:
  /// **'Difficulty moving joints'**
  String get difficulty_joint_movement;

  /// No description provided for @bent_bones.
  ///
  /// In en, this message translates to:
  /// **'Bent or changed shape of bones'**
  String get bent_bones;

  /// No description provided for @back_pain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get back_pain;

  /// No description provided for @feeling_weak_tired.
  ///
  /// In en, this message translates to:
  /// **'Feeling weak or tired'**
  String get feeling_weak_tired;

  /// No description provided for @pale_skin.
  ///
  /// In en, this message translates to:
  /// **'Pale skin'**
  String get pale_skin;

  /// No description provided for @easy_bruising.
  ///
  /// In en, this message translates to:
  /// **'Getting bruises easily'**
  String get easy_bruising;

  /// No description provided for @gum_bleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding from gums'**
  String get gum_bleeding;

  /// No description provided for @frequent_infections.
  ///
  /// In en, this message translates to:
  /// **'Getting infections often'**
  String get frequent_infections;

  /// No description provided for @swollen_glands.
  ///
  /// In en, this message translates to:
  /// **'Swollen glands in neck/armpit/groin'**
  String get swollen_glands;

  /// No description provided for @fever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get fever;

  /// No description provided for @sudden_weight_change.
  ///
  /// In en, this message translates to:
  /// **'Sudden weight gain or loss'**
  String get sudden_weight_change;

  /// No description provided for @temperature_sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Feeling too hot or too cold'**
  String get temperature_sensitivity;

  /// No description provided for @excessive_thirst.
  ///
  /// In en, this message translates to:
  /// **'Feeling very thirsty'**
  String get excessive_thirst;

  /// No description provided for @excessive_urination.
  ///
  /// In en, this message translates to:
  /// **'Passing urine very often'**
  String get excessive_urination;

  /// No description provided for @excessive_hunger.
  ///
  /// In en, this message translates to:
  /// **'Feeling very hungry'**
  String get excessive_hunger;

  /// No description provided for @excess_sweating.
  ///
  /// In en, this message translates to:
  /// **'Excess sweating'**
  String get excess_sweating;

  /// No description provided for @hair_fall.
  ///
  /// In en, this message translates to:
  /// **'Hair fall'**
  String get hair_fall;

  /// No description provided for @irregular_periods.
  ///
  /// In en, this message translates to:
  /// **'Irregular periods'**
  String get irregular_periods;

  /// No description provided for @symptoms_submitted_successfully.
  ///
  /// In en, this message translates to:
  /// **'✅ Symptoms submitted successfully!'**
  String get symptoms_submitted_successfully;

  /// No description provided for @error_message.
  ///
  /// In en, this message translates to:
  /// **'❌ Error: '**
  String get error_message;

  /// No description provided for @nearby_hospitals.
  ///
  /// In en, this message translates to:
  /// **'🏥 Nearby Hospitals'**
  String get nearby_hospitals;

  /// No description provided for @location_error.
  ///
  /// In en, this message translates to:
  /// **'Location error: '**
  String get location_error;

  /// No description provided for @error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get error_loading;

  /// No description provided for @no_hospitals_found_message.
  ///
  /// In en, this message translates to:
  /// **'No hospitals found'**
  String get no_hospitals_found_message;

  /// No description provided for @beds_label.
  ///
  /// In en, this message translates to:
  /// **'Beds: '**
  String get beds_label;

  /// No description provided for @oxygen_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get oxygen_yes;

  /// No description provided for @oxygen_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get oxygen_no;

  /// No description provided for @oxygen_label.
  ///
  /// In en, this message translates to:
  /// **'Oxygen: '**
  String get oxygen_label;

  /// No description provided for @navigate_button.
  ///
  /// In en, this message translates to:
  /// **'📍 Navigate'**
  String get navigate_button;

  /// No description provided for @ward_general.
  ///
  /// In en, this message translates to:
  /// **'General Ward'**
  String get ward_general;

  /// No description provided for @ward_semi_private.
  ///
  /// In en, this message translates to:
  /// **'Semi-private Ward'**
  String get ward_semi_private;

  /// No description provided for @ward_private.
  ///
  /// In en, this message translates to:
  /// **'Private Ward'**
  String get ward_private;

  /// No description provided for @ward_isolation.
  ///
  /// In en, this message translates to:
  /// **'Isolation Ward'**
  String get ward_isolation;

  /// No description provided for @micu.
  ///
  /// In en, this message translates to:
  /// **'MICU'**
  String get micu;

  /// No description provided for @sicu.
  ///
  /// In en, this message translates to:
  /// **'SICU'**
  String get sicu;

  /// No description provided for @nicu.
  ///
  /// In en, this message translates to:
  /// **'NICU'**
  String get nicu;

  /// No description provided for @ccu.
  ///
  /// In en, this message translates to:
  /// **'CCU'**
  String get ccu;

  /// No description provided for @picu.
  ///
  /// In en, this message translates to:
  /// **'PICU'**
  String get picu;

  /// No description provided for @ventilators.
  ///
  /// In en, this message translates to:
  /// **'Ventilators'**
  String get ventilators;

  /// No description provided for @monitors.
  ///
  /// In en, this message translates to:
  /// **'Monitors'**
  String get monitors;

  /// No description provided for @emergency_24x7_label.
  ///
  /// In en, this message translates to:
  /// **'Emergency 24x7'**
  String get emergency_24x7_label;

  /// No description provided for @defibrillator.
  ///
  /// In en, this message translates to:
  /// **'Defibrillator'**
  String get defibrillator;

  /// No description provided for @central_oxygen_label.
  ///
  /// In en, this message translates to:
  /// **'Central Oxygen'**
  String get central_oxygen_label;

  /// No description provided for @in_house_pharmacy.
  ///
  /// In en, this message translates to:
  /// **'In-house Pharmacy'**
  String get in_house_pharmacy;

  /// No description provided for @pharmacy_24x7.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy 24x7'**
  String get pharmacy_24x7;

  /// No description provided for @oxygen_cylinders.
  ///
  /// In en, this message translates to:
  /// **'Oxygen Cylinders'**
  String get oxygen_cylinders;

  /// No description provided for @essential_drugs.
  ///
  /// In en, this message translates to:
  /// **'Essential Drugs'**
  String get essential_drugs;

  /// No description provided for @doctors_count.
  ///
  /// In en, this message translates to:
  /// **'Doctors Count'**
  String get doctors_count;

  /// No description provided for @nurses_count.
  ///
  /// In en, this message translates to:
  /// **'Nurses Count'**
  String get nurses_count;

  /// No description provided for @icu_trained_staff.
  ///
  /// In en, this message translates to:
  /// **'ICU Trained Staff'**
  String get icu_trained_staff;

  /// No description provided for @anesthetist_available.
  ///
  /// In en, this message translates to:
  /// **'Anesthetist Available'**
  String get anesthetist_available;

  /// No description provided for @blood_bank.
  ///
  /// In en, this message translates to:
  /// **'Blood Bank'**
  String get blood_bank;

  /// No description provided for @dialysis_unit.
  ///
  /// In en, this message translates to:
  /// **'Dialysis Unit'**
  String get dialysis_unit;

  /// No description provided for @cssd.
  ///
  /// In en, this message translates to:
  /// **'CSSD'**
  String get cssd;

  /// No description provided for @mortuary.
  ///
  /// In en, this message translates to:
  /// **'Mortuary'**
  String get mortuary;

  /// No description provided for @user_found.
  ///
  /// In en, this message translates to:
  /// **'User found'**
  String get user_found;

  /// No description provided for @user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get user_not_found;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @password_reset_successful.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get password_reset_successful;

  /// No description provided for @password_reset_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get password_reset_failed;

  /// No description provided for @account_recovery.
  ///
  /// In en, this message translates to:
  /// **'Account recovery'**
  String get account_recovery;

  /// No description provided for @enter_email_or_username.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username to recover your account'**
  String get enter_email_or_username;

  /// No description provided for @email_or_username.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get email_or_username;

  /// No description provided for @verify_account.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verify_account;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get back_to_login;

  /// No description provided for @set_new_password.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get set_new_password;

  /// No description provided for @enter_secure_password.
  ///
  /// In en, this message translates to:
  /// **'Enter a new secure password for your account'**
  String get enter_secure_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @password_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully'**
  String get password_updated_successfully;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @health_risk_report.
  ///
  /// In en, this message translates to:
  /// **'Health Risk Report'**
  String get health_risk_report;

  /// No description provided for @download_health_report.
  ///
  /// In en, this message translates to:
  /// **'Download Health Report (PDF)'**
  String get download_health_report;

  /// No description provided for @view_recommended_hospitals.
  ///
  /// In en, this message translates to:
  /// **'View Recommended Hospitals'**
  String get view_recommended_hospitals;

  /// No description provided for @generating_report.
  ///
  /// In en, this message translates to:
  /// **'Generating Health Report PDF...'**
  String get generating_report;

  /// No description provided for @report_downloaded_successfully.
  ///
  /// In en, this message translates to:
  /// **'Health report downloaded successfully!'**
  String get report_downloaded_successfully;

  /// No description provided for @error_downloading_report.
  ///
  /// In en, this message translates to:
  /// **'Error downloading report: '**
  String get error_downloading_report;

  /// No description provided for @profile_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profile_updated_successfully;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @select_hospital.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select_hospital;

  /// No description provided for @selected_hospital.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected_hospital;

  /// No description provided for @by_relevance.
  ///
  /// In en, this message translates to:
  /// **'By Relevance'**
  String get by_relevance;

  /// No description provided for @by_distance.
  ///
  /// In en, this message translates to:
  /// **'By Distance'**
  String get by_distance;

  /// No description provided for @icu_resources.
  ///
  /// In en, this message translates to:
  /// **'ICU Resources'**
  String get icu_resources;

  /// No description provided for @emergency_life_saving.
  ///
  /// In en, this message translates to:
  /// **'Emergency & Life-saving'**
  String get emergency_life_saving;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// No description provided for @pharmacy_supplies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy & Supplies'**
  String get pharmacy_supplies;

  /// No description provided for @human_resources.
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get human_resources;

  /// No description provided for @support_resources.
  ///
  /// In en, this message translates to:
  /// **'Support Resources'**
  String get support_resources;

  /// No description provided for @report_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Report downloaded successfully!'**
  String get report_downloaded;

  /// No description provided for @authentication_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please login again.'**
  String get authentication_required;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized: Government access required'**
  String get unauthorized;

  /// No description provided for @download_failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: '**
  String get download_failed;

  /// No description provided for @password_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Password must have 6+ characters, a special character, and start with uppercase'**
  String get password_validation_error;

  /// No description provided for @email_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Email must contain \'@\' symbol'**
  String get email_validation_error;

  /// No description provided for @phone_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 10 digits'**
  String get phone_validation_error;
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
      <String>['en', 'hi', 'kn', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
