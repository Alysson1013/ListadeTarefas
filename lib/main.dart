import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController toDo = TextEditingController();

  List _toDoList = [];


  //lendo dados salvos, necessário ler um método já existente

  @override
  void initState() {
    super.initState();

    _readFile().then((value){
      setState(() {
        _toDoList = json.decode(value);
      });
    });
  }

  void _addToDo(){
    setState(() {
      Map<String, dynamic> newToDo = new Map();
      newToDo["title"] = toDo.text;
      toDo.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true
      ),
      body: Column(
        children: [
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: toDo,
                        decoration: InputDecoration(
                            labelText: "Nova Tarefa",
                            labelStyle: TextStyle(color: Colors.blueAccent)
                        )
                    )
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    child: Text("ADD"),
                    textColor: Colors.white,
                    onPressed: _addToDo,
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: (context, index){
                  return CheckboxListTile(
                    title: Text(_toDoList[index]["title"]),
                    value: _toDoList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(_toDoList[index]["ok"]?
                        Icons.check: Icons.error
                      )
                    ),
                    onChanged: (c){
                      setState(() {
                        _toDoList[index]["ok"] = c;
                        _saveData();
                      });
                    },
                  );
                }),
          )
        ]
      ),
    );
  }

  //Função para buscar o arquivo
  Future<File> _getFile() async{
    //Faz a requisição do diretório padrão
    final directory = await getApplicationDocumentsDirectory();
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
      return null;
    }
  }
}


