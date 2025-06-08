// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get newCubingMenu => 'New Volume';

  @override
  String get cubingListMenu => 'Volume Lists';

  @override
  String get info => 'About';

  @override
  String get currency => '\$';

  @override
  String get infoPageTitle => 'About Application';

  @override
  String get infoPage => 'Information Page';

  @override
  String get infoContent => 'The Timber Volume Application is designed for calculating the volume in cubic meters of dimensioned working wood, such as boards, planks, beams, or squares.';

  @override
  String get infoContent2 => 'What is a cubic meter?';

  @override
  String get infoContent3 => 'The cubic meter is one of ';

  @override
  String get infoContent4 => 'the standardized units of measurement, ';

  @override
  String get infoContent5 => 'used in a variety of fields, but most often in the construction sector. The cubic meter, denoted in the International System (SI) as mc or m³, is a unit of volume measurement.';

  @override
  String get infoContent6 => 'How is the cubic meter calculated?';

  @override
  String get infoContent7 => 'The cubic meter is calculated by considering the magnitude of three dimensions, namely length, width, and height. For better understanding, we can think of a box with a side of 1 meter, a cube, whose three dimensions we will multiply: length of 1 m, width of 1 m, and height also of 1 m. Thus, we will obtain a cubic meter, which represents the volume of the cube or box.';

  @override
  String get infoContent8 => 'Cubic meter formula';

  @override
  String get infoContent9 => 'To calculate 1 cubic meter of a material (using the volume calculation formula), it is necessary to know the exact, measured dimensions of the elements that constitute the volume. Thus, the general formula by which a cubic meter can be calculated is:';

  @override
  String get infoContent10 => 'Volume = Length (meters) x Width (meters) x Height (meters)';

  @override
  String get infoContent11 => 'The resulting value represents the volume in cubic meters, but it should be noted that not every time will we have clear, linear values to measure.\nIn some situations, approximations (meter measurement units) may be needed because on some sides there may be obstacles that need to be considered.\nFor example, if you want to calculate how many cubic meters are on a pallet of boards, here are the calculations you need to make:';

  @override
  String get infoContent12 => 'Length = 4.5 m;\nWidth = 0.9 m;\nHeight = 0.8 m;\nVolume of the timber pallet = 4.5 m x 0.9 m x 0.8 m = 3.24 m³';

  @override
  String get appTitle => 'Timber Volume';

  @override
  String get newCubing => 'NEW VOLUME';

  @override
  String get cubingList => 'VOLUME LISTS';

  @override
  String get listOfCubbingTitle => 'List of Volume';

  @override
  String get insertNameOfList => 'Insert name for volume list';

  @override
  String get nameOfList => 'Name of List';

  @override
  String get cancel => 'CANCEL';

  @override
  String get save => 'SAVE';

  @override
  String get nameListisEmpty => 'The list must have a name! Please enter a name!';

  @override
  String get listSnackBar => 'The list';

  @override
  String get listAddedSuccessfully => 'has been successfully added to the database.';

  @override
  String get listExist => 'already exists! Please enter another name.';

  @override
  String get newCubingTitle => 'New Volume';

  @override
  String get length => 'Length:    ';

  @override
  String get meters => 'meters';

  @override
  String get width => 'Width: ';

  @override
  String get centimeters => 'centimeters';

  @override
  String get thichness => 'Thichness: ';

  @override
  String get calculateVolume => 'GET VOLUME';

  @override
  String get errorMessage => 'Enter only numeric values ';

  @override
  String get volumeTable => 'Volume table';

  @override
  String get number => 'Number: ';

  @override
  String get result => 'Result';

  @override
  String get statsList => 'List Status';

  @override
  String get totalVolume => 'Total volume';

  @override
  String get viewList => 'View list';

  @override
  String get finishList => 'Finish list';

  @override
  String get pretPerMeterTitle => 'Price per cubic meter³';

  @override
  String get insertPricePerM => 'Enter price per cubic meter';

  @override
  String get pricePerMeter => 'Price per meter³';

  @override
  String get validePrice => 'Enter a valid price!';

  @override
  String get resultOfCubingTitle => 'Round Wood Volume';

  @override
  String get listVolume => 'LIST VOLUME: ';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get detailedList => 'Detailed List';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get pdfGenerateSuccessfull => 'PDF was generated successfully!';

  @override
  String get openPdf => 'Open';

  @override
  String get listsCubingTitle => 'Volume Lists';

  @override
  String get intNr => 'Nr.';

  @override
  String get nameList => 'List Name';

  @override
  String get volume => 'Volume';

  @override
  String get date => 'Date';

  @override
  String get cubajMasuratoriTitle => 'List:';

  @override
  String get buc => 'Pc.';

  @override
  String get lengthTable => 'Length';

  @override
  String get widthTable => 'Width';

  @override
  String get thichnessTable => 'Thickness';

  @override
  String get cubingTable => 'Volume';

  @override
  String get pricePerMeterMasuratori => 'Price per m³';

  @override
  String get pieces => 'Pieces ';

  @override
  String get deleteList => 'Delete List';

  @override
  String get edit => 'Editing';

  @override
  String get updatePrice => 'Update Price';

  @override
  String get measuringAdd => 'Measurements added successfully!';

  @override
  String get editPageTitle => 'Editing Volume';

  @override
  String get numberEdit => 'Number';

  @override
  String get piecesEdit => 'Pieces   ';

  @override
  String get thichnessEdit => 'Thickness';

  @override
  String get lengthEdit => 'Length     ';

  @override
  String get widthEdit => 'Width   ';

  @override
  String get editCubing => 'EDITING';

  @override
  String get cubing => 'Volume';

  @override
  String get deleteCubing => 'DELETE VOLUME';

  @override
  String get valuesUnder0 => 'Values ​​cannot be less than or equal to 0!';

  @override
  String get diameterOver19 => 'The diameter is too large for multiple pieces!';

  @override
  String get cubingAdd => 'The cube has been updated successfully!';

  @override
  String get cubingDelete => 'The cube was successfully deleted!';
}
