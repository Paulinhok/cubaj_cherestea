import 'package:scandura/SQLite/cubaj_masuratori.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/price_per_meter.dart';
import 'package:scandura/utils/cubajUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:scandura/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class NewCubbingPage extends StatefulWidget {
  final String numeLista;

  NewCubbingPage({super.key, required this.numeLista});

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/2551495382'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/7276661656';

  @override
  State<NewCubbingPage> createState() => _NewCubbingPageState();
}

var selectedIndex = 1;
double? length;
double? width;
double? thichness;
int? pieces;

class _NewCubbingPageState extends State<NewCubbingPage> {
  final TextEditingController lenghtController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController thichnessController = TextEditingController();
  final TextEditingController piecesController = TextEditingController();

  final TextEditingController cubajTotalController = TextEditingController();
  final FocusNode lenghtFocusNode = FocusNode();
  final FocusNode widthocusNode = FocusNode();
  final FocusNode thichnessFocusNode = FocusNode();

  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4079464500254319/6009254972'
      : 'ca-app-pub-4079464500254319/7276661656';

  double? cubajTotal = 0;
  double? pretTotal;
  double? result;
  int numarCurent = 0;

  String resultMessage = "Rezultat: ";
  String errorMessage = '';

  List<Map<String, dynamic>> cubajData = [];
  List<double> rezultate = [];

  void calculateCubbing() {
    try {
      final double length = double.parse(lenghtController.text);
      final double? width = double.tryParse(widthController.text);
      final double? thichness = double.tryParse(thichnessController.text);
      final int? pieces = int.tryParse(piecesController.text);

      if (width != null && thichness != null) {
        setState(() {
          errorMessage = '';
            result = CubajUtils.cubajScandura(length, width, thichness);
          numarCurent++;
          cubajTotal = cubajTotal! + result! * pieces!;
          cubajData = [
            {
              'Numar': numarCurent,
              'Cubaj total': '${cubajTotal!.toStringAsFixed(3)} m³',
            }
          ];
            resultMessage =
              '${width.toString()} cm x ${thichness.toString()} cm x ${length.toString()} cm x ${pieces.toString()} = ${(result! * pieces).toStringAsFixed(3)} m³';
        });
      } else {
        setState(() {
          errorMessage = AppLocalizations.of(context)!.errorMessage;
          result = null;
          cubajData = [];
          resultMessage = "Rezultat: ";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Eroare: ${e.toString()}';
        resultMessage = "Rezultat: ";
      });
    }
  }

  void navigateToPricePerMeter() {
    if (result != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PricePerMeter(
              numeLista: widget.numeLista,
              cubajTotal: result!,
            ),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
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
          title: Text(AppLocalizations.of(context)!.newCubingTitle),
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
            padding: const EdgeInsets.only(top: 5),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              if (_nativeAdIsLoaded && _nativeAd != null)
                SizedBox(
                  height: screenHeight * 0.14,
                  width: screenWidth * 0.99,
                  child: AdWidget(ad: _nativeAd!),
                )
              else
                SizedBox(
                  height: screenHeight * 0.14,
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    // Grosime
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        height: 45,
                        child: Row(
                          children: [
                            // Text(AppLocalizations.of(context)!.thichness),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: widthController,
                                focusNode: lenghtFocusNode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText:
                                      AppLocalizations.of(context)!.width,
                                  hintText:
                                      AppLocalizations.of(context)!.centimeters,
                                ),
                                onChanged: (value) {
                                  // Înlocuiește virgula cu punct
                                  widthController.text =
                                      value.replaceAll(',', '.');
                                  widthController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset:
                                            widthController.text.length),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ),
                      SizedBox(width: 50),
                      // Lungime
                      SizedBox(
                        height: 45,
                        child: Row(
                          children: [
                            // Text(AppLocalizations.of(context)!.length),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: thichnessController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText:
                                      AppLocalizations.of(context)!.thichness,
                                  hintText:
                                      AppLocalizations.of(context)!.centimeters,
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (value) {
                                  // Înlocuiește virgula cu punct
                                  thichnessController.text =
                                      value.replaceAll(',', '.');
                                  thichnessController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: thichnessController.text.length),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),

                    SizedBox(height: 10),
                    // Latime
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text(AppLocalizations.of(context)!.width),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: lenghtController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText:
                                        AppLocalizations.of(context)!.length,
                                    hintText: AppLocalizations.of(context)!
                                        .centimeters,
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  onChanged: (value) {
                                    // Înlocuiește virgula cu punct
                                    lenghtController.text =
                                        value.replaceAll(',', '.');
                                    lenghtController.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: lenghtController.text.length),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ],
                        // ),
                        SizedBox(width: 50),
                        SizedBox(
                          height: 45,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text(AppLocalizations.of(context)!.width),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: piecesController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText:
                                        AppLocalizations.of(context)!.pieces,
                                    hintText: AppLocalizations.of(context)!.buc,
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  onChanged: (value) {
                                    // Înlocuiește virgula cu punct
                                    piecesController.text =
                                        value.replaceAll(',', '.');
                                    piecesController.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: piecesController.text.length),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),

                  SizedBox(width: 10),
                  // Buton Cubează
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          calculateCubbing();

                          // await DatabaseHelper().updatePretTotal(widget.numeLista);

                          double lenght = double.parse(lenghtController.text);
                          double width = double.parse(widthController.text);
                          double thichness =
                              double.parse(thichnessController.text);
                              int pieces = int.parse(piecesController.text);

                          lenghtController.clear();
                          widthController.clear();
                          thichnessController.clear();
                          piecesController.clear();

                          FocusScope.of(context).requestFocus(lenghtFocusNode);

                          int maxNumarCurent = await DatabaseHelper()
                              .getNextNumarCurent(widget.numeLista);
                          int numarCurent = maxNumarCurent + 1;

                          DatabaseHelper().insertCubajMasuratori(
                              widget.numeLista,
                              numarCurent,
                              pieces,
                              lenght,
                              width,
                              thichness,
                              result!);
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.7, screenHeight * 0.05),
                          backgroundColor: const Color(0xFF008B8B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.calculateVolume,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      // Mesaj de eroare / rezultat
                    ],
                  ),
                ],
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              // Tabel cubaj
              // Text(AppLocalizations.of(context)!.volumeTable),
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.95,
                          height: screenHeight * 0.05,
                          child: TextField(
                            controller: TextEditingController(
                                text: resultMessage,
                              
                            ),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: AppLocalizations.of(context)!.result,
                                labelStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                            style: TextStyle(
                              color: Colors.green[700],
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                              // fontWeight: FontWeight.bold,
                            ),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 5),
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.95,
                          height: screenHeight * 0.05,
                          child: TextField(
                            controller: TextEditingController(
                              text:
                                  '${AppLocalizations.of(context)!.number}$numarCurent              ${AppLocalizations.of(context)!.totalVolume} = ${cubajTotal!.toStringAsFixed(3)} m³',
                            ),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText:
                                    AppLocalizations.of(context)!.statsList,
                                labelStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                            style: TextStyle(
                              color: Colors.grey[700],
                              // fontWeight: FontWeight.bold,
                            ),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Butoane de la tabel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await DatabaseHelper()
                              .updatePretTotal(widget.numeLista);
                          double pretTotal = await DatabaseHelper()
                              .getPretTotal(widget.numeLista);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CubajMasuratoriPage(
                                        numeLista: widget.numeLista,
                                        pretTotal: pretTotal,
                                      )));
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize:
                                Size(screenWidth * 0.45, screenHeight * 0.05),
                            backgroundColor: const Color(0xFF008B8B),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: Text(
                          AppLocalizations.of(context)!.viewList,
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PricePerMeter(
                                  numeLista: widget.numeLista,
                                  cubajTotal: cubajTotal!,
                                ),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize:
                                Size(screenWidth * 0.46, screenHeight * 0.05),
                            backgroundColor: const Color(0xFF008B8B),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: Text(
                          AppLocalizations.of(context)!.finishList,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ));
  }
}
