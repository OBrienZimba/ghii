import 'dart:convert';

import 'package:ghii/models/repository.dart';
import 'package:http/http.dart' as http;

class RepoService{
  final String url = 'https://api.github.com/repositories';
  Future<List<Repository>> fetchRepository() async{
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);

      return data.map((repos) => Repository.fromJson(repos)).toList();
    }else {
      throw Exception('Failed to Load Data');
    }
  }
}

