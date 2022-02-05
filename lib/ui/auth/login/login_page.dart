import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/ui/auth/login/bloc/login_bloc.dart';
import 'package:flutter_bloc_app/ui/auth/login/bloc/login_event.dart';
import 'package:flutter_bloc_app/ui/auth/login/bloc/login_state.dart';
import 'package:flutter_bloc_app/ui/home/home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  final loginBloc = LoginBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer(
          bloc: loginBloc,
          listener: (context, state) async {
            if (state is LoginSuccess) {
              saveTokenAndId(state.user);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false);
            } else if (state is LoginFailure) {
              setState(() {
                loading = false;
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            return _loginForm(context);
          },
        ),
      ),
    );
  }

  Widget _loginForm(context) {
    return Form(
      key: formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(32),
        children: [
          SvgPicture.asset('assets/icons/account.svg', height: 50, width: 50,),
          const SizedBox(
            height: 50,
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: txtEmail,
            validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
            decoration: const InputDecoration(
                labelText: 'Email',
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black))),
          ),
          const SizedBox(
            height: 14,
          ),
          TextFormField(
            obscureText: true,
            controller: txtPassword,
            validator: (val) =>
                val!.length < 6 ? 'Required at least 6 chars' : null,
            decoration: const InputDecoration(
                labelText: 'Password',
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black))),
          ),
          const SizedBox(
            height: 30,
          ),
          loading
              ? const Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
              height: 20.0,
              width: 20.0,
            ),
          ) : ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  loginBloc
                      .add(LoginSubmitted(txtEmail.text, txtPassword.text));
                });
              }
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
