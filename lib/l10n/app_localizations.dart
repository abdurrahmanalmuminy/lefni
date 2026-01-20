import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Control Panel'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Today navigation item
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Contracts navigation item
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get contracts;

  /// Cases navigation item
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// Sessions navigation item
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// Appointments navigation item
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// Clients navigation item
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// Documents navigation item
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// Tasks navigation item
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Tools navigation item
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// Help navigation item
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Reports tab
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Invoices tab
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// Users tab
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Welcome message prefix
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Demo page placeholder message
  ///
  /// In en, this message translates to:
  /// **'This is a demo page. You can replace this content with any content you want.'**
  String get demoPageMessage;

  /// User name display
  ///
  /// In en, this message translates to:
  /// **'Abdurrahman Hussein'**
  String get userName;

  /// Issued invoices menu item
  ///
  /// In en, this message translates to:
  /// **'Issued Invoices'**
  String get invoicesIssued;

  /// Received invoices menu item
  ///
  /// In en, this message translates to:
  /// **'Received Invoices'**
  String get invoicesReceived;

  /// Pending invoices menu item
  ///
  /// In en, this message translates to:
  /// **'Pending Invoices'**
  String get invoicesPending;

  /// Paid invoices menu item
  ///
  /// In en, this message translates to:
  /// **'Paid Invoices'**
  String get invoicesPaid;

  /// Create invoice menu item
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// Invoice settings menu item
  ///
  /// In en, this message translates to:
  /// **'Invoice Settings'**
  String get invoiceSettings;

  /// User contracts menu item
  ///
  /// In en, this message translates to:
  /// **'User Contracts'**
  String get userContracts;

  /// User tasks menu item
  ///
  /// In en, this message translates to:
  /// **'User Tasks'**
  String get userTasks;

  /// User ratings menu item
  ///
  /// In en, this message translates to:
  /// **'User Ratings'**
  String get userRatings;

  /// User statistics menu item
  ///
  /// In en, this message translates to:
  /// **'User Statistics'**
  String get userStats;

  /// Users list menu item
  ///
  /// In en, this message translates to:
  /// **'Users List'**
  String get usersList;

  /// Add user menu item
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// User roles menu item
  ///
  /// In en, this message translates to:
  /// **'User Roles'**
  String get userRoles;

  /// User permissions menu item
  ///
  /// In en, this message translates to:
  /// **'User Permissions'**
  String get userPermissions;

  /// User activity menu item
  ///
  /// In en, this message translates to:
  /// **'User Activity'**
  String get userActivity;

  /// User settings menu item
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// Monthly reports menu item
  ///
  /// In en, this message translates to:
  /// **'Monthly Reports'**
  String get monthlyReports;

  /// Yearly reports menu item
  ///
  /// In en, this message translates to:
  /// **'Yearly Reports'**
  String get yearlyReports;

  /// Cases statistics menu item
  ///
  /// In en, this message translates to:
  /// **'Cases Statistics'**
  String get casesStats;

  /// Client reports menu item
  ///
  /// In en, this message translates to:
  /// **'Client Reports'**
  String get clientReports;

  /// Financial reports menu item
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get financialReports;

  /// Performance reports menu item
  ///
  /// In en, this message translates to:
  /// **'Performance Reports'**
  String get performanceReports;

  /// No description provided for @contractsManagement.
  ///
  /// In en, this message translates to:
  /// **'Contracts Management'**
  String get contractsManagement;

  /// No description provided for @createContract.
  ///
  /// In en, this message translates to:
  /// **'Create Contract'**
  String get createContract;

  /// No description provided for @editContract.
  ///
  /// In en, this message translates to:
  /// **'Edit Contract'**
  String get editContract;

  /// No description provided for @contractArchive.
  ///
  /// In en, this message translates to:
  /// **'Contract Archive'**
  String get contractArchive;

  /// No description provided for @searchContracts.
  ///
  /// In en, this message translates to:
  /// **'Search Contracts'**
  String get searchContracts;

  /// No description provided for @linkToClient.
  ///
  /// In en, this message translates to:
  /// **'Link to Client'**
  String get linkToClient;

  /// No description provided for @linkToCase.
  ///
  /// In en, this message translates to:
  /// **'Link to Case'**
  String get linkToCase;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get uploadFiles;

  /// No description provided for @electronicSignature.
  ///
  /// In en, this message translates to:
  /// **'Electronic Signature'**
  String get electronicSignature;

  /// No description provided for @contractTypes.
  ///
  /// In en, this message translates to:
  /// **'Contract Types'**
  String get contractTypes;

  /// No description provided for @clientContracts.
  ///
  /// In en, this message translates to:
  /// **'Client Contracts'**
  String get clientContracts;

  /// No description provided for @lawyerContracts.
  ///
  /// In en, this message translates to:
  /// **'Lawyer Contracts'**
  String get lawyerContracts;

  /// No description provided for @engineeringContracts.
  ///
  /// In en, this message translates to:
  /// **'Engineering Office Contracts'**
  String get engineeringContracts;

  /// No description provided for @accountantContracts.
  ///
  /// In en, this message translates to:
  /// **'Accountant Contracts'**
  String get accountantContracts;

  /// No description provided for @clientsManagement.
  ///
  /// In en, this message translates to:
  /// **'Clients Management'**
  String get clientsManagement;

  /// No description provided for @clientProfile.
  ///
  /// In en, this message translates to:
  /// **'Client Profile'**
  String get clientProfile;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @clientDocuments.
  ///
  /// In en, this message translates to:
  /// **'Client Documents'**
  String get clientDocuments;

  /// No description provided for @officeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Office Documents'**
  String get officeDocuments;

  /// No description provided for @serviceCatalog.
  ///
  /// In en, this message translates to:
  /// **'Service Catalog'**
  String get serviceCatalog;

  /// No description provided for @individualServices.
  ///
  /// In en, this message translates to:
  /// **'Individual Services'**
  String get individualServices;

  /// No description provided for @businessServices.
  ///
  /// In en, this message translates to:
  /// **'Business Services'**
  String get businessServices;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @powerOfAttorney.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney'**
  String get powerOfAttorney;

  /// No description provided for @notarization.
  ///
  /// In en, this message translates to:
  /// **'Notarization'**
  String get notarization;

  /// No description provided for @caseStudy.
  ///
  /// In en, this message translates to:
  /// **'Case Study'**
  String get caseStudy;

  /// No description provided for @reconciliationRequest.
  ///
  /// In en, this message translates to:
  /// **'Reconciliation Request'**
  String get reconciliationRequest;

  /// No description provided for @governance.
  ///
  /// In en, this message translates to:
  /// **'Governance'**
  String get governance;

  /// No description provided for @intellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get intellectualProperty;

  /// No description provided for @annualContracts.
  ///
  /// In en, this message translates to:
  /// **'Annual Contracts'**
  String get annualContracts;

  /// No description provided for @debtCollection.
  ///
  /// In en, this message translates to:
  /// **'Debt Collection'**
  String get debtCollection;

  /// No description provided for @arbitration.
  ///
  /// In en, this message translates to:
  /// **'Arbitration'**
  String get arbitration;

  /// No description provided for @casesManagement.
  ///
  /// In en, this message translates to:
  /// **'Cases Management'**
  String get casesManagement;

  /// No description provided for @addCase.
  ///
  /// In en, this message translates to:
  /// **'Add Case'**
  String get addCase;

  /// No description provided for @caseStatus.
  ///
  /// In en, this message translates to:
  /// **'Case Status'**
  String get caseStatus;

  /// No description provided for @potentialCase.
  ///
  /// In en, this message translates to:
  /// **'Potential'**
  String get potentialCase;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @closedCase.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedCase;

  /// No description provided for @caseNumber.
  ///
  /// In en, this message translates to:
  /// **'Case Number'**
  String get caseNumber;

  /// No description provided for @caseType.
  ///
  /// In en, this message translates to:
  /// **'Case Type'**
  String get caseType;

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get court;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @responsibleLawyer.
  ///
  /// In en, this message translates to:
  /// **'Responsible Lawyer'**
  String get responsibleLawyer;

  /// No description provided for @caseFiles.
  ///
  /// In en, this message translates to:
  /// **'Case Files'**
  String get caseFiles;

  /// No description provided for @letters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get letters;

  /// No description provided for @objections.
  ///
  /// In en, this message translates to:
  /// **'Objections'**
  String get objections;

  /// No description provided for @memos.
  ///
  /// In en, this message translates to:
  /// **'Memos'**
  String get memos;

  /// No description provided for @linkSessions.
  ///
  /// In en, this message translates to:
  /// **'Link Sessions'**
  String get linkSessions;

  /// No description provided for @linkReports.
  ///
  /// In en, this message translates to:
  /// **'Link Reports'**
  String get linkReports;

  /// No description provided for @tasksSessions.
  ///
  /// In en, this message translates to:
  /// **'Tasks & Sessions'**
  String get tasksSessions;

  /// No description provided for @officeTasks.
  ///
  /// In en, this message translates to:
  /// **'Office Tasks'**
  String get officeTasks;

  /// No description provided for @assignTask.
  ///
  /// In en, this message translates to:
  /// **'Assign Task'**
  String get assignTask;

  /// No description provided for @taskDates.
  ///
  /// In en, this message translates to:
  /// **'Task Dates'**
  String get taskDates;

  /// No description provided for @taskAlerts.
  ///
  /// In en, this message translates to:
  /// **'Task Alerts'**
  String get taskAlerts;

  /// No description provided for @progressReports.
  ///
  /// In en, this message translates to:
  /// **'Progress Reports'**
  String get progressReports;

  /// No description provided for @courtSessions.
  ///
  /// In en, this message translates to:
  /// **'Court Sessions'**
  String get courtSessions;

  /// No description provided for @sessionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Session Schedule'**
  String get sessionSchedule;

  /// No description provided for @sessionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Session Alerts'**
  String get sessionAlerts;

  /// No description provided for @sessionReport.
  ///
  /// In en, this message translates to:
  /// **'Session Report'**
  String get sessionReport;

  /// No description provided for @appointmentScheduling.
  ///
  /// In en, this message translates to:
  /// **'Appointment Scheduling'**
  String get appointmentScheduling;

  /// No description provided for @internalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Internal Alerts'**
  String get internalAlerts;

  /// No description provided for @smsAlerts.
  ///
  /// In en, this message translates to:
  /// **'SMS Alerts'**
  String get smsAlerts;

  /// No description provided for @financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financial;

  /// No description provided for @feesManagement.
  ///
  /// In en, this message translates to:
  /// **'Fees Management'**
  String get feesManagement;

  /// No description provided for @receivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get receivables;

  /// No description provided for @receiptVouchers.
  ///
  /// In en, this message translates to:
  /// **'Receipt Vouchers'**
  String get receiptVouchers;

  /// No description provided for @monthlyFinancial.
  ///
  /// In en, this message translates to:
  /// **'Monthly Financial Reports'**
  String get monthlyFinancial;

  /// No description provided for @collaborators.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get collaborators;

  /// No description provided for @cooperatingLawyers.
  ///
  /// In en, this message translates to:
  /// **'Cooperating Lawyers'**
  String get cooperatingLawyers;

  /// No description provided for @agencies.
  ///
  /// In en, this message translates to:
  /// **'Agencies'**
  String get agencies;

  /// No description provided for @taskUpdates.
  ///
  /// In en, this message translates to:
  /// **'Task Updates'**
  String get taskUpdates;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @studentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Student Registration'**
  String get studentRegistration;

  /// No description provided for @cv.
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get cv;

  /// Cooperation type field
  ///
  /// In en, this message translates to:
  /// **'Cooperation Type'**
  String get cooperationType;

  /// Training cooperation type
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @caseReferral.
  ///
  /// In en, this message translates to:
  /// **'Case Referral'**
  String get caseReferral;

  /// No description provided for @consultationBooking.
  ///
  /// In en, this message translates to:
  /// **'Consultation Booking'**
  String get consultationBooking;

  /// No description provided for @engineeringOffices.
  ///
  /// In en, this message translates to:
  /// **'Engineering Offices'**
  String get engineeringOffices;

  /// No description provided for @technicalReports.
  ///
  /// In en, this message translates to:
  /// **'Technical Reports'**
  String get technicalReports;

  /// No description provided for @constructionDefects.
  ///
  /// In en, this message translates to:
  /// **'Construction Defects'**
  String get constructionDefects;

  /// No description provided for @realEstateDisputes.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Disputes'**
  String get realEstateDisputes;

  /// No description provided for @legalAccountants.
  ///
  /// In en, this message translates to:
  /// **'Legal Accountants'**
  String get legalAccountants;

  /// No description provided for @accountingReports.
  ///
  /// In en, this message translates to:
  /// **'Accounting Reports'**
  String get accountingReports;

  /// No description provided for @financialReportRequest.
  ///
  /// In en, this message translates to:
  /// **'Financial Report Request'**
  String get financialReportRequest;

  /// No description provided for @translators.
  ///
  /// In en, this message translates to:
  /// **'Translators'**
  String get translators;

  /// No description provided for @translationTasks.
  ///
  /// In en, this message translates to:
  /// **'Translation Tasks'**
  String get translationTasks;

  /// No description provided for @translatedFiles.
  ///
  /// In en, this message translates to:
  /// **'Translated Files'**
  String get translatedFiles;

  /// No description provided for @invoicesAndRevenues.
  ///
  /// In en, this message translates to:
  /// **'Invoices and Revenues'**
  String get invoicesAndRevenues;

  /// No description provided for @clientFees.
  ///
  /// In en, this message translates to:
  /// **'Client Fees'**
  String get clientFees;

  /// No description provided for @collectionRecord.
  ///
  /// In en, this message translates to:
  /// **'Collection Record'**
  String get collectionRecord;

  /// No description provided for @expensesAndPayments.
  ///
  /// In en, this message translates to:
  /// **'Expenses and Payments'**
  String get expensesAndPayments;

  /// No description provided for @collaboratorAccounts.
  ///
  /// In en, this message translates to:
  /// **'Collaborator Accounts'**
  String get collaboratorAccounts;

  /// Login page title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign in loading state
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// Email required validation error
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Password required validation error
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// Access denied message for unauthorized users
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view this section'**
  String get noPermission;

  /// User role label in profile
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Link to switch to login
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Link to switch to sign up
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Success message after sign up
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// Sign up error message
  ///
  /// In en, this message translates to:
  /// **'Sign up failed'**
  String get signUpFailed;

  /// Success message for password reset
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get passwordResetEmailSent;

  /// Button to send password reset link
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number required validation error
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Name required validation error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Step label
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// Of label for steps
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get stepOf;

  /// Account information step title
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// Profile information step title
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// Specialization field for lawyers
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// License number field
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// Firm name field
  ///
  /// In en, this message translates to:
  /// **'Firm Name'**
  String get firmName;

  /// University field for students
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// Bank account field
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// Training program checkbox for students
  ///
  /// In en, this message translates to:
  /// **'Training Program'**
  String get isTraining;

  /// Case sourcing cooperation type
  ///
  /// In en, this message translates to:
  /// **'Case Sourcing'**
  String get caseSourcing;

  /// Success message after creating user
  ///
  /// In en, this message translates to:
  /// **'User created successfully'**
  String get userCreatedSuccessfully;

  /// Success message after creating appointment
  ///
  /// In en, this message translates to:
  /// **'Appointment created successfully'**
  String get appointmentCreatedSuccessfully;

  /// Success message after uploading document
  ///
  /// In en, this message translates to:
  /// **'Document uploaded successfully'**
  String get documentUploadedSuccessfully;

  /// Success message after creating client
  ///
  /// In en, this message translates to:
  /// **'Client created successfully'**
  String get clientCreatedSuccessfully;

  /// Success message after creating case
  ///
  /// In en, this message translates to:
  /// **'Case created successfully'**
  String get caseCreatedSuccessfully;

  /// Success message after creating task
  ///
  /// In en, this message translates to:
  /// **'Task created successfully'**
  String get taskCreatedSuccessfully;

  /// Success message after creating session
  ///
  /// In en, this message translates to:
  /// **'Session created successfully'**
  String get sessionCreatedSuccessfully;

  /// Success message after creating contract
  ///
  /// In en, this message translates to:
  /// **'Contract created successfully'**
  String get contractCreatedSuccessfully;

  /// Success message after creating finance record
  ///
  /// In en, this message translates to:
  /// **'Finance record created successfully'**
  String get financeRecordCreatedSuccessfully;

  /// Validation message for client selection
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get pleaseSelectClient;

  /// Validation message for date/time selection
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get pleaseSelectDateTime;

  /// Validation message for file selection
  ///
  /// In en, this message translates to:
  /// **'Please select a file'**
  String get pleaseSelectFile;

  /// Validation message for case selection
  ///
  /// In en, this message translates to:
  /// **'Please select a case'**
  String get pleaseSelectCase;

  /// Validation message for lawyer selection
  ///
  /// In en, this message translates to:
  /// **'Please select a lawyer'**
  String get pleaseSelectLawyer;

  /// Validation message for assignee selection
  ///
  /// In en, this message translates to:
  /// **'Please select assignee'**
  String get pleaseSelectAssignee;

  /// Validation message for related item selection
  ///
  /// In en, this message translates to:
  /// **'Please select related item'**
  String get pleaseSelectRelatedItem;

  /// Validation message for date selection
  ///
  /// In en, this message translates to:
  /// **'Please select start and due dates'**
  String get pleaseSelectDates;

  /// Validation message for lead lawyer selection
  ///
  /// In en, this message translates to:
  /// **'Please select a lead lawyer'**
  String get pleaseSelectLeadLawyer;

  /// Validation message for finance item
  ///
  /// In en, this message translates to:
  /// **'Service and price are required'**
  String get serviceAndPriceRequired;

  /// Validation message for finance items
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item'**
  String get pleaseAddAtLeastOneItem;

  /// Date and time field label
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// Purpose field label
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Optional client field label
  ///
  /// In en, this message translates to:
  /// **'Client (Optional)'**
  String get clientOptional;

  /// Optional case field label
  ///
  /// In en, this message translates to:
  /// **'Case (Optional)'**
  String get caseOptional;

  /// Type field label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Status field label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Optional due date field label
  ///
  /// In en, this message translates to:
  /// **'Due Date (Optional)'**
  String get dueDateOptional;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Assign to field label
  ///
  /// In en, this message translates to:
  /// **'Assign To'**
  String get assignTo;

  /// Related to field label
  ///
  /// In en, this message translates to:
  /// **'Related To'**
  String get relatedTo;

  /// Priority field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Start date field label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// Due date field label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Add tag field label
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// Items label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Subtotal label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// VAT label
  ///
  /// In en, this message translates to:
  /// **'VAT (15%)'**
  String get vat;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Optional notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// Location field label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Optional meeting link field label
  ///
  /// In en, this message translates to:
  /// **'Meeting Link (Optional)'**
  String get meetingLinkOptional;

  /// Party type field label
  ///
  /// In en, this message translates to:
  /// **'Party Type'**
  String get partyType;

  /// Content field label
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// Optional file selection label
  ///
  /// In en, this message translates to:
  /// **'Select files (Optional)'**
  String get selectFilesOptional;

  /// File selection label
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// Date/time selection label
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTime;

  /// None option label
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Has agency checkbox label
  ///
  /// In en, this message translates to:
  /// **'Has Agency'**
  String get hasAgency;

  /// Agency number field label
  ///
  /// In en, this message translates to:
  /// **'Agency Number'**
  String get agencyNumber;

  /// Agency file selection label
  ///
  /// In en, this message translates to:
  /// **'Select agency file'**
  String get selectAgencyFile;

  /// ID number field label
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// CR number field label
  ///
  /// In en, this message translates to:
  /// **'CR Number'**
  String get crNumber;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Address required validation error
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// Lead lawyer field label
  ///
  /// In en, this message translates to:
  /// **'Lead Lawyer'**
  String get leadLawyer;

  /// Optional judge field label
  ///
  /// In en, this message translates to:
  /// **'Judge (Optional)'**
  String get judgeOptional;

  /// Lawyer field label
  ///
  /// In en, this message translates to:
  /// **'Lawyer'**
  String get lawyer;

  /// Add item button label
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// Add lawyer dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Lawyer'**
  String get addLawyer;

  /// Add student dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudent;

  /// Add engineer dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Engineer'**
  String get addEngineer;

  /// Add accountant dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Accountant'**
  String get addAccountant;

  /// Add translator dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Translator'**
  String get addTranslator;

  /// Start date selection label
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// Due date selection label
  ///
  /// In en, this message translates to:
  /// **'Select due date'**
  String get selectDueDate;

  /// Due date selection label for optional field
  ///
  /// In en, this message translates to:
  /// **'Select due date'**
  String get selectDueDateOptional;

  /// Service field label
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Optional quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity (Optional)'**
  String get quantityOptional;

  /// Optional description field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Validation message for required client
  ///
  /// In en, this message translates to:
  /// **'Client is required'**
  String get clientRequired;

  /// Validation message for required case
  ///
  /// In en, this message translates to:
  /// **'Case is required'**
  String get caseRequired;

  /// Validation message for required lawyer
  ///
  /// In en, this message translates to:
  /// **'Lawyer is required'**
  String get lawyerRequired;

  /// Validation message for required lead lawyer
  ///
  /// In en, this message translates to:
  /// **'Lead lawyer is required'**
  String get leadLawyerRequired;

  /// Validation message for required title
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Validation message for required description
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// Validation message for required assignee
  ///
  /// In en, this message translates to:
  /// **'Assignee is required'**
  String get assigneeRequired;

  /// Validation message for required case number
  ///
  /// In en, this message translates to:
  /// **'Case number is required'**
  String get caseNumberRequired;

  /// Validation message for required court name
  ///
  /// In en, this message translates to:
  /// **'Court name is required'**
  String get courtNameRequired;

  /// Validation message for required circuit
  ///
  /// In en, this message translates to:
  /// **'Circuit is required'**
  String get circuitRequired;

  /// Validation message for required identity number
  ///
  /// In en, this message translates to:
  /// **'Identity number is required'**
  String get identityNumberRequired;

  /// Validation message for required location
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// Validation message for required purpose
  ///
  /// In en, this message translates to:
  /// **'Purpose is required'**
  String get purposeRequired;

  /// Validation message for required content
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get contentRequired;

  /// Case field label
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get caseLabel;

  /// Contract field label
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contractLabel;

  /// Civil case category
  ///
  /// In en, this message translates to:
  /// **'Civil'**
  String get caseCategoryCivil;

  /// Criminal case category
  ///
  /// In en, this message translates to:
  /// **'Criminal'**
  String get caseCategoryCriminal;

  /// Labor case category
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get caseCategoryLabor;

  /// Intellectual Property case category
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get caseCategoryIntellectualProperty;

  /// Commercial case category
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get caseCategoryCommercial;

  /// Administrative case category
  ///
  /// In en, this message translates to:
  /// **'Administrative'**
  String get caseCategoryAdministrative;

  /// Prospect case status
  ///
  /// In en, this message translates to:
  /// **'Prospect'**
  String get caseStatusProspect;

  /// Active case status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get caseStatusActive;

  /// Closed case status
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get caseStatusClosed;

  /// Client party type
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get partyTypeClient;

  /// Lawyer party type
  ///
  /// In en, this message translates to:
  /// **'Lawyer'**
  String get partyTypeLawyer;

  /// Engineer party type
  ///
  /// In en, this message translates to:
  /// **'Engineer'**
  String get partyTypeEngineer;

  /// Accountant party type
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get partyTypeAccountant;

  /// Translator party type
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get partyTypeTranslator;

  /// Court hearing session type
  ///
  /// In en, this message translates to:
  /// **'Court Hearing'**
  String get sessionTypeCourtHearing;

  /// Client meeting session type
  ///
  /// In en, this message translates to:
  /// **'Client Meeting'**
  String get sessionTypeClientMeeting;

  /// Consultation session type
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get sessionTypeConsultation;

  /// Client document category
  ///
  /// In en, this message translates to:
  /// **'Client Document'**
  String get documentCategoryClientDoc;

  /// Office document category
  ///
  /// In en, this message translates to:
  /// **'Office Document'**
  String get documentCategoryOfficeDoc;

  /// Contract document category
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get documentCategoryContract;

  /// Report document category
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get documentCategoryReport;

  /// Other document category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get documentCategoryOther;

  /// Case related type
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get relatedTypeCase;

  /// Client related type
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get relatedTypeClient;

  /// Contract related type
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get relatedTypeContract;

  /// Low task priority
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLow;

  /// Medium task priority
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get taskPriorityMedium;

  /// High task priority
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHigh;

  /// Payment method field label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Payment method required validation error
  ///
  /// In en, this message translates to:
  /// **'Payment method is required'**
  String get paymentMethodRequired;

  /// Cash payment method
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// Bank transfer payment method
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentMethodBankTransfer;

  /// Check payment method
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get paymentMethodCheck;

  /// Credit card payment method
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get paymentMethodCreditCard;

  /// Online payment method
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get paymentMethodOnlinePayment;

  /// Other payment method
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentMethodOther;

  /// Button to send verification code
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// Button to verify code
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// Status when code is verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Button to complete phone signup
  ///
  /// In en, this message translates to:
  /// **'Complete Sign Up'**
  String get completeSignUp;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
