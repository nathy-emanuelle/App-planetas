// ignore: unused_import
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/telas/tela_planeta.dart';
import 'package:myapp/controles/controle_planeta.dart';
import 'package:myapp/modelos/planeta.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planetas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ), 
      home: const MyHomePage(title: 'App planetas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ControlePlaneta _controlePlaneta = ControlePlaneta();
  List<Planeta> _planetas = [];

  @override
  void initState() {
    super.initState();
    _lerPlanetas();
  }

  Future<void> _lerPlanetas() async {
    final resultado = await _controlePlaneta.lerPlanetas();
    setState(() {
      _planetas = resultado;
    });
  }

  void _incluirPlaneta() async {
    final novoPlaneta = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPlaneta(
          title: 'Cadastrar Planeta',
          isIncluir: true, // Flag para inclusão
          onData: (planeta) => planeta, // Retorna o planeta inserido
        ),
      ),
    );

    if (novoPlaneta != null && novoPlaneta is Planeta) {
      await _controlePlaneta.inserirPlaneta(novoPlaneta); // Salvar no BD
      _lerPlanetas();
    }
  }

  void _alterarPlaneta(BuildContext context, Planeta planeta) async {
    final planetaAlterado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPlaneta(
          title: 'Editar Planeta',
          planeta: planeta, // Passa o planeta para edição
          isIncluir: false, // Flag para edição
          onData: (planetaEditado) {
            return planetaEditado; // Retorna o planeta editado
          },
        ),
      ),
    );

    if (planetaAlterado != null && planetaAlterado is Planeta) {
      await _controlePlaneta.atualizarPlaneta(planetaAlterado); // Atualiza o BD
      _lerPlanetas();
    }
  }

  void _excluirPlaneta(int id) async {
    await _controlePlaneta.excluirPlaneta(id);
    _lerPlanetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _planetas.length,
        itemBuilder: (context, index) {
          final planeta = _planetas[index];
          return ListTile(
            title: Text(planeta.nome),
            subtitle: Text("Apelido: ${planeta.apelido} "),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _alterarPlaneta(context, planeta), // Correção aqui
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _excluirPlaneta(planeta.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incluirPlaneta,
        child: const Icon(Icons.add),
      ),
    );
  }
}
