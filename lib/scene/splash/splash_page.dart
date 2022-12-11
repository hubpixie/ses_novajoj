import 'package:flutter/material.dart';
import 'package:ses_novajoj/scene/splash/splash_presenter.dart';
import 'package:ses_novajoj/foundation/firebase_util.dart';

class SplashPage extends StatefulWidget {
  final SplashPresenter presenter;
  const SplashPage({Key? key, required this.presenter}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // it moves to Login View automatically.
    Future.delayed(const Duration(seconds: 2), () {
      // widget.presenter.startLogin();
      widget.presenter.startTop(context);
    });
    // send viewEvent
    FirebaseUtil().sendViewEvent(route: AnalyticsRoute.splash);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABC5FD),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/ses_splash.png',
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
              child: CircularProgressIndicator(
                color: Colors.amber,
                backgroundColor: Colors.grey[850],
              ),
            ),
          )
        ],
      ),
    );
  }
}
