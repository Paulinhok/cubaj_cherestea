import 'package:intl/intl.dart';
import 'package:scandura/SQLite/cubaj_masuratori.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:flutter/material.dart';
import 'package:scandura/SQLite/measuring.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:scandura/l10n/app_localizations.dart';

class ResultOfCubbing extends StatefulWidget {
  ResultOfCubbing(
      {super.key,
      required this.cubajTotal,
      required this.pretTotal,
      required this.pretUnitar,
      required this.numeLista});

  final double cubajTotal;
  final double pretTotal;
  final double pretUnitar;
  final String numeLista;

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/2551495382'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';

  @override
  State<ResultOfCubbing> createState() => _ResultOfCubbingState();
}

class _ResultOfCubbingState extends State<ResultOfCubbing> {
  List<Map<String, dynamic>> cubajData = [];

  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4079464500254319/6009254972'
      : 'ca-app-pub-4079464500254319/7276661656';

  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'ro_RO');

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadMediumNativeAd();

    double pretTotal = widget.cubajTotal * widget.pretUnitar;
    cubajData = [
      {
        'Cubaj total': '${widget.cubajTotal.toStringAsFixed(3)} m³',
        'Pret unitar': '${widget.pretUnitar} RON/m³',
        'Pret total': '${pretTotal.toStringAsFixed(3)} RON',
      }
    ];
    sendValues();
  }

  Future<void> sendValues() async {
    await DatabaseHelper()
        .updatePretUnitar(widget.numeLista, widget.pretUnitar);
    await DatabaseHelper().updatePretTotal(widget.numeLista);
  }

  Future<void> navigateToCubajMasuratori() async {
    try {
      double pretUnitar = await DatabaseHelper().getPretUnitar(widget.numeLista);
      double cubajTotal = await DatabaseHelper().getCubajTotal(widget.numeLista);

      double pretTotal = cubajTotal * pretUnitar;

      if (!mounted) return; // Ensure the widget is still in the tree
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CubajMasuratoriPage(
            numeLista: widget.numeLista,
            pretTotal: pretTotal,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to CubajMasuratoriPage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to navigate to CubajMasuratoriPage')),
      );
    }
  }

  List<CubajMasuratori> _combineRows(List<CubajMasuratori> measuring) {
    final Map<String, CubajMasuratori> combined = {};
    final List<CubajMasuratori> separate = [];

    for (var masuratori in measuring) {
      if (masuratori.latime! < 20) {
        String key =
            '${masuratori.lungime}_${masuratori.latime}_${masuratori.grosime}_${masuratori.cubajBucata}';
        if (combined.containsKey(key)) {
          combined[key]!.bucati = masuratori.bucati! + combined[key]!.bucati!;
        } else {
          combined[key] = masuratori;
        }
      } else {
        separate.add(masuratori);
      }
    }
    return combined.values.toList() + separate;
  }

  Future<void> generatePDF(
      BuildContext context, String numeLista, double pretTotal) async {
    final pdf = pw.Document();
    final measuring = await DatabaseHelper().getMeasuring(numeLista);
    final listaCubaj = await DatabaseHelper().getListDetails(numeLista);

    final cubajTotal = await DatabaseHelper().getCubajTotal(numeLista);
    final totalBucati = measuring.fold(0, (sum, item) => sum + item.bucati!);
    final pretTotal = listaCubaj.pretTotal!;
    final pretPerMeter = listaCubaj.getPretUnitar();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                  "${AppLocalizations.of(this.context)!.listVolume} $numeLista"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.of(this.context)!.intNr,
                  AppLocalizations.of(this.context)!.buc,
                  AppLocalizations.of(this.context)!.lengthTable,
                  AppLocalizations.of(this.context)!.widthTable,
                  AppLocalizations.of(this.context)!.thichnessTable,
                  AppLocalizations.of(this.context)!.cubingTable,
                ]
                    .map((header) => pw.Text(header,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        )))
                    .toList(),
                data: _combineRows(measuring).asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  CubajMasuratori masuratori = entry.value;

                  return [
                    pw.Text(index.toString()),
                    pw.Text(masuratori.bucati.toString()),
                    pw.Text('${masuratori.lungime} m'),
                    pw.Text('${masuratori.latime} cm'),
                    pw.Text('${masuratori.grosime} cm'),
                    '${(masuratori.cubajBucata! * masuratori.bucati!).toStringAsFixed(3)} m³',
                  ];
                }).toList()
                  ..add([
                    pw.Text('${AppLocalizations.of(this.context)!.pieces}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(totalBucati.toString(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    '',
                    pw.Text(
                        '${AppLocalizations.of(this.context)!.totalVolume}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${cubajTotal.toStringAsFixed(2)} m³',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ])
                  ..add([
                    pw.Text(
                        '${AppLocalizations.of(this.context)!.pricePerMeterMasuratori}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '${currencyFormat.format(pretPerMeter)} ${AppLocalizations.of(this.context)!.currency}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    '',
                    pw.Text('${AppLocalizations.of(this.context)!.totalPrice}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '${currencyFormat.format(pretTotal)} ${AppLocalizations.of(this.context)!.currency}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellDecoration: (index, data, rowNum) {
                  return pw.BoxDecoration(
                    color:
                        rowNum % 2 == 0 ? PdfColors.grey300 : PdfColors.white,
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$numeLista.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.pdfGenerateSuccessfull),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.openPdf,
          onPressed: () {
            OpenFile.open(file.path);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _loadAd();
    super.dispose();
  }

  void _loadMediumNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            print('$NativeAd failedToLoad: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: const Color(0xfffffbed),
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
          centerTitle: true,
          titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
          backgroundColor: Color(0xFF008B8B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          // leading: ... (from left button)...
          //actions: ... from right button...
          actions: [
            PopupMenuButton(
              icon: Icon(
                Icons.menu_rounded,
                color: Colors.white,
              ),
              onSelected: (result) {
                if (result == 0) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                } else if (result == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListOfCubbingPage()));
                } else if (result == 2) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ListeCubaj()));
                }
              },
              itemBuilder: (BuildContext bc) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: ListTile(
                      leading: Icon(Icons.menu_open_rounded),
                      title: Text(AppLocalizations.of(context)!.home),
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.new_label_outlined),
                      title: Text(AppLocalizations.of(context)!.newCubingMenu),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.list),
                      title: Text(AppLocalizations.of(context)!.cubingListMenu),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              if (_nativeAdIsLoaded && _nativeAd != null)
                SizedBox(
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.99,
                  child: AdWidget(ad: _nativeAd!),
                )
              else
                SizedBox(
                  height: screenHeight * 0.45,
                ),
                
              SizedBox(height: 15),
              Text(
                '${AppLocalizations.of(context)!.listVolume} ${widget.numeLista.toUpperCase()}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Flexible(
                child: DataTable(
                  columnSpacing: screenWidth * 0.05,
                  border: TableBorder(
                    top: BorderSide(),
                    verticalInside: BorderSide(),
                    bottom: BorderSide(),
                  ),
                  columns: [
                    DataColumn(
                        label: Text(AppLocalizations.of(context)!.totalVolume)),
                    DataColumn(
                        label: Text(AppLocalizations.of(context)!.unitPrice)),
                    DataColumn(
                        label: Text(AppLocalizations.of(context)!.totalPrice)),
                  ],
                  rows: cubajData
                      .map((data) => DataRow(cells: [
                            DataCell(Text(data['Cubaj total'])),
                            DataCell(Text(
                                '${currencyFormat.format(widget.pretUnitar)} ${AppLocalizations.of(context)!.currency}')),
                            DataCell(Text(
                                '${currencyFormat.format(widget.pretTotal)}${AppLocalizations.of(context)!.currency}')),
                          ]))
                      .toList(),
                ),
              ),
              SizedBox(height: 5),
              // Butoane de la tabel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      navigateToCubajMasuratori();
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(screenWidth * 0.3, screenHeight * 0.05),
                        backgroundColor: const Color(0xFF008B8B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Text(
                      AppLocalizations.of(context)!.detailedList,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: screenWidth * 0.04, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      generatePDF(context, widget.numeLista, widget.pretTotal);
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize:
                            Size(screenWidth * 0.31, screenHeight * 0.05),
                        backgroundColor: const Color(0xFF008B8B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Text(
                      AppLocalizations.of(context)!.generatePdf,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: screenWidth * 0.04, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      sendValues();
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(screenWidth * 0.3, screenHeight * 0.05),
                        backgroundColor: const Color(0xFF008B8B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Text(
                      AppLocalizations.of(context)!.sendEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: screenWidth * 0.04, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ));
  }
}
