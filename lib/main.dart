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

  final TextEditingController toDo = TextEditingController();

  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;


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

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

    _toDoList.sort((a, b){
      if (a["ok"] && !b["ok"]) return 1;
      else if(!a["ok"] && b["ok"]) return -1;
      else return 0;
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
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length,
                  itemBuilder: itemBuilder),
            ),
          )
        ]
      ),
    );
  }

 /* */
  //Item Builder
  Widget itemBuilder(context, index){
    //Dismissible, arrastavel
    return Dismissible(
      //Atribui a key apartir da hora em milisegundos
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
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
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();
        });


        final snack = SnackBar(
          content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
          action: SnackBarAction(label: "Desfazer",
            onPressed: (){
            _toDoList.insert(_lastRemovedPos, _lastRemoved);
            _saveData();
            },
          ),
          duration: Duration(seconds: 2),
        );
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      },
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


