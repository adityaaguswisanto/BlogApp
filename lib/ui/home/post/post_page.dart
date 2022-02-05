import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/data/helper/ext.dart';
import 'package:flutter_bloc_app/data/local/user_preferences.dart';
import 'package:flutter_bloc_app/data/responses/post/post.dart';
import 'package:flutter_bloc_app/ui/auth/login/login_page.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_bloc.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_event.dart';
import 'package:flutter_bloc_app/ui/home/post/bloc/post_state.dart';
import 'package:flutter_bloc_app/ui/home/post/comment/comment_page.dart';
import 'package:flutter_bloc_app/ui/home/post/post_form.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<dynamic> _postList = [];

  int userId = 0;

  final postBloc = PostBloc();
  bool loading = true;

  @override
  void initState() {
    postBloc.add(PostGetting());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        bloc: postBloc,
        listener: (context, state) async {
          if (state is PostSuccess) {
            postBloc.add(PostGetting());
          } else if (state is PostGetsSuccess) {
            setState(() {
              loading = false;
            });
            userId = await getUserId();
            _postList = state.post;
            _postListView(context, _postList, userId);
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
          return _postListView(context, _postList, userId);
        });
  }

  Widget _postListView(context, List<dynamic> _postList, int userId) {
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
        : ListView.builder(
            itemCount: _postList.length,
            itemBuilder: (context, index) {
              Post post = _postList[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    image: post.user!.image != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                '$baseImage${post.user!.image}'),
                                            fit: BoxFit.cover)
                                        : null,
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.amber),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                '${post.user!.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 17),
                              )
                            ],
                          ),
                        ),
                        post.user!.id == userId
                            ? PopupMenuButton(
                                itemBuilder: (context) => [
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
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => PostForm(
                                                  title: 'Edit Post',
                                                  post: post,
                                                )));
                                  } else {
                                    //here method
                                    postBloc.add(PostDeleted(post.id ?? 0));
                                  }
                                },
                              )
                            : const SizedBox()
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text('${post.body}'),
                    post.image != null
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        '$baseImage${post.image}'),
                                    fit: BoxFit.cover)),
                          )
                        : SizedBox(
                            height: post.image != null ? 0 : 10,
                          ),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                postBloc.add(PostLiked(post.id ?? 0));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      post.selfLiked == true
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      size: 16,
                                      color: post.selfLiked == true
                                          ? Colors.red
                                          : Colors.black38,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${post.likesCount}')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CommentPage(
                                          postId: post.id,
                                        )));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.sms_outlined,
                                      size: 16,
                                      color: Colors.black38,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${post.commentsCount}')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
  }
}
