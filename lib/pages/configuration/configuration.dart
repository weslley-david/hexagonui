import 'package:flutter/material.dart';

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  String message = "deletar meus dados";

  void _confirmDeletion() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Não permite fechar o diálogo ao tocar fora
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmação de Exclusão"),
          content: Text("Tem certeza que deseja deletar seus dados?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Deletar"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteData();
    }
  }

  void _deleteData() {
    // Aqui você deve implementar a lógica para deletar os dados
    // Exemplo: fazer uma solicitação HTTP para um backend para deletar dados

    // Após a exclusão, você pode atualizar a interface
    setState(() {
      message = "Seus dados foram deletados.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Center(
        child: TextButton(
          onPressed: _confirmDeletion,
          child: Text(
            message,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
