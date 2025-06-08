import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ro.dart';

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
    Locale('es'),
    Locale('fr'),
    Locale('ro')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @newCubingMenu.
  ///
  /// In en, this message translates to:
  /// **'New Volume'**
  String get newCubingMenu;

  /// No description provided for @cubingListMenu.
  ///
  /// In en, this message translates to:
  /// **'Volume Lists'**
  String get cubingListMenu;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get info;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get currency;

  /// No description provided for @infoPageTitle.
  ///
  /// In en, this message translates to:
  /// **'About Application'**
  String get infoPageTitle;

  /// No description provided for @infoPage.
  ///
  /// In en, this message translates to:
  /// **'Information Page'**
  String get infoPage;

  /// No description provided for @infoContent.
  ///
  /// In en, this message translates to:
  /// **'The Timber Volume Application is designed for calculating the volume in cubic meters of dimensioned working wood, such as boards, planks, beams, or squares.'**
  String get infoContent;

  /// No description provided for @infoContent2.
  ///
  /// In en, this message translates to:
  /// **'What is a cubic meter?'**
  String get infoContent2;

  /// No description provided for @infoContent3.
  ///
  /// In en, this message translates to:
  /// **'The cubic meter is one of '**
  String get infoContent3;

  /// No description provided for @infoContent4.
  ///
  /// In en, this message translates to:
  /// **'the standardized units of measurement, '**
  String get infoContent4;

  /// No description provided for @infoContent5.
  ///
  /// In en, this message translates to:
  /// **'used in a variety of fields, but most often in the construction sector. The cubic meter, denoted in the International System (SI) as mc or m³, is a unit of volume measurement.'**
  String get infoContent5;

  /// No description provided for @infoContent6.
  ///
  /// In en, this message translates to:
  /// **'How is the cubic meter calculated?'**
  String get infoContent6;

  /// No description provided for @infoContent7.
  ///
  /// In en, this message translates to:
  /// **'The cubic meter is calculated by considering the magnitude of three dimensions, namely length, width, and height. For better understanding, we can think of a box with a side of 1 meter, a cube, whose three dimensions we will multiply: length of 1 m, width of 1 m, and height also of 1 m. Thus, we will obtain a cubic meter, which represents the volume of the cube or box.'**
  String get infoContent7;

  /// No description provided for @infoContent8.
  ///
  /// In en, this message translates to:
  /// **'Cubic meter formula'**
  String get infoContent8;

  /// No description provided for @infoContent9.
  ///
  /// In en, this message translates to:
  /// **'To calculate 1 cubic meter of a material (using the volume calculation formula), it is necessary to know the exact, measured dimensions of the elements that constitute the volume. Thus, the general formula by which a cubic meter can be calculated is:'**
  String get infoContent9;

  /// No description provided for @infoContent10.
  ///
  /// In en, this message translates to:
  /// **'Volume = Length (meters) x Width (meters) x Height (meters)'**
  String get infoContent10;

  /// No description provided for @infoContent11.
  ///
  /// In en, this message translates to:
  /// **'The resulting value represents the volume in cubic meters, but it should be noted that not every time will we have clear, linear values to measure.\nIn some situations, approximations (meter measurement units) may be needed because on some sides there may be obstacles that need to be considered.\nFor example, if you want to calculate how many cubic meters are on a pallet of boards, here are the calculations you need to make:'**
  String get infoContent11;

  /// No description provided for @infoContent12.
  ///
  /// In en, this message translates to:
  /// **'Length = 4.5 m;\nWidth = 0.9 m;\nHeight = 0.8 m;\nVolume of the timber pallet = 4.5 m x 0.9 m x 0.8 m = 3.24 m³'**
  String get infoContent12;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Timber Volume'**
  String get appTitle;

  /// No description provided for @newCubing.
  ///
  /// In en, this message translates to:
  /// **'NEW VOLUME'**
  String get newCubing;

  /// No description provided for @cubingList.
  ///
  /// In en, this message translates to:
  /// **'VOLUME LISTS'**
  String get cubingList;

  /// No description provided for @listOfCubbingTitle.
  ///
  /// In en, this message translates to:
  /// **'List of Volume'**
  String get listOfCubbingTitle;

  /// No description provided for @insertNameOfList.
  ///
  /// In en, this message translates to:
  /// **'Insert name for volume list'**
  String get insertNameOfList;

  /// No description provided for @nameOfList.
  ///
  /// In en, this message translates to:
  /// **'Name of List'**
  String get nameOfList;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @nameListisEmpty.
  ///
  /// In en, this message translates to:
  /// **'The list must have a name! Please enter a name!'**
  String get nameListisEmpty;

  /// No description provided for @listSnackBar.
  ///
  /// In en, this message translates to:
  /// **'The list'**
  String get listSnackBar;

  /// No description provided for @listAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'has been successfully added to the database.'**
  String get listAddedSuccessfully;

  /// No description provided for @listExist.
  ///
  /// In en, this message translates to:
  /// **'already exists! Please enter another name.'**
  String get listExist;

  /// No description provided for @newCubingTitle.
  ///
  /// In en, this message translates to:
  /// **'New Volume'**
  String get newCubingTitle;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length:    '**
  String get length;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get meters;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width: '**
  String get width;

  /// No description provided for @centimeters.
  ///
  /// In en, this message translates to:
  /// **'centimeters'**
  String get centimeters;

  /// No description provided for @thichness.
  ///
  /// In en, this message translates to:
  /// **'Thichness: '**
  String get thichness;

  /// No description provided for @calculateVolume.
  ///
  /// In en, this message translates to:
  /// **'GET VOLUME'**
  String get calculateVolume;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter only numeric values '**
  String get errorMessage;

  /// No description provided for @volumeTable.
  ///
  /// In en, this message translates to:
  /// **'Volume table'**
  String get volumeTable;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number: '**
  String get number;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @statsList.
  ///
  /// In en, this message translates to:
  /// **'List Status'**
  String get statsList;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get totalVolume;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'View list'**
  String get viewList;

  /// No description provided for @finishList.
  ///
  /// In en, this message translates to:
  /// **'Finish list'**
  String get finishList;

  /// No description provided for @pretPerMeterTitle.
  ///
  /// In en, this message translates to:
  /// **'Price per cubic meter³'**
  String get pretPerMeterTitle;

  /// No description provided for @insertPricePerM.
  ///
  /// In en, this message translates to:
  /// **'Enter price per cubic meter'**
  String get insertPricePerM;

  /// No description provided for @pricePerMeter.
  ///
  /// In en, this message translates to:
  /// **'Price per meter³'**
  String get pricePerMeter;

  /// No description provided for @validePrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price!'**
  String get validePrice;

  /// No description provided for @resultOfCubingTitle.
  ///
  /// In en, this message translates to:
  /// **'Round Wood Volume'**
  String get resultOfCubingTitle;

  /// No description provided for @listVolume.
  ///
  /// In en, this message translates to:
  /// **'LIST VOLUME: '**
  String get listVolume;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @detailedList.
  ///
  /// In en, this message translates to:
  /// **'Detailed List'**
  String get detailedList;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @pdfGenerateSuccessfull.
  ///
  /// In en, this message translates to:
  /// **'PDF was generated successfully!'**
  String get pdfGenerateSuccessfull;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openPdf;

  /// No description provided for @listsCubingTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume Lists'**
  String get listsCubingTitle;

  /// No description provided for @intNr.
  ///
  /// In en, this message translates to:
  /// **'Nr.'**
  String get intNr;

  /// No description provided for @nameList.
  ///
  /// In en, this message translates to:
  /// **'List Name'**
  String get nameList;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @cubajMasuratoriTitle.
  ///
  /// In en, this message translates to:
  /// **'List:'**
  String get cubajMasuratoriTitle;

  /// No description provided for @buc.
  ///
  /// In en, this message translates to:
  /// **'Pc.'**
  String get buc;

  /// No description provided for @lengthTable.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get lengthTable;

  /// No description provided for @widthTable.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get widthTable;

  /// No description provided for @thichnessTable.
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get thichnessTable;

  /// No description provided for @cubingTable.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get cubingTable;

  /// No description provided for @pricePerMeterMasuratori.
  ///
  /// In en, this message translates to:
  /// **'Price per m³'**
  String get pricePerMeterMasuratori;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces '**
  String get pieces;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get edit;

  /// No description provided for @updatePrice.
  ///
  /// In en, this message translates to:
  /// **'Update Price'**
  String get updatePrice;

  /// No description provided for @measuringAdd.
  ///
  /// In en, this message translates to:
  /// **'Measurements added successfully!'**
  String get measuringAdd;

  /// No description provided for @editPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Editing Volume'**
  String get editPageTitle;

  /// No description provided for @numberEdit.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get numberEdit;

  /// No description provided for @piecesEdit.
  ///
  /// In en, this message translates to:
  /// **'Pieces   '**
  String get piecesEdit;

  /// No description provided for @thichnessEdit.
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get thichnessEdit;

  /// No description provided for @lengthEdit.
  ///
  /// In en, this message translates to:
  /// **'Length     '**
  String get lengthEdit;

  /// No description provided for @widthEdit.
  ///
  /// In en, this message translates to:
  /// **'Width   '**
  String get widthEdit;

  /// No description provided for @editCubing.
  ///
  /// In en, this message translates to:
  /// **'EDITING'**
  String get editCubing;

  /// No description provided for @cubing.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get cubing;

  /// No description provided for @deleteCubing.
  ///
  /// In en, this message translates to:
  /// **'DELETE VOLUME'**
  String get deleteCubing;

  /// No description provided for @valuesUnder0.
  ///
  /// In en, this message translates to:
  /// **'Values ​​cannot be less than or equal to 0!'**
  String get valuesUnder0;

  /// No description provided for @diameterOver19.
  ///
  /// In en, this message translates to:
  /// **'The diameter is too large for multiple pieces!'**
  String get diameterOver19;

  /// No description provided for @cubingAdd.
  ///
  /// In en, this message translates to:
  /// **'The cube has been updated successfully!'**
  String get cubingAdd;

  /// No description provided for @cubingDelete.
  ///
  /// In en, this message translates to:
  /// **'The cube was successfully deleted!'**
  String get cubingDelete;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ro': return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
