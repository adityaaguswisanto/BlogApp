import 'dart:convert';
import 'dart:io';

const baseURL = 'http://192.168.43.136:8000';
const baseImage = baseURL + '/storage/';

//Api Endpoint
const registerURL = baseURL + '/api/auth/register';
const loginURL = baseURL + '/api/auth/login';
const forgotURL = baseURL + '/api/auth/forgot';
const userURL = baseURL + '/api/auth/user';
const postsURL = baseURL + '/api/post';
const commentsURL = baseURL + '/api/comment';

const serverError = 'Server Error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again !';

//Create Method Function
String? getStringImage(File? file) {
  if (file == null) return null;
  return base64Encode(file.readAsBytesSync());
}