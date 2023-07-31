import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import '../ML/Recognizer.dart';
import 'package:path_provider/path_provider.dart';
import '../ML/Recognition.dart';
import '../widgets/login.dart';
import 'entry.dart';

class MyFace extends StatefulWidget {
  MyFace({Key? key, required this.cameras}) : super(key: key);
  late List<CameraDescription> cameras;
  @override
  _MyFacePageState createState() => _MyFacePageState(cameras);
}

class _MyFacePageState extends State<MyFace> {
  Map<String,Recognition> registered = {};
  late List<CameraDescription> cameras;
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;
  late List<Recognition> recognitions = [];

  late FaceDetector faceDetector;
  late Recognizer _recognizer;

  _MyFacePageState(this.cameras);

  void _readValue() async{
    try {
      final directory = await getApplicationDocumentsDirectory();
      //print("Directory : ${directory.path}");
      final file = File('${directory.path}/registered.txt');
      if(await file.exists()){
        print("File Exists");
      }
      String text = await file.readAsString();
      //print("Data found : $text");
      Map<String,dynamic> r = jsonDecode(text);
      r.forEach((key, value) {
        Map<String,Recognition> m = {key : Recognition.fromJson(value)};
        registered.addAll(m);
      });
      //print("Registered : ${r['khushal'].runtimeType}");
    } catch (e) {
      print(e);
    }
  }

  void _writeValue() async{
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var file = File("$path/registered.txt");
    if(await file.exists()){
      file.delete();
    }
    String text = jsonEncode(registered);
    await file.writeAsString(text, mode:FileMode.writeOnly);
  }

  @override
  void initState() {
    super.initState();
    _readValue();
    faceDetector = FaceDetector (options: FaceDetectorOptions (performanceMode: FaceDetectorMode.fast));
    _recognizer = Recognizer (registered);
    initializeCamera();
  }

  initializeCamera() async {
    try {
      var status = await Permission.camera.status;
      if (status.isDenied) {
        print("Camera Status : $status");
        if (await Permission.speech.isPermanentlyDenied) {
          print("OpenSettings");
          openAppSettings();
        }
        else {
          print("Ask permission");
          openAppSettings();
        }
      }

      controller = CameraController(description, ResolutionPreset.high);
      await controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller.startImageStream((image) =>
        {
          if (!isBusy) {isBusy = true, frame = image, doFaceDetectionOnFrame()}
        });
      });
    }
    catch(e){
      print(e);
      openAppSettings();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EntryScreen()));
    }
  }

  @override
  void dispose() {
    Future.delayed(Duration(seconds:2), () {
      controller?.dispose();
    });
    super.dispose();
  }

  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame() async {
    InputImage inputImage = getInputImage ();
    List<Face> faces = await faceDetector.processImage(inputImage);
    //print("count=${faces.length}");
    performFaceRecognition (faces);
  }
  img.Image? image;
  bool register = false;

  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();
    image = _convertYUV420(frame!);
    image =img.copyRotate(image!, camDirec == CameraLensDirection.front?270:90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      print("FaceRect : $faceRect");
      img.Image croppedFace = img.copyCrop(image!, faceRect.left.toInt(),faceRect.top.toInt(),faceRect.width.toInt(),faceRect.height.toInt());
      Recognition recognition = _recognizer.recognize(croppedFace!, faceRect);
      if(recognition.distance>1){
        recognition.name = "Unknown";
      }
      recognitions.add(recognition);
      if(recognition.name!="Unknown"){
        Navigator.pushReplacementNamed(context, '/dashboard', arguments: recognition.name);
      }

      if(register){
        showFaceRegistrationDialogue(croppedFace!,recognition);
        register = false;
      }

    }
    if(this.mounted) {
      setState(() {
        isBusy = false;
        _scanResults = recognitions;
      });
    }

  }

  TextEditingController textEditingController = TextEditingController();
  showFaceRegistrationDialogue(img.Image croppedFace, Recognition recognition){
    if(registered.length==3){
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Face Registration", textAlign: TextAlign.center),alignment: Alignment.center,
            content: SizedBox(
              height: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20,),
                  const Text("3 faces are already registered. Limit reached.", textAlign: TextAlign.center,),
                  ElevatedButton(onPressed: (){ Navigator.pop(context);},
                      child: const Text("Close"))
                ],
              ),
            )
        )
      );
    }
    else {
      showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
              title: const Text(
                  "Face Registration", textAlign: TextAlign.center),
              alignment: Alignment.center,
              content: SizedBox(
                height: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20,),
                    Image.memory(
                      Uint8List.fromList(img.encodeBmp(croppedFace!)),
                      width: 200, height: 200,),
                    SizedBox(
                      width: 200,
                      child: TextField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: "Enter Name")
                      ),
                    ),
                    const SizedBox(height: 10,),
                    ElevatedButton(
                        onPressed: () {
                          Recognizer.registered.putIfAbsent(
                              textEditingController.text, () => recognition);
                          _writeValue();
                          textEditingController.text = "";
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Face Registered"),
                              ));
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.blue,
                            minimumSize: const Size(200, 40)),
                        child: const Text("Register"))
                  ],
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
      );
    }
  }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width, height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = yuv2rgb(y, u, v);
      }
    }
    return image;
  }
  img.Image _convertYUV420(CameraImage image) {
    var imag = img.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
      planeOffset < image.height * image.width;
      planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        imag.data[planeOffset + x] = newVal;
      }
    }

    return imag;
  }
  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
    ((b << 16) & 0xff0000) |
    ((g << 8) & 0xff00) |
    (r & 0xff);
  }

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = description;
    final imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat =
    InputImageFormatValue.fromRawValue(frame!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = frame!.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }

  Widget buildResult() {
    if (_scanResults == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(child: Text('Camera is not initialized'));
    }
    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter = FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  void _toggleCameraDirection() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();
    setState(() {
      controller;
    });

    initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: AppBar(
            title: Text(''),// You can add title here
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => Login())),
            ),
            backgroundColor: Colors.blue.withOpacity(0.3), //You can make this transparent
            elevation: 0.0, //No shadow
          ),
        )
      );

      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            )
                : Container(),
          ),
        ),
      );

      stackChildren.add(
        Positioned(
            top: 0.0,
            left: 0.0,
            width: size.width,
            height: size.height,
            child: buildResult()),
      );
    }

    stackChildren.add(Positioned(
      top: size.height - 140,
      left: 0,
      width: size.width,
      height: 80,
      child: Card(
        margin: const EdgeInsets.only(left: 20, right: 20),
        color: Colors.blue,
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cached,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      color: Colors.black,
                      onPressed: () {
                        _toggleCameraDirection();
                      },
                    ),
                    Container(
                      width: 30,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      color: Colors.black,
                      onPressed: () {
                        register = true;
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            margin: const EdgeInsets.only(top: 0),
            color: Colors.black,
            child: Stack(
              children: stackChildren,
            )),
      ),
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.camDire2);

  final Size absoluteImageSize;
  final List<Recognition> faces;
  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.indigoAccent;

    for (Recognition face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.location.right) * scaleX
              : face.location.left * scaleX,
          face.location.top * scaleY,
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.location.left) * scaleX
              : face.location.right * scaleX,
          face.location.bottom * scaleY,
        ),
        paint,
      );

      TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 20),
          text: "${face.name}  ${face.distance.toStringAsFixed(2)}");
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(face.location.left*scaleX, face.location.top*scaleY));
    }

  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
