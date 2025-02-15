import 'package:three_js/three_js.dart' as three;
import 'package:three_js_geometry/three_js_geometry.dart';

class SceneManager {
  final three.ThreeJS threeJs;
  late final three.OrbitControls controls;

  SceneManager(this.threeJs);

  void setupScene() {
    threeJs.scene = three.Scene();
    _setupCameraAndControls();
    _addLights();
    _addBackground();
  }

  void _setupCameraAndControls() {
    double aspect = threeJs.width / threeJs.height;
    threeJs.camera = three.PerspectiveCamera(60, aspect, 1, 10000);
    threeJs.camera.position.setValues(0, 160, 400);

    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
  }

  void _addLights() {
    threeJs.scene.add(three.AmbientLight(0x3D4143));

    three.DirectionalLight light = three.DirectionalLight(0xffffff, 1.4);
    light.position.setValues(300, 1000, 500);
    light.target!.position.setValues(0, 0, 0);
    light.castShadow = true;
    light.shadow!.mapSize.width = 512; // Reduce shadow map resolution
    light.shadow!.mapSize.height = 512;

    double d = 300;
    light.shadow!.camera = three.OrthographicCamera(-d, d, d, -d, 500, 1600);
    light.shadow!.bias = 0.0001;
    light.shadow!.mapSize.width = light.shadow!.mapSize.height = 1024;

    threeJs.scene.add(light);
  }

  void _addBackground() {
    three.BufferGeometry backgroundGeometry = IcosahedronGeometry(3000, 2);
    three.Mesh background =
        three.Mesh(backgroundGeometry, three.MeshLambertMaterial());
    threeJs.scene.add(background);
  }
}
