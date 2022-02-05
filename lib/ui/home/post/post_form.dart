import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/post/post.dart';
import 'package:flutter_bloc_app/ui/auth/login/login_page.dart';
import 'package:flutter_bloc_app/ui/home/home_page.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_bloc.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_event.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_state.dart';
import 'package:image_picker/image_picker.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  const PostForm({Key? key, this.post, this.title}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtBody = TextEditingController();
  bool loading = false;

  final _picker = ImagePicker();
  final postBloc = PostBloc();

  File? file;

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      txtBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: BlocConsumer(
        bloc: postBloc,
        listener: (context, state) async {
          if (state is PostSuccess) {
            setState(() {
              loading = false;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('${state.message}')));
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false);
          } else if (state is PostFailure) {
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
          return _postForm(context);
        },
      ),
    );
  }

  Widget _postForm(context) {
    return ListView(
      children: [
        widget.post != null
            ? const SizedBox()
            : Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                    image: file == null
                        ? null
                        : DecorationImage(
                            image: FileImage(file ?? File('')),
                            fit: BoxFit.cover)),
                child: Center(
                  child: file == null
                      ? IconButton(
                          onPressed: () {
                            getImage();
                          },
                          icon: const Icon(Icons.image, color: Colors.black38))
                      : IconButton(
                          onPressed: () {
                            getImage();
                          },
                          icon: const Icon(null)),
                ),
              ),
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: txtBody,
              maxLines: 9,
              validator: (val) => val!.isEmpty ? 'Post body is required' : null,
              decoration: const InputDecoration(
                  hintText: "Post body...",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.black38))),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (widget.post == null) {
                  setState(() {
                    loading = true;
                  });
                  String? image = file == null ? null : getStringImage(file);
                  postBloc.add(PostSubmitted(txtBody.text, image));
                } else {
                  setState(() {
                    loading = true;
                  });
                  postBloc.add(PostUpdated(widget.post!.id ?? 0, txtBody.text));
                }
              }
            },
            child: const Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
