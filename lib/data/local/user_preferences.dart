import 'package:flutter_bloc_app/data/responses/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('id') ?? 0;
}

Future<void> saveTokenAndId(User user) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString('token', user.token ?? '');
  await pref.setInt('id', user.id ?? 0);
}

Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}