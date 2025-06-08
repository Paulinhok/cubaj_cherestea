import 'dart:io';

import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:scandura/pages/result_of_cubbing.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scandura/l10n/app_localizations.dart';
class PricePerMeter extends StatefulWidget {
  PricePerMeter({super.key, required this.cubajTotal, required this.numeLista});
  final double cubajTotal;
  final String numeLista;

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/2551495382'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';

  @override
  State<PricePerMeter> createState() => _PricePerMeterState();
}

class _PricePerMeterState extends State<PricePerMeter> {
  final TextEditingController pretController = TextEditingController();
  final FocusNode priceFocusNode = FocusNode();

  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4079464500254319/6009254972'
      : 'ca-app-pub-4079464500254319/7276661656';

  void calculateCubbingAndPrice() async {
    double? pretPerMeter = double.tryParse(pretController.text);

    if (pretPerMeter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.validePrice),
        ),
      );
      return;
    }

    await DatabaseHelper().updatePretUnitar(widget.numeLista, pretPerMeter);

    double cubajTotal = await DatabaseHelper().getCubajTotal(widget.numeLista);

    double pretTotal =
        double.parse((cubajTotal * pretPerMeter).toStringAsFixed(3));

    DatabaseHelper().updateListeCubajCubajTotal(
      widget.numeLista,
      cubajTotal,
      pretTotal,
    );
    // double pretTotal = await DatabaseHelper().getPretTotal(widget.numeLista);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultOfCubbing(
              pretUnitar: pretPerMeter,
              cubajTotal: widget.cubajTotal,
              pretTotal: widget.cubajTotal * pretPerMeter,
              numeLista: widget.numeLista)),
    );
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
          title: Text(AppLocalizations.of(context)!.pretPerMeterTitle),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Text(
                AppLocalizations.of(context)!.insertPricePerM,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  wordSpacing: 2,
                  height: 5,
                ),
              ),
              SizedBox(
                width: 315,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.price_check_rounded),
                    border: UnderlineInputBorder(),
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
                    labelText: AppLocalizations.of(context)!.pricePerMeter,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    // Înlocuiește virgula cu punct
                    pretController.text = value.replaceAll(',', '.');
                    pretController.selection = TextSelection.fromPosition(
                      TextPosition(offset: pretController.text.length),
                    );
                  },
                  controller: pretController,
                  focusNode: priceFocusNode,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                        print('Button RENUNTA was press ');
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(screenWidth * 0.4, screenHeight * 0.06),
                        backgroundColor: const Color(0xFF008B8B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          //   fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          print('Buttom SALVEAZA has pressed');

                          calculateCubbingAndPrice();
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(screenWidth * 0.4, screenHeight * 0.06),
                          backgroundColor: const Color(0xFF008B8B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.white,
                          ),
                        )),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
