import 'package:desafio_unimed_front/src/entities/cliente.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Cliente> lista = [];
  bool _atualizacaoAutomatica = false;

  void _switchAtualizacao() {
    setState(() {
      _atualizacaoAutomatica = !_atualizacaoAutomatica;
    });
  }

  void _atualizar() {
    if (_atualizacaoAutomatica) _popularLista();
  }

  void _deletarCliente(int? id) async {
    if (id != null) {
      await Dio().delete('http://localhost:1616/api/v1/clientes/$id');
    }
    _atualizar();
  }

  void _popularLista() async {
    var response = await Dio().get('http://localhost:1616/api/v1/clientes');
    List<Cliente> listaNova;
    if (response.statusCode == 200) {
      listaNova = List.from(response.data.map((e) => Cliente.fromJson(e)));
      setState(() {
        lista = listaNova;
      });
    }
  }

  void _adicionarCliente(String razao, String cnpj, String regime, String email) async {
    Map<String, dynamic> json = {
      "razaoSocial": razao,
      "cnpj": cnpj,
      "regimeTributario": regime,
      "email": email
    };

    await Dio().post('http://localhost:1616/api/v1/clientes', data: json);

    _atualizar();
  }

  void _editarCliente(int id, String razao, String cnpj, String regime, String email) async {
    Map<String, dynamic> json = {
      "id": id,
      "razaoSocial": razao,
      "cnpj": cnpj,
      "regimeTributario": regime,
      "email": email
    };

    await Dio().put('http://localhost:1616/api/v1/clientes', data: json);

    _atualizar();
  }

  void _adicionarNotaFiscal(String descricao, String valor, int clienteId) async {
    Map<String, dynamic> cliente = {"id": clienteId};
    Map<String, dynamic> json = {"descricao": descricao, "valor": valor, "cliente": cliente};

    await Dio().post('http://localhost:1616/api/v1/notasFiscais', data: json);
  }

  Future<List<Map<String, dynamic>>> _buscarNotas(int id) async {
    var response = await Dio().get('http://localhost:1616/api/v1/notasFiscais?clienteId=$id');
    List<Map<String, dynamic>> lista = List.from(response.data.map(
        (e) => <String, dynamic>{"id": e['id'], "descricao": e['descricao'], "valor": e['valor']}));
    return lista;
  }

  Future<void> _deletarNotaFiscal(int id) async {
    await Dio().delete('http://localhost:1616/api/v1/notasFiscais/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(top: 10),
            child: Column(
              children: const [
                Text(
                  'ATENÇÃO!',
                  style: TextStyle(color: Colors.red, fontSize: 22),
                ),
                Text('Esse app simples faz parte de um teste para back-end e só'
                    ' funcionará com o back rodando em http://localhost:1616/'),
                Text('Como o teste é para back-end, todas as validações estão do lado do servidor.')
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Text('Atualização automática após ação'),
                  Switch(value: _atualizacaoAutomatica, onChanged: (b) => _switchAtualizacao())
                ],
              ),
              ElevatedButton(
                  onPressed: () async => _popularLista(), child: const Text("Atualizar lista")),
              ElevatedButton(
                  onPressed: () => showDialog(
                      context: context, builder: (context) => _adiconarClienteDialog(context)),
                  child: const Text("Adicionar cliente")),
              ElevatedButton(
                  onPressed: () =>
                      showDialog(context: context, builder: (context) => _dashboard(context)),
                  child: const Text("Dashboard"))
            ],
          ),
          _listBody(),
        ],
      ),
    );
  }

  Widget _dashboard(BuildContext context) {
    int totalClientes = lista.length;
    int qtSimplesNacional = lista.where((c) => c.regimeTributario == 'SIMPLES_NACIONAL').length;
    int qtLucroPresumido = lista.where((c) => c.regimeTributario == 'LUCRO_PRESUMIDO').length;
    double porcentagemSimplesNacional =
        totalClientes != 0 ? (qtSimplesNacional / totalClientes) : 0;
    return SimpleDialog(
      title: const Text('Dashboard'),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Total de clientes: $totalClientes',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Clientes com Simples Nacional: $qtSimplesNacional',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Clientes com Lucro Presumido: $qtLucroPresumido',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          width: 600,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Simples Nacional',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Lucro Presumido',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              LinearProgressIndicator(
                  value: porcentagemSimplesNacional,
                  color: Colors.blueAccent,
                  backgroundColor: Colors.red)
            ],
          ),
        )
      ],
    );
  }

  Widget _listBody() {
    if (lista.isEmpty) return const Center(child: Text('A lista está vazia.'));

    return ListView.builder(
        shrinkWrap: true,
        itemCount: lista.length,
        itemBuilder: (_, index) {
          Cliente cliente = lista[index];
          return ListTile(
            leading: IconButton(
                onPressed: () => showDialog(
                    context: context, builder: (context) => _editarClienteDialog(context, cliente)),
                icon: const Icon(Icons.edit)),
            title: Text('(${cliente.cnpj}) ${cliente.razaoSocial}'),
            subtitle: Text('Regime tributário: ${cliente.regime} e-mail: ${cliente.email}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => _cadastrarNotaDialog(context, cliente)),
                    icon: const Icon(Icons.add_chart_outlined)),
                IconButton(
                    onPressed: () async {
                      List<Map<String, dynamic>> notas = await _buscarNotas(cliente.id!);
                      showDialog(
                          context: context,
                          builder: (context) => _listarNotasDialog(context, cliente, notas));
                    },
                    icon: const Icon(Icons.insert_chart_outlined)),
                IconButton(
                    onPressed: () => _deletarCliente(cliente.id), icon: const Icon(Icons.delete))
              ],
            ),
            isThreeLine: true,
          );
        });
  }

  Widget _cadastrarNotaDialog(BuildContext context, Cliente cliente) {
    final _descricaoController = TextEditingController(text: '');
    final _valorController = TextEditingController(text: '');
    return AlertDialog(
        title: const Text("Adicionar Nota Fiscal"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
              onPressed: () {
                _adicionarNotaFiscal(_descricaoController.text, _valorController.text, cliente.id!);
                Navigator.pop(context);
              },
              child: const Text('Adicionar')),
        ],
        content: Column(
          children: [
            TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(label: Text('Descrição'))),
            TextField(
                controller: _valorController,
                decoration: const InputDecoration(label: Text('Valor'))),
          ],
        ));
  }

  Widget _listarNotasDialog(
      BuildContext context, Cliente cliente, List<Map<String, dynamic>> notas) {
    return AlertDialog(
      title: Text('Notas fiscais de ${cliente.razaoSocial}'),
      content: SizedBox(
        height: 500,
        width: 500,
        child: ListView.builder(
            itemCount: notas.length,
            itemBuilder: (_, index) {
              Map<String, dynamic> nota = notas[index];
              return ListTile(
                title: Text(nota['descricao']),
                subtitle: Text('Valor: R\$${nota['valor']}'),
                trailing: IconButton(
                    onPressed: () async {
                      await _deletarNotaFiscal(nota['id']);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete)),
              );
            }),
      ),
    );
  }

  Widget _adiconarClienteDialog(BuildContext context) {
    final _textControllerRazaoSocial = TextEditingController(text: '');
    final _textControllerCnpj = TextEditingController(text: '');
    final _textControllerEmail = TextEditingController(text: '');

    String radioValue = 'SIMPLES_NACIONAL';

    return AlertDialog(
        title: const Text('Adicionar Cliente'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
              onPressed: () {
                _adicionarCliente(_textControllerRazaoSocial.text, _textControllerCnpj.text,
                    radioValue, _textControllerEmail.text);
                Navigator.pop(context);
              },
              child: const Text('Adicionar')),
        ],
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              TextField(
                controller: _textControllerRazaoSocial,
                autofocus: true,
                decoration: const InputDecoration(label: Text('Razão Social')),
              ),
              TextField(
                controller: _textControllerCnpj,
                autofocus: true,
                decoration: const InputDecoration(label: Text('CNPJ')),
              ),
              ListTile(
                title: const Text('Simples Nacional'),
                leading: Radio<String>(
                    value: 'SIMPLES_NACIONAL',
                    groupValue: radioValue,
                    onChanged: (value) => setState(() {
                          radioValue = value!;
                        })),
              ),
              ListTile(
                title: const Text('Lucro Presumido'),
                leading: Radio<String>(
                    value: 'LUCRO_PRESUMIDO',
                    groupValue: radioValue,
                    onChanged: (value) => setState(() {
                          radioValue = value!;
                        })),
              ),
              TextField(
                controller: _textControllerEmail,
                autofocus: true,
                decoration: const InputDecoration(label: Text('E-mail')),
              ),
            ],
          );
        }));
  }

  Widget _editarClienteDialog(BuildContext context, Cliente cliente) {
    final _textControllerRazaoSocial = TextEditingController(text: cliente.razaoSocial);
    final _textControllerCnpj = TextEditingController(text: cliente.cnpj);
    final _textControllerEmail = TextEditingController(text: cliente.email);

    String radioValue = cliente.regimeTributario;

    return AlertDialog(
        title: const Text('Adicionar Cliente'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
              onPressed: () {
                _editarCliente(cliente.id!, _textControllerRazaoSocial.text,
                    _textControllerCnpj.text, radioValue, _textControllerEmail.text);
                Navigator.pop(context);
              },
              child: const Text('Enviar')),
        ],
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              TextField(
                controller: _textControllerRazaoSocial,
                autofocus: true,
                decoration: const InputDecoration(label: Text('Razão Social')),
              ),
              TextField(
                controller: _textControllerCnpj,
                autofocus: true,
                decoration: const InputDecoration(label: Text('CNPJ')),
              ),
              ListTile(
                title: const Text('Simples Nacional'),
                leading: Radio<String>(
                    value: 'SIMPLES_NACIONAL',
                    groupValue: radioValue,
                    onChanged: (value) => setState(() {
                          radioValue = value!;
                        })),
              ),
              ListTile(
                title: const Text('Lucro Presumido'),
                leading: Radio<String>(
                    value: 'LUCRO_PRESUMIDO',
                    groupValue: radioValue,
                    onChanged: (value) => setState(() {
                          radioValue = value!;
                        })),
              ),
              TextField(
                controller: _textControllerEmail,
                autofocus: true,
                decoration: const InputDecoration(label: Text('E-mail')),
              ),
            ],
          );
        }));
  }
}
