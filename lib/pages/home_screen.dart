import 'package:encryptF/helpers/misc_helper.dart';
import 'package:encryptF/pages/file_encrypt_page.dart';
import 'package:encryptF/pages/new_notes.dart';
import 'package:encryptF/widgets/loading_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _shouldEncrypt = false;
  final _help = MiscHelper();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "NCrypt!",
            style: TextStyle(color: useColor),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: LoadingWidget(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Container()),
                  logo(),
                  const SizedBox(
                    height: 20,
                  ),
                  newNoteButton(),
                  const SizedBox(
                    height: 20,
                  ),
                  decryptFileButton(),
                  Expanded(child: Container()),
                ],
              ),
      ),
    );
  }

  Widget logo() {
    return Container(
      height: 192,
      width: 192,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/ic_launcher-playstore-modified.png'),
              fit: BoxFit.fill)),
    );
  }

  Widget newNoteButton() => ElevatedButton.icon(
      onPressed: () async {
        await FilePicker.platform.clearTemporaryFiles();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const NewNotes()));
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
        backgroundColor: MaterialStateProperty.all(buttonGrey),
      ),
      icon: const Icon(
        Icons.fiber_new,
        color: useColor,
      ),
      label: const Text(
        'New Note',
        style: TextStyle(fontSize: 25, color: useColor),
      ));

  Widget encryptFileButton() => ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isLoading = true;
            _shouldEncrypt = true;
          });
          encryptDecryptFile();
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
        ),
        icon: const Icon(Icons.enhanced_encryption_rounded),
        label: const Text(
          'Encrypt',
          style: TextStyle(fontSize: 25),
        ),
      );

  Widget decryptFileButton() => ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _isLoading = true;
          _shouldEncrypt = false;
        });
        encryptDecryptFile();
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
        backgroundColor: MaterialStateProperty.all(buttonGrey),
      ),
      icon: const Icon(
        Icons.lock_open_rounded,
        color: useColor,
      ),
      label: const Text('Decrypt',
          style: TextStyle(fontSize: 25, color: useColor)));

  void encryptDecryptFile() async {
    await FilePicker.platform.clearTemporaryFiles();
    try {
      final pickedFile =
          await FilePicker.platform.pickFiles(allowMultiple: true);
      setState(() {
        _isLoading = false;
      });
      if (pickedFile == null) {
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FileEncryptPage(
                pickedFile: pickedFile,
                shouldEncrypt: _shouldEncrypt,
              )));
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
          context: context,
          builder: (_) =>
              filePickError("UnSupported Operation + ${e.toString()}"));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error! ${e.toString()}');
      }
      showDialog(
          context: context,
          builder: (_) =>
              filePickError("An unexpected exception has occurred!"));
    }
  }

  Widget filePickError(String error) {
    return AlertDialog(
      title: const Text("Error!"),
      content: Text(error),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ok')),
      ],
    );
  }
}
