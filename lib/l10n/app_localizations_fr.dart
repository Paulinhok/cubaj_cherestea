// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get home => 'Accueil';

  @override
  String get newCubingMenu => 'Nouveau cubage';

  @override
  String get cubingListMenu => 'Listes de cubage';

  @override
  String get info => 'À propos';

  @override
  String get currency => '€';

  @override
  String get infoPageTitle => 'Infos cubage';

  @override
  String get infoPage => 'Page d\'informations';

  @override
  String get infoContent => 'L\'application de Cubage de Bois est destinée au calcul du volume en mètres cubes du bois d\'œuvre dimensionné, tel que les planches, liteaux, madriers, chevrons ou poutres.';

  @override
  String get infoContent2 => 'Qu\'est-ce qu\'un mètre cube ?';

  @override
  String get infoContent3 => ' Le mètre cube est l\'une des ';

  @override
  String get infoContent4 => 'unités de mesure standardisées, ';

  @override
  String get infoContent5 => 'utilisée dans une variété de domaines, mais le plus souvent dans le secteur de la construction. Le mètre cube, noté dans le Système International (SI) mc ou m³, est une unité de mesure du volume.';

  @override
  String get infoContent6 => 'Comment calcule-t-on un mètre cube ?';

  @override
  String get infoContent7 => ' Le mètre cube est calculé en prenant en compte les dimensions de trois grandeurs, à savoir la longueur, la largeur et la hauteur. Pour mieux comprendre, on peut imaginer une boîte avec des côtés de 1 mètre, un cube, dont on multipliera les trois dimensions : longueur de 1 m, largeur de 1 m et hauteur de 1 m. On obtiendra ainsi un mètre cube, qui représente le volume du cube ou de la boîte.';

  @override
  String get infoContent8 => 'Formule du mètre cube';

  @override
  String get infoContent9 => ' Pour calculer 1 mètre cube d\'un matériau (avec la formule de calcul du cubage), il est nécessaire de connaître les dimensions exactes, mesurées, des éléments qui constituent le volume. Ainsi, la formule générale pour calculer un mètre cube est :';

  @override
  String get infoContent10 => 'Volume = Longueur (mètres) x Largeur (mètres) x Hauteur (mètres)';

  @override
  String get infoContent11 => ' La valeur obtenue représente le volume en mètres cubes, mais il est important de noter que nous n\'aurons pas toujours des valeurs claires et linéaires à mesurer.\nDans certaines situations, des approximations (unités de mesure en mètres) peuvent être nécessaires, car certaines faces peuvent présenter des obstacles qui doivent être pris en compte.\nPar exemple, si vous voulez calculer combien de mètres cubes se trouvent sur une palette de planches, voici les calculs à effectuer :';

  @override
  String get infoContent12 => 'Longueur = 4,5 m;\nLargeur = 0,9 m;\nHauteur = 0,8 m;\nVolume de la palette de bois = 4,5 m x 0,9 m x 0,8 m = 3,24 m³';

  @override
  String get appTitle => 'Cubage de Bois';

  @override
  String get newCubing => 'NOUVEAU CUBAGE';

  @override
  String get cubingList => 'LISTES DE CUBAGE';

  @override
  String get listOfCubbingTitle => 'Liste de cubage';

  @override
  String get insertNameOfList => 'Entrez le nom de la liste';

  @override
  String get nameOfList => 'Nom de la liste';

  @override
  String get cancel => 'ANNULER';

  @override
  String get save => 'ENREGISTRER';

  @override
  String get nameListisEmpty => 'La liste doit avoir un nom ! Veuillez entrer un nom !';

  @override
  String get listSnackBar => 'La liste';

  @override
  String get listAddedSuccessfully => 'a été ajoutée avec succès à la base de données.';

  @override
  String get listExist => 'existe déjà ! Veuillez entrer un autre nom.';

  @override
  String get newCubingTitle => 'Nouveau cubage';

  @override
  String get length => 'Longueur : ';

  @override
  String get meters => 'mètres';

  @override
  String get width => 'Largeur : ';

  @override
  String get centimeters => 'centimètres';

  @override
  String get thichness => 'Thichness: ';

  @override
  String get calculateVolume => 'CALCULER VOLUME';

  @override
  String get errorMessage => 'Valeurs numériques uniquement';

  @override
  String get volumeTable => 'Tableau des volumes';

  @override
  String get number => 'Numéro: ';

  @override
  String get result => 'Résultat';

  @override
  String get statsList => 'Statut de la liste';

  @override
  String get totalVolume => 'Volume total';

  @override
  String get viewList => 'Voir la liste';

  @override
  String get finishList => 'Terminer la liste';

  @override
  String get pretPerMeterTitle => 'Prix par m³';

  @override
  String get insertPricePerM => 'Entrez le prix par m³';

  @override
  String get pricePerMeter => 'Prix par m³';

  @override
  String get validePrice => 'Prix valide !';

  @override
  String get resultOfCubingTitle => 'Résultat du cubage';

  @override
  String get listVolume => 'VOLUME :';

  @override
  String get unitPrice => 'Prix unitaire';

  @override
  String get totalPrice => 'Prix total';

  @override
  String get detailedList => 'Liste détaillée';

  @override
  String get generatePdf => 'Générer PDF';

  @override
  String get sendEmail => 'Envoyer Email';

  @override
  String get pdfGenerateSuccessfull => 'PDF généré avec succès !';

  @override
  String get openPdf => 'Ouvrir PDF';

  @override
  String get listsCubingTitle => 'Listes de cubage';

  @override
  String get intNr => 'Numéro';

  @override
  String get nameList => 'Nom de la liste';

  @override
  String get volume => 'Volume';

  @override
  String get date => 'Date';

  @override
  String get cubajMasuratoriTitle => 'Liste de mesures :';

  @override
  String get buc => 'Pièces';

  @override
  String get lengthTable => 'Longueur';

  @override
  String get widthTable => 'Largeur';

  @override
  String get thichnessTable => 'Thickness';

  @override
  String get cubingTable => 'Volume';

  @override
  String get pricePerMeterMasuratori => 'Prix par m³';

  @override
  String get pieces => 'Pièces';

  @override
  String get deleteList => 'Supprimer la liste';

  @override
  String get edit => 'Modifier';

  @override
  String get updatePrice => 'Mettre à jour le prix';

  @override
  String get measuringAdd => 'Ajouté avec succès !';

  @override
  String get editPageTitle => 'Modifier';

  @override
  String get numberEdit => 'Numéro';

  @override
  String get piecesEdit => 'Pièces  ';

  @override
  String get thichnessEdit => 'Épaisseur';

  @override
  String get lengthEdit => 'Longueur ';

  @override
  String get widthEdit => 'Largeur';

  @override
  String get editCubing => 'MODIFIER CUBAGE';

  @override
  String get cubing => 'Volume';

  @override
  String get deleteCubing => 'SUPPRIMER CUBAGE';

  @override
  String get valuesUnder0 => 'Valeurs supérieures à 0 uniquement !';

  @override
  String get diameterOver19 => 'Diamètre trop grand !';

  @override
  String get cubingAdd => 'Cubage mis à jour !';

  @override
  String get cubingDelete => 'Cubage supprimé !';
}
