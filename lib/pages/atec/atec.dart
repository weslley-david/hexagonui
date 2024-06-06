import 'dart:convert';

import 'package:flutter/material.dart';

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
  const Atec({super.key});

  @override
  State<Atec> createState() => _AtecState();
}

class _AtecState extends State<Atec> {
  List<Question> questions = []; // Aqui você irá carregar suas questões
  Map<int, int> selectedAlternatives = {};

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() {
    // Simulação de fetch das questões de um endpoint
    String jsonData = '''[
      {
        "id": 1,
        "content": "Sabe próprio nome",
        "area": "Fala/Linguagem/Comunicação",
        "item_item_questionToquestion": [
          {
            "id": 413,
            "content": "Não verdadeiro",
            "score": "0"
          },
          {
            "id": 414,
            "content": "Mais ou menos",
            "score": "1"
          },
          {
            "id": 415,
            "content": "Verdade",
            "score": "2"
          }
        ]
      },
      {
        "id": 2,
        "content": "Responde ao 'Não' ou 'Pare'",
        "area": "Fala/Linguagem/Comunicação",
        "item_item_questionToquestion": [
          {
            "id": 416,
            "content": "Não verdadeiro",
            "score": "0"
          },
          {
            "id": 417,
            "content": "Mais ou menos",
            "score": "1"
          },
          {
            "id": 418,
            "content": "Verdade",
            "score": "2"
          }
        ]
      }
    ]''';

    List<dynamic> jsonResult = json.decode(jsonData);
    List<Question> fetchedQuestions =
        jsonResult.map((json) => Question.fromJson(json)).toList();

    setState(() {
      questions = fetchedQuestions;
    });
  }

  void submitAnswers() {
    List<Answer> answers = selectedAlternatives.entries.map((entry) {
      return Answer(
        questionId: entry.key,
        alternativeId: entry.value,
      );
    }).toList();

    Map<String, dynamic> submission = {
      "title": "avaliação teste de submissão",
      "notes": "aaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "client": 21,
      "answers": answers.map((answer) => answer.toJson()).toList(),
    };

    String jsonSubmission = json.encode(submission);
    print(jsonSubmission);

    // Aqui você enviaria o JSON para o endpoint especificado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                Question question = questions[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.content,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        ...question.alternatives.map((alternative) {
                          return RadioListTile<int>(
                            title: Text(alternative.content),
                            value: alternative.id,
                            groupValue: selectedAlternatives[question.id],
                            onChanged: (int? value) {
                              setState(() {
                                selectedAlternatives[question.id] = value!;
                                print(selectedAlternatives);
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitAnswers,
        child: Icon(Icons.send),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:hexagonui/models/Question.dart';

// class Atec extends StatefulWidget {
//   const Atec({super.key});

//   @override
//   State<Atec> createState() => _AtecState();
// }

// class _AtecState extends State<Atec> {
//   late Future<List<Question>> questions;
//   List<Answer> _answers = [];

//   String? gender;

//   @override
//   void initState() {
//     super.initState();
//     questions =
//         getQuestionList(); // Chama a função para incrementar o contador na inicialização
//   }

//   Future<List<Question>> getQuestionList() async {
//     final uri = Uri.https('hexagon-no2i.onrender.com', '/atec/');
//     final response = await http.get(uri, headers: {
//       'Content-Type': 'application/json',
//     });

//     if (response.statusCode == 200) {
//       List<dynamic> jsonList = jsonDecode(response.body);
//       return jsonList.map((item) => Question.fromJson(item)).toList();
//     } else {
//       throw Exception('Falha ao carregar a lista de perguntas');
//     }
//   }

//   Future<void> _submit() async {
//     final submission = Submission(
//       title: 'avaliação teste de submissão',
//       notes: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaa',
//       client: 21,
//       answers: _answers,
//     );

//     final uri = Uri.https('seu-dominio.com', '/api/submit');
//     final response = await http.post(
//       uri,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(submission.toJson()),
//     );

//     if (response.statusCode == 201) {
//       print('Submissão realizada com sucesso!');
//     } else {
//       print('Erro ao realizar submissão: ${response.statusCode}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     getQuestionList();
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("ATEC"),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: FutureBuilder<List<Question>>(
//                 future: questions,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Erro: ${snapshot.error}'));
//                     } else if (snapshot.hasData) {
//                       List<Question> questions = snapshot.data!;
//                       return ListView.builder(
//                         itemCount: questions.length,
//                         itemBuilder: (context, index) {
//                           Question question = questions[index];
//                           return ExpansionTile(
//                             title: Text(question.content),
//                             children: question.answers.map((answer) {
//                               return RadioListTile(
//                                 value: answer.id,
//                                 groupValue: question.id,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _answers.add(Answer(
//                                         question: question.id,
//                                         item: answer.id));
//                                   });
//                                 },
//                                 title: Text(answer.content),
//                               );
//                             }).toList(),
//                           );
//                         },
//                       );
//                     }
//                   }
//                   return Center(child: CircularProgressIndicator());
//                 },
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _submit,
//                     child: Text('Enviar'),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ));
//   }
// }

// class Submission {
//   String title;
//   String notes;
//   int client;
//   List<Answer> answers;

//   Submission(
//       {required this.title,
//       required this.notes,
//       required this.client,
//       required this.answers});

//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'notes': notes,
//       'client': client,
//       'answers': answers.map((answer) => answer.toJson()).toList(),
//     };
//   }
// }

// class Answer {
//   int question;
//   int item;

//   Answer({required this.question, required this.item});

//   Map<String, dynamic> toJson() {
//     return {
//       'question': question,
//       'item': item,
//     };
//   }
// }
