import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Question {
  final int id;
  final String content;
  final String area;
  final List<Alternative> alternatives;

  Question({
    required this.id,
    required this.content,
    required this.area,
    required this.alternatives,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var alternativesFromJson = json['item_item_questionToquestion'] as List;
    List<Alternative> alternativesList = alternativesFromJson
        .map((altJson) => Alternative.fromJson(altJson))
        .toList();

    return Question(
      id: json['id'],
      content: json['content'],
      area: json['area'],
      alternatives: alternativesList,
    );
  }
}

class Alternative {
  final int id;
  final String content;
  final int score;

  Alternative({
    required this.id,
    required this.content,
    required this.score,
  });

  factory Alternative.fromJson(Map<String, dynamic> json) {
    return Alternative(
      id: json['id'],
      content: json['content'],
      score: int.parse(json['score']),
    );
  }
}

class Answer {
  final int questionId;
  final int alternativeId;

  Answer({
    required this.questionId,
    required this.alternativeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': questionId,
      'item': alternativeId,
    };
  }
}

class Atec extends StatefulWidget {
  final String client;
  const Atec({super.key, required this.client});

  @override
  State<Atec> createState() => _AtecState();
}

class _AtecState extends State<Atec> with TickerProviderStateMixin {
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('acetoken');
  }

  Future<String?> getIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('identifier');
  }

  final TextEditingController _titleController =
      TextEditingController(text: 'minha avaliação');
  final TextEditingController _observationController = TextEditingController();
  late final TabController _tabController;
  List<Question> questions = [];
  Map<int, int> selectedAlternatives = {};

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, Color> areaColors = {
    "Fala/Linguagem/Comunicação": Colors.blue,
    "Percepção sensorial /cognitiva": Colors.green,
    "Saúde / Aspectos físicos / Comportamento": Colors.red,
    "Sociabilidade": Colors.orange,
  };

  Future<void> fetchQuestions() async {
    try {
      final response =
          await http.get(Uri.parse('https://hexagon-no2i.onrender.com/atec/'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResult = json.decode(response.body);
        List<Question> fetchedQuestions =
            jsonResult.map((json) => Question.fromJson(json)).toList();

        setState(() {
          questions = fetchedQuestions;
        });
      } else {
        // Se a resposta não for 200 OK, trate o erro aqui
        String errorMessage =
            'Erro ao buscar perguntas: ${response.statusCode}';
        // Exiba um snackbar ou um alerta para o usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Trate qualquer exceção que possa ocorrer
      String errorMessage = 'Ocorreu um erro ao buscar perguntas: $e';
      // Exiba um snackbar ou um alerta para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> submitAnswers() async {
    List<Answer> answers = selectedAlternatives.entries.map((entry) {
      return Answer(
        questionId: entry.key,
        alternativeId: entry.value,
      );
    }).toList();

    String? identifier = await getIdentifier();

    Map<String, dynamic> submission = {
      "title": '${_titleController.text} - por $identifier',
      "notes": _observationController.text,
      "client": int.parse(widget.client),
      "answers": answers.map((answer) => answer.toJson()).toList(),
    };

    if (answers.length != 77) {
      //String jsonSubmission = json.encode(submission);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as questões precisam ser respondidas.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    String? token = await getAccessToken();

    final response = await http.post(
      Uri.parse('https://hexagon-no2i.onrender.com/atec/submit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(submission),
    );

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      // ignore: use_build_context_synchronously
      context.pop();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao enviar os dados'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATEC'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.checklist_rtl),
            ),
            Tab(
              icon: Icon(Icons.notes_outlined),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    Question question = questions[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: areaColors[question.area] ??
                              Colors.black, // Cor da borda com base na área
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.area,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color:
                                    areaColors[question.area] ?? Colors.black,
                              ),
                            ),
                            Text(
                              question.content,
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ...question.alternatives.map((alternative) {
                              return RadioListTile<int>(
                                title: Text(alternative.content),
                                value: alternative.id,
                                groupValue: selectedAlternatives[question.id],
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedAlternatives[question.id] = value!;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 5.0),
                  const Text("Título: "),
                  const SizedBox(height: 5.0),
                  TextField(controller: _titleController),
                  const SizedBox(height: 5.0),
                  const Text("Observações: "),
                  const SizedBox(height: 5.0),
                  TextField(
                    controller: _observationController,
                    minLines: 15,
                    maxLines: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitAnswers,
        child: const Icon(Icons.send),
      ),
    );
  }
}
