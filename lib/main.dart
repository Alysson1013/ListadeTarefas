import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
  ))
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _toDoList = [];

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  //Função para buscar o arquivo
  Future<File> _getFile() async{
    //Faz a requisição do diretório padrão
    final directory = await getDownloadsDirectory();
    //retorna o arquivo para salvar os dados no diretório em questão
    return File("${directory.path}/data.json");
  }

  //Função para alterar o arquivo
  Future<File> _saveData() async{
    //Pegar Lista
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }
  //Função para obter os dados
  Future<String> _readFile() async{
    try{
      final file = await _getFile();
      return file.readAsString();
    } catch(er){
      return er;
    }
  }
}


