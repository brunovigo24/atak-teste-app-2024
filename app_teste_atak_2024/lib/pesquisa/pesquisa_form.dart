import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PesquisaForm extends StatefulWidget {
  const PesquisaForm({Key? key}) : super(key: key);

  @override
  State<PesquisaForm> createState() => _PesquisaFormState();
}

class _PesquisaFormState extends State<PesquisaForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _query = '';
  late TextEditingController _queryController;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesquisar'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _queryController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Query'),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return 'Informe a query';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _query = value ?? '';
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        await _fetchResults();
                      }
                    },
                    child: const Text('Pesquisar'),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultado da pesquisa será exibido aqui:',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._results.asMap().entries.map((entry) {
                          final index = entry.key;
                          final result = entry.value;
                          return GestureDetector(
                            onTap: () {
                              _openResultInNewWindow(index);
                            },
                            child: Text(
                              result,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchResults() async {
    final url = Uri.parse('http://suaapi.com/api/links/extract?query=$_query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _results = data['links'].cast<
              String>(); // Supondo que a resposta da API seja um JSON com uma chave 'links' que contém uma lista de strings
        });
      } else {
        throw Exception('Falha ao buscar resultados');
      }
    } catch (e) {
      print('Erro ao buscar resultados: $e');
      // Trate o erro conforme necessário
    }
  }

  void _openResultInNewWindow(int index) {
    // Implemente aqui a lógica para abrir o resultado em uma nova janela
    // Por exemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ResultadoPage(result: _results[index])));
  }
}