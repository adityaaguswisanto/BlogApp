import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/post/comment.dart';
import 'package:flutter_bloc_app/ui/auth/login/login_page.dart';
import 'package:flutter_bloc_app/ui/home/post/comment/bloc/comment_bloc.dart';
import 'package:flutter_bloc_app/ui/home/post/comment/bloc/comment_event.dart';
import 'package:flutter_bloc_app/ui/home/post/comment/bloc/comment_state.dart';

class CommentPage extends StatefulWidget {
  final int? postId;

  const CommentPage({Key? key, this.postId}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtComment = TextEditingController();

  List<dynamic> _commentList = [];

  bool loading = true;
  int userId = 0;
  int editCommentId = 0;

  final commentBloc = CommentBloc();

  @override
  void initState() {
    commentBloc.add(CommentGetting(widget.postId ?? 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment'),
      ),
      body: BlocConsumer<CommentBloc, CommentState>(
          bloc: commentBloc,
          listener: (context, state) async {
            if (state is CommentSuccess) {
              commentBloc.add(CommentGetting(widget.postId ?? 0));
              txtComment.clear();
            } else if (state is CommentGetsSuccess) {
              setState(() {
                loading = false;
              });
              userId = await getUserId();
              _commentList = state.comment;
              _commentListView(context, _commentList, userId);
            } else if (state is CommentFailure) {
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
            return _commentListView(context, _commentList, userId);
          }),
    );
  }

  Widget _commentListView(context, List<dynamic> _commentList, int userId) {
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
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _commentList.length,
                  itemBuilder: (context, index) {
                    Comment comment = _commentList[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.black38, width: 0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      image: comment.user!.image != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  '$baseImage${comment.user!.image}'),
                                              fit: BoxFit.cover)
                                          : null,
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    '${comment.user!.name}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              comment.user!.id == userId
                                  ? PopupMenuButton(
                                      itemBuilder: (BuildContext context) => [
                                        const PopupMenuItem(
                                          child: Text('Edit'),
                                          value: 'edit',
                                        ),
                                        const PopupMenuItem(
                                          child: Text('Delete'),
                                          value: 'delete',
                                        ),
                                      ],
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.more_vert,
                                          color: Colors.black,
                                        ),
                                      ),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          setState(() {
                                            editCommentId = comment.id ?? 0;
                                            txtComment.text =
                                                comment.comment ?? '';
                                          });
                                        } else {
                                          commentBloc.add(
                                              CommentDeleted(comment.id ?? 0));
                                        }
                                      },
                                    )
                                  : const SizedBox()
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('${comment.comment}')
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.black26, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: txtComment,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Comment',
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (txtComment.text.isNotEmpty) {
                          if (editCommentId > 0) {
                            commentBloc.add(
                                CommentUpdated(editCommentId, txtComment.text));
                          } else {
                            commentBloc.add(CommentSubmitted(
                                widget.postId ?? 0, txtComment.text));
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                    )
                  ],
                ),
              )
            ],
          );
  }
}
