import 'dart:io';

import 'package:intl/intl.dart';
import 'package:scandura/SQLite/cubaj_masuratori.dart';
import 'package:scandura/SQLite/cubbing.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/edit_cubaj.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/SQLite/measuring.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:scandura/pages/new_cubbing.dart';
import 'package:scandura/utils/cubajUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scandura/l10n/app_localizations.dart';

class EditMasuratoriPage extends StatefulWidget {
  EditMasuratoriPage(
      {super.key, required this.pretTotal, required this.numeLista});

  final double pretTotal;
  final String numeLista;

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/2551495382'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';

  @override
  State<EditMasuratoriPage> createState() => _EditMasuratoriPageState();
}

List<CubajMasuratori> _combineRows(List<CubajMasuratori> measuring,
    {int? excludeId}) {
  final Map<String, CubajMasuratori> combined = {};
  final List<CubajMasuratori> separate = [];

  for (var masuratori in measuring) {
    if (masuratori.id == excludeId) continue;

    // if (masuratori.latime! < 20) {
    String key =
        '${masuratori.lungime}_${masuratori.latime}_${masuratori.grosime}';

    if (combined.containsKey(key)) {
      combined[key]!.bucati = masuratori.bucati! + combined[key]!.bucati!;

      combined[key]!.cubajBucata = CubajUtils.cubajScandura(
          combined[key]!.lungime!,
          combined[key]!.latime!,
          combined[key]!.grosime!);
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
    // } else {
    //   separate.add(masuratori);
    // }
  }

  return combined.values.toList() + separate;
}

class _EditMasuratoriPageState extends State<EditMasuratoriPage> {
  late Future<List<CubajMasuratori>> measuring;
  late Future<Cubaj> listName;

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
  double totalCubaj = 0.0;
  late Future<double> pretTotal;
  late Future<double> pretPerMeter;

  @override
  void initState() {
    super.initState();
    measuring = DatabaseHelper().getMeasuring(widget.numeLista);
    pretTotal = DatabaseHelper().getPretTotal(widget.numeLista);
    _loadAd();
    _loadMediumNativeAd();

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
  }

  Future<void> refreshData() async {
    await DatabaseHelper().updatePretTotal(widget.numeLista);
    await DatabaseHelper().updateCubaj(widget.numeLista);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.measuringAdd),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CubajMasuratoriPage(
          numeLista: widget.numeLista,
          pretTotal: widget.pretTotal,
        ),
      ),
    );

    setState(() {
      measuring = DatabaseHelper().getMeasuring(widget.numeLista);
    });
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.03;

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          if (_nativeAdIsLoaded && _nativeAd != null)
            SizedBox(
              height: screenHeight * 0.15,
              width: screenWidth * 0.99,
              child: AdWidget(ad: _nativeAd!),
            )
          else
            SizedBox(
              height: screenHeight * 0.15,
            ),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.45,
                  height: screenHeight * 0.05,
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
                  width: screenWidth * 0.45,
                  height: screenHeight * 0.05,
                  child: TextField(
                    controller: TextEditingController(
                        text:
                            '${currencyFormat.format(double.tryParse(pretTotalController.text.replaceAll('RON', '').trim()))} ${AppLocalizations.of(context)!.currency}'),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.totalPrice,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold)),
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
                  width: screenWidth * 0.45,
                  height: screenHeight * 0.05,
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
                  width: screenWidth * 0.45,
                  height: screenHeight * 0.05,
                  child: TextField(
                    controller: TextEditingController(
                        text:
                            '${currencyFormat.format(double.tryParse(pretPerMeterController.text.replaceAll('RON', '').trim()))} ${AppLocalizations.of(context)!.currency}'),
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
          SizedBox(height: 10),
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
                    return LayoutBuilder(builder: (context, constraints) {
                      double columnWidth = constraints.maxWidth / 6;
              
                      // int totalBucati = snapshot.data!
                      //     .fold(0, (sum, item) => sum + item.bucati!);
                      // double totalCubaj = snapshot.data!.fold(
                      //     0,
                      //     (sum, item) =>
                      //         sum + (item.cubajBucata! * item.bucati!));
              
                      // Future<double> pretTotal =
                      //     DatabaseHelper().getPretTotal(widget.numeLista);
              
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
                                            AppLocalizations.of(context)!.intNr))),
                                DataColumn(
                                    label: Container(
                                        color: Color(0xFF008B8B),
                                        alignment: Alignment.center,
                                        width: columnWidth * 0.5,
                                        child: Text(
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            AppLocalizations.of(context)!.buc))),
                                DataColumn(
                                    label: Container(
                                        color: Color(0xFF008B8B),
                                        alignment: Alignment.center,
                                        width: columnWidth * 1.1,
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
                                        width: columnWidth * 1.1,
                                        child: Text(
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            AppLocalizations.of(context)!.cubing))),
                                DataColumn(
                                    label: Container(
                                        color: Color(0xFF008B8B),
                                        alignment: Alignment.center,
                                        width: columnWidth * 0.9,
                                        child: Text(
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            AppLocalizations.of(context)!.edit))),
                              ],
                              rows: _combineRows(snapshot.data!)
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key + 1;
                                CubajMasuratori masuratori = entry.value;
                                return DataRow(cells: [
                                  DataCell(Center(child: Text(index.toString()))),
                                  DataCell(Center(
                                      child: Text(masuratori.bucati.toString()))),
                                  DataCell(Center(
                                      child: Text('${masuratori.lungime} cm'))),
                                  DataCell(Center(
                                      child: Text('${masuratori.latime} cm'))),
                                  DataCell(Center(
                                      child: Text('${masuratori.grosime} cm'))),
                                  DataCell(Center(
                                      child: Text(
                                          '${(masuratori.cubajBucata! * masuratori.bucati!).toStringAsFixed(3)} m³'))),
                                  DataCell(Center(
                                      child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return EditCubaj(
                                          index: index,
                                          masuratori: masuratori,
                                        );
                                      }));
                                    },
                                  ))),
                                ]);
                              }).toList()
                                ..add(DataRow(cells: [
                                  DataCell(Center(
                                      child: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.4,
                                          child: Text('')))),
                                  DataCell(Center(
                                      child: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.5,
                                          child: Text('')))),
                                  DataCell(Container(
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      width: columnWidth * 1.1,
                                      child: Text(''))),
                                  DataCell(Center(
                                      child: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 1,
                                          child: Text('')))),
                                  DataCell(Center(
                                      child: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 0.9,
                                          child: Text('')))),
                                  DataCell(Center(
                                      child: Container(
                                          color: Color(0xFF008B8B),
                                          alignment: Alignment.center,
                                          width: columnWidth * 1.1,
                                          child: Text('')))),
                                  DataCell(Container(
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      width: columnWidth * 0.9,
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewCubbingPage(
                                                          numeLista:
                                                              widget.numeLista,
                                                        ))).then((_) {
                                              refreshData();
                                            });
                                          },
                                          icon: Icon(Icons.add_circle_outline),
                                          color: Colors.white,
                                          iconSize: screenWidth * 0.08,
                                          tooltip: "CUBAJ NOU",
                                        ),
                                      ))),
                                ]))
                              // ..add(
                              //   DataRow(cells: [
                              //     DataCell(Container(
                              //         color: Color(0xFF008B8B),
                              //         alignment: Alignment.center,
                              //         width: columnWidth * 0.8,
                              //         child: Text(''))),
                              //     DataCell(Container(
                              //         color: Color(0xFF008B8B),
                              //         alignment: Alignment.center,
                              //         width: columnWidth * 0.5,
                              //         child: Text(''))),
                              //     DataCell(Container(
                              //         color: Color(0xFF008B8B),
                              //         alignment: Alignment.center,
                              //         width: columnWidth,
                              //         child: Text(''))),
                              //     DataCell(Center(
                              //         child: Container(
                              //             color: Color(0xFF008B8B),
                              //             alignment: Alignment.center,
                              //             width: columnWidth * 1.2,
                              //             child: FutureBuilder<double>(
                              //               future: pretTotal,
                              //               builder: (context, snapshot) {
                              //                 if (snapshot.connectionState ==
                              //                     ConnectionState.waiting) {
                              //                   return CircularProgressIndicator();
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
                              //     DataCell(Container(
                              //         color: Color(0xFF008B8B),
                              //         alignment: Alignment.center,
                              //         width: columnWidth * 0.9,
                              //         child: Text(''))),
                              //     DataCell(Center(
                              //         child: Container(
                              //             color: Color(0xFF008B8B),
                              //             alignment: Alignment.center,
                              //             width: columnWidth * 1.3,
                              //             child: Text(
                              //               style: TextStyle(
                              //                   fontWeight: FontWeight.bold),
                              //               '${totalCubaj.toStringAsFixed(2)}m³',
                              //               textAlign: TextAlign.center,
                              //             )))),
                              //     DataCell(Container(
                              //         color: Color(0xFF008B8B),
                              //         alignment: Alignment.center,
                              //         width: columnWidth * 1.1,
                              //         child: Center(
                              //           child: IconButton(
                              //             onPressed: () {},
                              //             icon:
                              //                 Icon(Icons.queue_play_next_rounded),
                              //             color: Colors.white,
                              //           ),
                              //         ))),
                              // ]),
                              // ),
                              ),
                        ),
                      );
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
