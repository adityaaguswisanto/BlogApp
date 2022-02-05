import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/ui/auth/login/login_page.dart';
import 'package:flutter_bloc_app/ui/home/home_page.dart';
import 'package:flutter_bloc_app/ui/splash/bloc/splash_bloc.dart';
import 'package:flutter_bloc_app/ui/splash/bloc/splash_event.dart';
import 'package:flutter_bloc_app/ui/splash/bloc/splash_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  final splashBloc = SplashBloc();

  @override
  void initState() {
    splashBloc.add(SplashSubmitted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: splashBloc,
      listener: (context, state) async {
        String token = await getToken();
        if (token == '') {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false);
        } else {
          if (state is SplashLoading) {
            loading(context);
          } else if (state is SplashSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false);
          } else if (state is SplashFailure) {
            if (state.error == null) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false);
            } else if (state.error == unauthorized) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${state.error}'),
              ));
            }
          }
        }
      },
      builder: (context, state) {
        return loading(context);
      },
    );
  }

  Widget loading(context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
