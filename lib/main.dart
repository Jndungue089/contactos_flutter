import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

const String keyApplicationId = 'D6IdSaFT9cgT83kJqt5mWIbxA3hejqJC8ylKjNlz';
const String keyClientKey = 'ES8sXdtiujMnmVhebuTB7LOBzNXnDm2ncjrdGW7N';
const String keyParseServerUrl = 'https://parseapi.back4app.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PessoaScreen(),
    );
  }
}

class PessoaScreen extends StatefulWidget {
  @override
  _PessoaScreenState createState() => _PessoaScreenState();
}

class _PessoaScreenState extends State<PessoaScreen> {
  final TextEditingController _nomeController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<ParseObject> _pessoas = [];

  @override
  void initState() {
    super.initState();
    _fetchPessoas();
  }

  Future<void> _fetchPessoas() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Pessoa'));
    final response = await queryBuilder.query();
    if (response.success && response.results != null) {
      setState(() {
        _pessoas = response.results as List<ParseObject>;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePessoa() async {
    if (_nomeController.text.isEmpty || _image == null) return;
    final pessoa = ParseObject('Pessoa')
      ..set('nome', _nomeController.text)
      ..set('fotoPath', _image!.path);

    final response = await pessoa.save();
    if (response.success) {
      _fetchPessoas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Pessoa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 100)
                : Text('Nenhuma imagem selecionada'),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: Text('Selecionar Foto')),
            ElevatedButton(onPressed: _savePessoa, child: Text('Salvar Pessoa')),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _pessoas.length,
                itemBuilder: (context, index) {
                  var pessoa = _pessoas[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        pessoa.get<String>('fotoPath') != null && pessoa.get<String>('fotoPath')!.isNotEmpty
                            ? Image.file(File(pessoa.get<String>('fotoPath')!), width: 80, height: 80, fit: BoxFit.cover)
                            : Icon(Icons.person, size: 80),
                        SizedBox(height: 10),
                        Text(
                          pessoa.get<String>('nome') ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
