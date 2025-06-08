import 'package:intl/intl.dart';
import 'package:scandura/SQLite/cubbing.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/edit_masuratori.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/SQLite/measuring.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:scandura/pages/price_per_meter.dart';
import 'package:scandura/utils/cubajUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:scandura/l10n/app_localizations.dart';

class CubajMasuratoriPage extends StatefulWidget {
  CubajMasuratoriPage(
      {super.key, required this.numeLista, required this.pretTotal});
  final String numeLista;
  final double pretTotal;

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/2551495382'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';

  @override
  State<CubajMasuratoriPage> createState() => _CubajMasuratoriPageState();
}

List<CubajMasuratori> _combineRows(List<CubajMasuratori> measuring) {
  final Map<String, CubajMasuratori> combined = {};
  final List<CubajMasuratori> separate = [];

  for (var masuratori in measuring) {
    // if (masuratori.latime! < 20) {
    if (masuratori.lungime != null &&
        masuratori.latime != null &&
        masuratori.grosime != null &&
        masuratori.bucati != null) {
      String key =
          '${masuratori.lungime}_${masuratori.latime}_${masuratori.grosime}';

      if (combined.containsKey(key)) {
        combined[key]!.bucati = masuratori.bucati! + combined[key]!.bucati!;

        combined[key]!.cubajBucata = CubajUtils.cubajScandura(
          combined[key]!.lungime!,
          combined[key]!.latime!,
          combined[key]!.grosime!,
        );
      } else {
        combined[key] = CubajMasuratori(
          id: masuratori.id,
          bucati: masuratori.bucati,
          lungime: masuratori.lungime,
          latime: masuratori.latime,
          grosime: masuratori.grosime,
          cubajBucata: masuratori.cubajBucata,
          numeLista: masuratori.numeLista,
        );
      }
    } else {
      print('Masuratori incomplete: $masuratori');
    }
    // } else {
    //   separate.add(masuratori);
    // }
  }

  return combined.values.toList() + separate;
}

class _CubajMasuratoriPageState extends State<CubajMasuratoriPage> {
  late Future<List<CubajMasuratori>> measuring;
  late Future<Cubaj> listaCubaj;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController totalBucatiController = TextEditingController();
  final TextEditingController pretTotalController = TextEditingController();
  final TextEditingController pretPerMeterController = TextEditingController();

  final NumberFormat currencyFormat = NumberFormat("#,##0.00", "ro_RO");

  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4079464500254319/6009254972'
      : 'ca-app-pub-4079464500254319/7276661656';

  int totalBucati = 0;
  double totalCubaj = 0;

  late Future<double> pretTotal;
  late Future<double> pretPerMeter;

  @override
  void initState() {
    super.initState();
    measuring = DatabaseHelper().getMeasuring(widget.numeLista);
    listaCubaj = DatabaseHelper().getListDetails(widget.numeLista);
    pretTotal = DatabaseHelper().getPretTotal(widget.numeLista);
    pretPerMeter = DatabaseHelper().getPretUnitar(widget.numeLista);

    DatabaseHelper().getMeasuring(widget.numeLista).then((measuring) {
      totalBucati = measuring.fold(0, (sum, item) => sum + (item.bucati ?? 0));
      totalBucatiController.text = totalBucati.toString();
    });
    DatabaseHelper().getCubajTotal(widget.numeLista).then((value) {
      setState(() {
        totalCubaj = value;
      });
    });
    DatabaseHelper().getPretTotal(widget.numeLista).then((value) {
      setState(() {
        pretTotalController.text = '${value.toStringAsFixed(2)} RON';
      });
    });
    DatabaseHelper().getPretUnitar(widget.numeLista).then((value) {
      setState(() {
        pretPerMeterController.text = '${value.toStringAsFixed(2)} RON';
      });
    });

    _loadAd();
    _loadMediumNativeAd();
  }

  generatePDF(
      BuildContext buildContext, String numeLista, double pretTotal) async {
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
                  "${AppLocalizations.of(buildContext)!.listVolume}: $numeLista"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  AppLocalizations.of(buildContext)!.intNr,
                  AppLocalizations.of(buildContext)!.buc,
                  AppLocalizations.of(buildContext)!.lengthTable,
                  AppLocalizations.of(buildContext)!.widthTable,
                  AppLocalizations.of(buildContext)!.thichnessTable,
                  AppLocalizations.of(buildContext)!.cubingTable,
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
                    pw.Text('${AppLocalizations.of(buildContext)!.pieces}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(totalBucati.toString(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    '',
                    pw.Text(
                        '${AppLocalizations.of(buildContext)!.totalVolume}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${cubajTotal.toStringAsFixed(2)} m³',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ])
                  ..add([
                    pw.Text(
                        '${AppLocalizations.of(buildContext)!.pricePerMeterMasuratori}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '${currencyFormat.format(pretPerMeter)} ${AppLocalizations.of(buildContext)!.currency}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    '',
                    pw.Text('${AppLocalizations.of(buildContext)!.totalPrice}:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '${currencyFormat.format(pretTotal)} ${AppLocalizations.of(buildContext)!.currency}',
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

    ScaffoldMessenger.of(buildContext).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(buildContext)!.pdfGenerateSuccessfull),
        action: SnackBarAction(
          label: AppLocalizations.of(buildContext)!.openPdf,
          onPressed: () {
            OpenFile.open(file.path);
          },
        ),
      ),
    );
  }

  Future<void> sendEmail() async {
    final pdfPath = generatePDF(context, widget.numeLista, widget.pretTotal);

    final Email email = Email(
      body: 'Cubajul listei ${widget.numeLista} este atasat in acest email.',
      subject: 'Cubajul listei ${widget.numeLista}',
      recipients: [emailController.text],
      attachmentPaths: [pdfPath],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email trimis cu succes!'),
      ),
    );
  }

  Future<void> deleteList() async {
    await DatabaseHelper().deleteList(widget.numeLista);

    setState(() {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return ListeCubaj();
      }));
    });
  }

  Future<void> updatePrice() async {
    await DatabaseHelper().updatePretUnitar(widget.numeLista, widget.pretTotal);

    double cubajTotal = await DatabaseHelper().getCubajTotal(widget.numeLista);
    await DatabaseHelper().getPretTotal(widget.numeLista);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PricePerMeter(
                  numeLista: widget.numeLista,
                  cubajTotal: cubajTotal,
                )));
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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
            templateType: TemplateType.small,
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
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeHeight = MediaQuery.of(context).size.height;
    double fontSize = sizeWidth * 0.03;

    return Scaffold(
        appBar: AppBar(
          title: Text(
              '${AppLocalizations.of(context)!.cubajMasuratoriTitle} ${widget.numeLista.toUpperCase()}'),
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
              // print(value);
              //   setState(() {
              //     selectedIndex = value.toString();
              //   });
              //   Navigator.pushNamed(context, value.toString());
              // },
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
        body: Column(children: [
          SizedBox(height: 5),
          if (_nativeAdIsLoaded && _nativeAd != null)
            SizedBox(
              height: sizeHeight * 0.15,
              width: sizeWidth * 0.99,
              child: AdWidget(ad: _nativeAd!),
            )
          else
            SizedBox(
              height: sizeHeight * 0.15,
            ),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: sizeWidth * 0.45,
                  height: sizeHeight * 0.05,
                  child: TextField(
                    controller: TextEditingController(
                        text: '${totalCubaj.toStringAsFixed(2)} m³'),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.totalVolume,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize * 1.7,
                    ),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: sizeWidth * 0.45,
                  height: sizeHeight * 0.05,
                  child: TextField(
                  controller: TextEditingController(
                    text: '${currencyFormat.format(double.tryParse(pretTotalController.text.replaceAll('RON', '').trim()))} ${AppLocalizations.of(context)!.currency}'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.totalPrice,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 1.4,
                  ),
                  enabled: false,
                  ),
                ),
                ],
              ),
              ),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: sizeWidth * 0.45,
                  height: sizeHeight * 0.05,
                  child: TextField(
                    controller: totalBucatiController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.pieces,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                    ),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: sizeWidth * 0.45,
                  height: sizeHeight * 0.05,
                  child: TextField(
                    controller: TextEditingController(
                    text: '${currencyFormat.format(double.tryParse(pretPerMeterController.text.replaceAll('RON', '').trim()))} ${AppLocalizations.of(context)!.currency}'),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.pricePerMeter,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                    ),
                    enabled: false,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FutureBuilder<List<CubajMasuratori>>(
                future: measuring,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Eroare: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Nu există masuratori salvate.'));
                  } else {
                    // int totalBucati = snapshot.data!
                    //     .fold(0, (sum, item) => sum + item.bucati!);
                    // double totalCubaj = snapshot.data!.fold(
                    //     0,
                    //     (sum, item) =>
                    //         sum + (item.cubajBucata! * item.bucati!));

                    // Future<double> pretTotal =
                    //     DatabaseHelper().getPretTotal(widget.numeLista);
                    // Future<double> pretPerMeter =
                    //     DatabaseHelper().getPretUnitar(widget.numeLista);

                    return LayoutBuilder(builder: (context, constraints) {
                      double columnWidth = constraints.maxWidth / 5;

                      return Center(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                                horizontalMargin: 0,
                                columnSpacing: 0,
                                border: TableBorder.all(),
                                columns: [
                                  DataColumn(
                                      label: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.4,
                                          child: Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              AppLocalizations.of(context)!
                                                  .intNr))),
                                  DataColumn(
                                      label: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.7,
                                          child: Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              AppLocalizations.of(context)!
                                                  .buc))),
                                  DataColumn(
                                      label: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 1,
                                          child: Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              AppLocalizations.of(context)!
                                                  .lengthTable))),
                                  DataColumn(
                                      label: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 1,
                                          child: Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              AppLocalizations.of(context)!
                                                  .widthTable))),
                                  DataColumn(
                                      label: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.9,
                                          child: Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              AppLocalizations.of(context)!
                                                  .thichnessTable))),
                                  DataColumn(
                                      label: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.9,
                                          child: Text(
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              AppLocalizations.of(context)!
                                                  .cubing))),
                                ],
                                rows: _combineRows(snapshot.data!)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key + 1;
                                  CubajMasuratori masuratori = entry.value;
                                  return DataRow(cells: [
                                    DataCell(
                                        Center(child: Text(index.toString()))),
                                    DataCell(Center(
                                        child: Text(
                                            masuratori.bucati.toString()))),
                                    DataCell(Center(
                                        child:
                                            Text('${masuratori.lungime} cm'))),
                                    DataCell(Center(
                                        child:
                                            Text('${masuratori.latime} cm'))),
                                    DataCell(Center(
                                        child:
                                            Text('${masuratori.grosime} cm'))),
                                    DataCell(Center(
                                        child: Text(
                                            '${(CubajUtils.cubajScandura(masuratori.lungime!, masuratori.latime!, masuratori.grosime!) * masuratori.bucati!).toStringAsFixed(3)} m³'))),
                                  ]);
                                }).toList()

                                //   ..add(DataRow(cells: [
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 1.1,
                                //             child: Text(
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold),
                                //               AppLocalizations.of(context)!
                                //                   .pricePerMeterMasuratori,
                                //               textAlign: TextAlign.center,
                                //             )))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 0.6,
                                //             child: Text(
                                //                 style: TextStyle(
                                //                     fontWeight: FontWeight.bold),
                                //                 AppLocalizations.of(context)!
                                //                     .pieces)))),
                                //     DataCell(Container(
                                //         color: Color(0xFF008B8B),
                                //         alignment: Alignment.center,
                                //         width: columnWidth * 0.8,
                                //         child: Text(''))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 1.1,
                                //             child: Text(
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold),
                                //               AppLocalizations.of(context)!
                                //                   .totalPrice,
                                //               textAlign: TextAlign.center,
                                //             )))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 0.8,
                                //             child: Text('')))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 1.1,
                                //             child: Text(
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold),
                                //               AppLocalizations.of(context)!
                                //                   .totalVolume,
                                //               textAlign: TextAlign.center,
                                //             )))),
                                //   ]))
                                // ..add(
                                //   DataRow(cells: [
                                //     DataCell(Container(
                                //         color: Color(0xFF008B8B),
                                //         alignment: Alignment.center,
                                //         width: columnWidth * 1.1,
                                //         child: FutureBuilder<double>(
                                //           future: pretPerMeter,
                                //           builder: (context, snapshot) {
                                //             if (snapshot.connectionState ==
                                //                 ConnectionState.waiting) {
                                //               return const CircularProgressIndicator();
                                //             } else if (snapshot.hasError) {
                                //               return Text(
                                //                   'Eroare: ${snapshot.error}');
                                //             } else {
                                //               return Text(
                                //                 style: TextStyle(
                                //                     fontWeight: FontWeight.bold),
                                //                 '${snapshot.data!.toStringAsFixed(2)} RON',
                                //                 textAlign: TextAlign.center,
                                //               );
                                //             }
                                //           },
                                //         ))),
                                //     DataCell(Container(
                                //         color: Color(0xFF008B8B),
                                //         alignment: Alignment.center,
                                //         width: columnWidth * 0.6,
                                //         child: Text(
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.bold),
                                //             totalBucati.toString()))),
                                //     DataCell(Container(
                                //         color: Color(0xFF008B8B),
                                //         alignment: Alignment.center,
                                //         width: columnWidth * 0.8,
                                //         child: Text(''))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 1.1,
                                //             child: FutureBuilder<double>(
                                //               future: pretTotal,
                                //               builder: (context, snapshot) {
                                //                 if (snapshot.connectionState ==
                                //                     ConnectionState.waiting) {
                                //                   return const CircularProgressIndicator();
                                //                 } else if (snapshot.hasError) {
                                //                   return Text(
                                //                       'Eroare: ${snapshot.error}');
                                //                 } else {
                                //                   return Text(
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold),
                                //                     '${snapshot.data!.toStringAsFixed(2)} RON',
                                //                     textAlign: TextAlign.center,
                                //                   );
                                //                 }
                                //               },
                                //             )))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 0.8,
                                //             child: Text('')))),
                                //     DataCell(Center(
                                //         child: Container(
                                //             color: Color(0xFF008B8B),
                                //             alignment: Alignment.center,
                                //             width: columnWidth * 1.1,
                                //             child: Text(
                                //                 style: TextStyle(
                                //                     fontWeight: FontWeight.bold),
                                //               '${totalCubaj.toStringAsFixed(2)} m³')))),
                                //   ]),
                                )),
                      );
                    });
                  }
                },
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(),
                        // ),
                        child: ElevatedButton(
                            onPressed: () {
                              deleteList();
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize:
                                  Size(sizeWidth * 0.9, sizeHeight * 0.01),
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.deleteList,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: Colors.white,
                                    ))),
                      ),
                      Container(
                        // decoration: BoxDecoration(border: Border.all()),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditMasuratoriPage(
                                          numeLista: widget.numeLista,
                                          pretTotal: widget.pretTotal)));
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize:
                                  Size(sizeWidth * 0.9, sizeHeight * 0.02),
                              backgroundColor: const Color(0xFF008B8B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.edit,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.white,
                              ),
                            )),
                      ),
                      Container(
                        // decoration: BoxDecoration(border: Border.all()),
                        child: ElevatedButton(
                            onPressed: () {
                              updatePrice();
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize:
                                  Size(sizeWidth * 0.9, sizeHeight * 0.02),
                              backgroundColor: const Color(0xFF008B8B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.updatePrice,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: Colors.white,
                                    ))),
                      ),
                      Container(
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.zero, border: Border.all()),
                        child: ElevatedButton(
                            onPressed: () async {
                              generatePDF(
                                  context, widget.numeLista, widget.pretTotal);
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize:
                                  Size(sizeWidth * 0.9, sizeHeight * 0.02),
                              backgroundColor: const Color(0xFF008B8B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                            child: Text(
                                AppLocalizations.of(context)!.generatePdf,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: fontSize, color: Colors.white))),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.zero, border: Border.all()),
                      //   child: Expanded(
                      //     child: ElevatedButton(
                      //         onPressed: sendEmail,
                      //         style: ElevatedButton.styleFrom(
                      //           fixedSize:
                      //               Size(sizeWidth * 0.25, sizeHeight * 0.07),
                      //           backgroundColor: const Color(0xFF008B8B),
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.zero),
                      //         ),
                      //         child: Text('Trimite Email',
                      //             textAlign: TextAlign.center,
                      //             style: TextStyle(
                      //                 fontSize: fontSize, color: Colors.white))),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]));
  }
}
