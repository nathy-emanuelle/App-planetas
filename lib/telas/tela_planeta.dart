import 'package:flutter/material.dart';
import 'package:myapp/controles/controle_planeta.dart';
import 'package:myapp/modelos/planeta.dart';

class TelaPlaneta extends StatefulWidget {
  final bool isIncluir; // Corrigido o nome para "isIncluir"
  final String title;
  final Function(Planeta) onData;
  final Planeta? planeta; // O parâmetro planeta é opcional

  const TelaPlaneta({
    super.key,
    required this.isIncluir, // Parâmetro correto para o indicador de inclusão
    required this.title,
    required this.onData,
    this.planeta, // Agora é opcional
  });

  @override
  State<TelaPlaneta> createState() => _TelaPlanetaState();
}

class _TelaPlanetaState extends State<TelaPlaneta> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _tamanhoController = TextEditingController();
  final TextEditingController _distanciaController = TextEditingController();
  final TextEditingController _apelidoController = TextEditingController();

  final ControlePlaneta _controlePlaneta = ControlePlaneta();

  late Planeta _planeta;

  @override
  void initState() {
    super.initState();
    _planeta =
        widget.planeta ?? Planeta.vazio(); // Inicializa o planeta se for nulo

    // Preenche os controladores com os valores do planeta
    _nomeController.text = _planeta.nome;
    _tamanhoController.text = _planeta.tamanho.toString();
    _distanciaController.text = _planeta.distancia.toString();
    _apelidoController.text = _planeta.apelido ?? "";
  }

  @override
  void dispose() {
    // Libera os controladores para evitar vazamento de memória
    _nomeController.dispose();
    _tamanhoController.dispose();
    _distanciaController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  // Função para inserir um novo planeta
  Future<void> _inserirPlaneta() async {
    if (_planeta.id == null) {
      await _controlePlaneta.inserirPlaneta(_planeta);
    } else {
      await _controlePlaneta.atualizarPlaneta(_planeta);
    }
  }

  // Função para alterar um planeta existente
  Future<void> _alterarPlaneta() async {
    await _controlePlaneta.atualizarPlaneta(_planeta);
  }

  // Submete o formulário, executando inserção ou alteração
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Atualiza os valores do planeta antes de salvar
      _planeta = Planeta(
        id: _planeta.id,
        nome: _nomeController.text,
        tamanho: double.tryParse(_tamanhoController.text) ?? 0.0,
        distancia: double.tryParse(_distanciaController.text) ?? 0.0,
        apelido: _apelidoController.text,
      );

      // Executa a inserção ou alteração
      if (widget.isIncluir) {
        _inserirPlaneta();
      } else {
        _alterarPlaneta();
      }

      // Exibe a mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do planeta foram salvos com sucesso!'),
        ),
      );

      // Retorna o planeta atualizado para a tela anterior
      Navigator.pop(context, _planeta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, insira o nome do planeta'
                          : null,
                ),
                TextFormField(
                  controller: _tamanhoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tamanho (em km)',
                  ),
                  validator: (value) =>
                      (value == null ||
                              value.isEmpty ||
                              double.tryParse(value) == null)
                          ? 'Por favor, insira um tamanho válido'
                          : null,
                ),
                TextFormField(
                  controller: _distanciaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Distância (em km)',
                  ),
                  validator: (value) =>
                      (value == null ||
                              value.isEmpty ||
                              double.tryParse(value) == null)
                          ? 'Por favor, insira uma distância válida'
                          : null,
                ),
                TextFormField(
                  controller: _apelidoController,
                  decoration: const InputDecoration(labelText: 'Apelido'),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
