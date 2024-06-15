import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpg/mpg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FruitDetector extends StatefulWidget {
  const FruitDetector({super.key});

  @override
  State<FruitDetector> createState() => _FruitDetectorState();
}

class _FruitDetectorState extends State<FruitDetector> {

  File? _image;
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  String result="Results";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker=ImagePicker();
    // final ImageLabelerOptions options =
    //     ImageLabelerOptions(confidenceThreshold: 0.5);
    // final imageLabeler = ImageLabeler(options: options);
    loadModel();
  }
  loadModel() async{
    final modelPath = await getModelPath('assets/ml/model_mobilenet.tflite');
final options = LocalLabelerOptions(
  confidenceThreshold: 0.5,
  modelPath: modelPath,
);
 imageLabeler = ImageLabeler(options: options);
  }

  imagefromGallery() async{
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if(image!=null){
      _image=File(image.path);
      setState(() {
        _image;
        doImageLabelling();
      });
    }
  }

  imagefromCamera() async{
    final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _image = File(image.path);
      setState(() {
        _image;
        doImageLabelling();
      });
    }
  }

  doImageLabelling() async{
    InputImage inputImage=InputImage.fromFile(_image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      result=text+"  "+confidence.toStringAsFixed(2);
    }
    setState(() {
      result;
    });
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fruit Detector",style: TextStyle(fontSize: 30),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: "AutoMobile")));
          }, icon: Icon(
                Icons.arrow_circle_right_outlined,
                size: 30,
                color: Colors.black,
              ))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image==null?Icon(Icons.image,size: 150,):Image.file(_image!,fit: BoxFit.cover,height: 300,width: 300,),
            SizedBox(height: 15,),
            Text("Results: "+ result,style: TextStyle(fontSize: 30,color: Colors.black),),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(onPressed: (){
              showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          backgroundColor: Colors.black,
                          title: const Text(
                            "Choose one",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            SimpleDialogOption(
                              onPressed: () {
                                imagefromGallery();
                              },
                              child: Text(
                                "Choose from gallery",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                imagefromCamera();
                              },
                              child: Text(
                                "Choose from camera",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      });
            }
            , child: Text("Pick an image"))
          ],
        ),
      ),
    );
  }
}