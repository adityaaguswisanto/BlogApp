import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/auth/login.dart';
import 'package:flutter_bloc_app/ui/auth/login/login_page.dart';
import 'package:flutter_bloc_app/ui/home/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc_app/ui/home/profile/bloc/profile_event.dart';
import 'package:flutter_bloc_app/ui/home/profile/bloc/profile_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtName = TextEditingController();

  final profileBloc = ProfileBloc();

  User? user;

  bool loading = true;
  File? file;
  final imagePicker = ImagePicker();

  Future getImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    profileBloc.add(ProfileGetting());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: profileBloc,
      listener: (context, state) async {
        if (state is ProfileSuccess) {
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${state.message}')));
        } else if (state is ProfileGetsSuccess) {
          setState(() {
            loading = false;
            user = state.user;
            txtName.text = user!.name ?? '';
          });
        } else if (state is ProfileFailure) {
          if (state.error == unauthorized) {
            logout().then((value) => {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false)
                });
          } else {
            setState(() {
              loading = false;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('${state.error}')));
          }
        }
      },
      builder: (context, state) {
        return _profileWidget(context);
      },
    );
  }

  Widget _profileWidget(context) {
    return loading
        ? const Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
              height: 20.0,
              width: 20.0,
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    child: Container(
                      width: 110,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        image: file == null
                            ? user!.image != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                        '$baseImage${user!.image}'),
                                    fit: BoxFit.cover)
                                : null
                            : DecorationImage(
                                image: FileImage(file ?? File('')),
                                fit: BoxFit.cover,
                              ),
                        color: Colors.amber,
                      ),
                    ),
                    onTap: () {
                      getImage();
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: txtName,
                      validator: (val) => val!.isEmpty ? 'Invalid Name' : null,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black38),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      profileBloc.add(ProfileSubmitted(
                          txtName.text, getStringImage(file)));
                    }
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
  }
}
