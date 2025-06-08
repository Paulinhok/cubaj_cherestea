import 'dart:io';

import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/new_cubbing.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scandura/l10n/app_localizations.dart';

class ListOfCubbingPage extends StatefulWidget {
  static dynamic numeLista;

  /// The requested size of the banner. Defaults to [AdSize.banner].
  final AdSize adSize;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-3940256099942544/3986624511'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';

  ListOfCubbingPage({super.key, this.adSize = AdSize.banner});

  @override
  State<ListOfCubbingPage> createState() => _ListOfCubbingPageState();
}

var selectedIndex = 2;

class _ListOfCubbingPageState extends State<ListOfCubbingPage> {
  final TextEditingController listaCubajController = TextEditingController();
  final TextEditingController cubajMasuratoriController =
      TextEditingController();

  BannerAd? _bannerAd;

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-4079464500254319/1374370420';

  set numeLista(String numeLista) {}

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadMediumNativeAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
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

  void verifyList() async {
    String numeLista = listaCubajController.text;
    bool isUnique = await DatabaseHelper().verifyListIsUnique(numeLista);

    if (numeLista.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nameListisEmpty),
        ),
      );
    } else if (isUnique) {
      double cubajTotal = 0;
      double pretTotal = cubajTotal * 100;

      DatabaseHelper()
          .insertListeCubaj(listaCubajController.text, cubajTotal, pretTotal);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.listSnackBar} '$numeLista' ${AppLocalizations.of(context)!.listAddedSuccessfully}",
          ),
        ),
      );
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${AppLocalizations.of(context)!.listSnackBar} '$numeLista' ${AppLocalizations.of(context)!.listExist}"),
        ),
      );
    }
    return Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.listOfCubbingTitle),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ListeCubaj()));
                  // } else if (result == 2) {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => ListOfCubbingPage()));
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
                      leading: Icon(Icons.list),
                      title: Text(AppLocalizations.of(context)!.cubingListMenu),
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
              // SizedBox(
              //   width: widget.adSize.width.toDouble(),
              //   height: widget.adSize.height.toDouble(),
              //   child: _bannerAd == null
              //       // Nothing to render yet.
              //       ? const SizedBox()
              //       // The actual ad.
              //       : AdWidget(ad: _bannerAd!),
              // ),
              Text(
                AppLocalizations.of(context)!.insertNameOfList,
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
                  controller: listaCubajController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.list_alt_outlined),
                    border: UnderlineInputBorder(),
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
                    labelText: AppLocalizations.of(context)!.nameOfList,
                    isDense: true,
                  ),
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
                          // fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          ListOfCubbingPage.numeLista =
                              listaCubajController.text;

                          verifyList();

                          print('Buttom SALVEAZA has pressed');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewCubbingPage(
                                      numeLista: listaCubajController.text)));
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
