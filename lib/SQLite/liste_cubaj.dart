import 'dart:io';
import 'package:intl/intl.dart';
import 'package:scandura/SQLite/cubaj_masuratori.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:flutter/material.dart';
import 'package:scandura/SQLite/cubbing.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scandura/l10n/app_localizations.dart';

class ListeCubaj extends StatefulWidget {
  ListeCubaj({super.key});

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/2551495382'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';

  @override
  State<ListeCubaj> createState() => _ListeCubajState();
}

class _ListeCubajState extends State<ListeCubaj> {
  late Future<List<Cubaj>> cubbings;

  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4079464500254319/6009254972'
      : 'ca-app-pub-4079464500254319/7276661656';

  final double pretTotal = 0;

  final NumberFormat currencyFormat = NumberFormat("#,##0.00", "ro_RO");

  @override
  void initState() {
    super.initState();
    cubbings = DatabaseHelper().getCubbings();
    _loadAd();
    _loadMediumNativeAd();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.listsCubingTitle),
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
              }
              // else if (result == 2) {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => ListOfCubbingPage()));
              // }
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
                // const PopupMenuItem(
                //   value: 2,
                //   child: ListTile(
                //     leading: Icon(Icons.list),
                //     title: Text("Lista de cubaj"),
                //   ),
                // ),
              ];
            },
          ),
        ],
      ),
      body: Column(
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
          Expanded(
            child: FutureBuilder<List<Cubaj>>(
              future: cubbings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Eroare: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nu există cubaje salvate.'));
                } else {
                  return LayoutBuilder(builder: (context, constraints) {
                    double columnWidth = constraints.maxWidth / 5;

                    return Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(),
                            horizontalMargin: 0,
                            columnSpacing: 0,
                            columns: [
                              DataColumn(
                                  label: Container(
                                      width: columnWidth * 0.5,
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        AppLocalizations.of(context)!.intNr,
                                        textAlign: TextAlign.center,
                                      ))),
                              DataColumn(
                                  label: Container(
                                      width: columnWidth * 1.2,
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      child: Text(
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          AppLocalizations.of(context)!
                                              .nameList))),
                              DataColumn(
                                  label: Container(
                                      width: columnWidth * 1.1,
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      child: Text(
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          AppLocalizations.of(context)!
                                              .volume))),
                              DataColumn(
                                  label: Container(
                                      width: columnWidth * 1.1,
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      child: Text(
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          AppLocalizations.of(context)!
                                              .totalPrice))),
                              DataColumn(
                                  label: Container(
                                      width: columnWidth * 1,
                                      color: Color(0xFF008B8B),
                                      alignment: Alignment.center,
                                      child: Text(
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          AppLocalizations.of(context)!.date))),
                            ],
                            rows: snapshot.data!.asMap().entries.map((entry) {
                              int index = entry.key + 1;
                              Cubaj cubaj = entry.value;
                              final pretTotalFinal =
                                  DatabaseHelper().getPretTotal(cubaj.nume!);
                                  

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Center(child: Text(index.toString())),
                                    onTap: () async {
                                      final double pretTotal =
                                          await pretTotalFinal;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CubajMasuratoriPage(
                                            numeLista: cubaj.nume!,
                                            pretTotal: pretTotal,
                                          ),
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          cubbings =
                                              DatabaseHelper().getCubbings();
                                        });
                                      });
                                    },
                                  ),
                                  DataCell(
                                    Center(child: Text(cubaj.nume!)),
                                    onTap: () async {
                                      final double pretTotal =
                                          await pretTotalFinal;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CubajMasuratoriPage(
                                            numeLista: cubaj.nume!,
                                            pretTotal: pretTotal,
                                          ),
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          cubbings =
                                              DatabaseHelper().getCubbings();
                                        });
                                      });
                                    },
                                  ),
                                  DataCell(
                                    Center(
                                        child: Text(cubaj.cubajTotal!
                                            .toStringAsFixed(3))),
                                    onTap: () async {
                                      final double pretTotal =
                                          await pretTotalFinal;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CubajMasuratoriPage(
                                            numeLista: cubaj.nume!,
                                            pretTotal: pretTotal,
                                          ),
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          cubbings =
                                              DatabaseHelper().getCubbings();
                                        });
                                      });
                                    },
                                  ),
                                  DataCell(
                                    Center(
                                        child: Text(currencyFormat
                                            .format(cubaj.pretTotal!))),
                                    onTap: () async {
                                      final double pretTotal =
                                          await pretTotalFinal;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CubajMasuratoriPage(
                                            numeLista: cubaj.nume!,
                                            pretTotal: pretTotal,
                                          ),
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          cubbings =
                                              DatabaseHelper().getCubbings();
                                        });
                                      });
                                    },
                                  ),
                                  DataCell(
                                    Center(child: Text(cubaj.formattedDate)),
                                    onTap: () async {
                                      final double pretTotal =
                                          await pretTotalFinal;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CubajMasuratoriPage(
                                            numeLista: cubaj.nume!,
                                            pretTotal: pretTotal,
                                          ),
                                        ),
                                      ).then((_) {
                                        setState(() {
                                          cubbings =
                                              DatabaseHelper().getCubbings();
                                        });
                                      });
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
