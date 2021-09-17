import 'dart:convert';

import 'package:http/http.dart' as http;
class RequestAssistant{
  static Future<dynamic> getRequest(String url) async{
    http.Response response = await http.get(Uri.parse(url));
    try{
      if(response.statusCode ==200){
      String data = response.body;
      var decode = jsonDecode(data);
      return decode;
    }
    }
    catch(exp){
      return 'Failed, No Response!!';
    }
  }
}