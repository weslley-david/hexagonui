import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:hexagonui/pages/clientDetail/ateccInsights.dart';
import 'package:hexagonui/pages/clientDetail/listGuardian.dart';
import 'package:hexagonui/pages/clientDetail/show_atec_evolution.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hexagonui/models/Client.dart';
import 'package:hexagonui/models/Specialist.dart';
import 'listSpecialist.dart';

class ClientDetail extends StatefulWidget {
  final String id;
  final String name;

  const ClientDetail({super.key, required this.id, required this.name});

  @override
  State<ClientDetail> createState() => _ClientDetailState();
}

class _ClientDetailState extends State<ClientDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Specialist>> _getSpecialistList() async {
    final Map<String, String> queryParams = {
      'skip': '0',
      'take': '30',
      'client': widget.id
    };

    final uri = Uri.https(
        'hexagon-no2i.onrender.com', '/specialist/byclient', queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => Specialist.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load specialist list');
    }
  }

  Future<Client> fetchUsuario() async {
    final response = await http.get(
        Uri.parse('https://hexagon-no2i.onrender.com/client/${widget.id}'));
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      return Client.fromJson(data);
    } else {
      throw Exception('Falha ao carregar o usuário');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: FutureBuilder<Client>(
        future: fetchUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Erro ao carregar os dados do usuário'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Usuário não encontrado'));
          } else {
            final usuario = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      image: usuario.imageurl != null
                          ? DecorationImage(
                              image: NetworkImage(usuario.imageurl!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Se a imagem não puder ser baixada, mostre outra imagem aqui
                                const AssetImage('assets/images/logo.png');
                              },
                            )
                          : null,
                    ),
                  ),
                  Text(
                    usuario.name ?? "name not found : (",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    usuario.identifier ?? "no identifier",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    usuario.bio ?? "bio not found : (",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: _tabController,
                    tabs: const <Widget>[
                      Tab(
                        icon: Icon(Icons.person_2_outlined),
                        text: "cliente",
                      ),
                      Tab(
                        icon: Icon(Icons.graphic_eq_outlined),
                        text: "cliente",
                      ),
                      Tab(
                        icon: Icon(Icons.content_paste),
                        text: "profissionais",
                      ),
                      Tab(
                        icon: Icon(Icons.family_restroom),
                        text: "familiares",
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        AtecInsights(clientId: "${usuario.id}"),
                        ShowAtecEvolution(clientId: "${usuario.id}"),
                        SpecialistList(clientId: "${usuario.id}"),
                        GuardianList(clientId: "${usuario.id}")
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {context.push('/atec')},
        child: const Icon(
          Icons.content_paste_go_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
