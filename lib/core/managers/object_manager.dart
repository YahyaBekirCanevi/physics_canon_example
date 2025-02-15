import 'package:physics_canon_example/core/extensions.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_geometry/three_js_geometry.dart';
import 'package:cannon_physics/cannon_physics.dart' as cannon;
import 'package:vector_math/vector_math.dart' as vmath;
import 'dart:math' as math;

class ObjectManager {
  final three.ThreeJS threeJs;
  final cannon.World world;

  List<three.Mesh> meshes = [];
  List<three.Mesh> grounds = [];
  List<cannon.Body> bodies = [];

  Map<String, three.BufferGeometry> geometries = {};
  Map<String, three.Material> materials = {};

  ObjectManager(this.threeJs, this.world);

  void createGeometriesAndMaterials() {
    geometries['sphere'] = three.SphereGeometry(1, 16, 10);
    geometries['box'] = three.BoxGeometry(1, 1, 1);
    geometries['cylinder'] = CylinderGeometry(1, 1, 1);

    materials['sph'] =
        three.MeshPhongMaterial.fromMap({'shininess': 10, 'name': 'sph'});
    materials['box'] =
        three.MeshPhongMaterial.fromMap({'shininess': 10, 'name': 'box'});
    materials['cyl'] =
        three.MeshPhongMaterial.fromMap({'shininess': 10, 'name': 'cyl'});
    materials['ground'] = three.MeshPhongMaterial.fromMap({
      'shininess': 10,
      'color': 0x3D4143,
      'transparent': true,
      'opacity': 0.5,
    });
  }

  void addStaticBox(
      List<double> size, List<double> position, List<double> rotation) {
    three.Mesh mesh = three.Mesh(geometries['box'], materials['ground']);
    mesh.scale.setValues(size[0], size[1], size[2]);
    mesh.position.setValues(position[0], position[1], position[2]);
    mesh.rotation.set(rotation[0], rotation[1], rotation[2]);
    threeJs.scene.add(mesh);
    grounds.add(mesh);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
  }

  void clearMeshes() {
    for (var mesh in meshes) {
      threeJs.scene.remove(mesh);
    }
    for (var ground in grounds) {
      threeJs.scene.remove(ground);
    }
    meshes.clear();
    grounds.clear();
  }

  void populateScene(int type) {
    clearMeshes();
    bodies.clear();

    _addGroundBodies();
    _addObjects(type);
  }

  void _addGroundBodies() {
    world.addBody(cannon.Body(
      shape: cannon.Box(
          vmath.Vector3(40.0 / 2, 40.0 / 2, 390.0 / 2).toCanonVec3()),
      position: vmath.Vector3(-180.0, 20.0, 0.0).toCanonVec3(),
    ));
    world.addBody(cannon.Body(
      shape: cannon.Box(
          vmath.Vector3(40.0 / 2, 40.0 / 2, 390.0 / 2).toCanonVec3()),
      position: vmath.Vector3(180.0, 20.0, 0.0).toCanonVec3(),
    ));
    world.addBody(cannon.Body(
      shape: cannon.Box(
          vmath.Vector3(400.0 / 2, 80.0 / 2, 400.0 / 2).toCanonVec3()),
      position: vmath.Vector3(0.0, -40.0, 0.0).toCanonVec3(),
    ));

    addStaticBox([40, 40, 390], [-180, 20, 0], [0, 0, 0]);
    addStaticBox([40, 40, 390], [180, 20, 0], [0, 0, 0]);
    addStaticBox([400, 80, 400], [0, -40, 0], [0, 0, 0]);
  }

  void _addObjects(int type) {
    int max = 10;
    for (int i = 0; i < max; i++) {
      int objectType =
          (type == 4) ? (math.Random().nextDouble() * 3).floor() + 1 : type;
      _createObject(objectType, i);
    }
  }

  void _createObject(int type, int index) {
    double x = -100 + math.Random().nextDouble() * 200;
    double z = -100 + math.Random().nextDouble() * 200;
    double y = 100 + math.Random().nextDouble() * 1000;
    double w = 10 + math.Random().nextDouble() * 10;
    double h = 10 + math.Random().nextDouble() * 10;
    double d = 10 + math.Random().nextDouble() * 10;
    three.Color color =
        three.Color.fromHex32((math.Random().nextDouble() * 0xFFFFFF).toInt());

    if (type == 1) {
      _createSphere(w, x, y, z, color, index);
    } else if (type == 2) {
      _createBox(w, h, d, x, y, z, color, index);
    } else if (type == 3) {
      _createCylinder(w, h, x, y, z, color, index);
    }
  }

  void _createSphere(double radius, double x, double y, double z,
      three.Color color, int index) {
    three.Material mat = materials['sph']!;
    mat.color = color;
    cannon.Body body = cannon.Body(
      shape: cannon.Sphere(radius * 0.5),
      position: vmath.Vector3(x, y, z).toCanonVec3(),
      mass: 1,
    );

    body.allowSleep = true;
    body.sleepSpeedLimit = 0.2; // Adjust as needed
    bodies.add(body);
    world.addBody(body);
    meshes.add(three.Mesh(geometries['sphere'], mat));
    meshes[index].scale.setValues(radius * 0.5, radius * 0.5, radius * 0.5);
    _addMeshToScene(index);
  }

  void _createBox(double width, double height, double depth, double x, double y,
      double z, three.Color color, int index) {
    three.Material mat = materials['box']!;
    mat.color = color;
    cannon.Body body = cannon.Body(
      shape: cannon.Box(
          vmath.Vector3(width / 2, height / 2, depth / 2).toCanonVec3()),
      position: vmath.Vector3(x, y, z).toCanonVec3(),
      mass: 1,
    );

    body.allowSleep = true;
    body.sleepSpeedLimit = 0.2; // Adjust as needed
    bodies.add(body);
    world.addBody(body);
    meshes.add(three.Mesh(geometries['box'], mat));
    meshes[index].scale.setValues(width, height, depth);
    _addMeshToScene(index);
  }

  void _createCylinder(double radius, double height, double x, double y,
      double z, three.Color color, int index) {
    three.Material mat = materials['cyl']!;
    mat.color = color;
    cannon.Body body = cannon.Body(
      shape: cannon.Cylinder(
          radiusTop: radius * 0.5, radiusBottom: radius * 0.5, height: height),
      position: vmath.Vector3(x, y, z).toCanonVec3(),
      mass: 1,
    );

    body.allowSleep = true;
    body.sleepSpeedLimit = 0.2; // Adjust as needed
    bodies.add(body);
    world.addBody(body);
    meshes.add(three.Mesh(geometries['cylinder'], mat));
    meshes[index].scale.setValues(radius * 0.5, height, radius * 0.5);
    _addMeshToScene(index);
  }

  void _addMeshToScene(int index) {
    meshes[index].castShadow = true;
    meshes[index].receiveShadow = true;
    threeJs.scene.add(meshes[index]);
  }

  void removeObject(int index) {
    /*three.Mesh mesh = meshes[index];
    threeJs.scene.remove(mesh);

    mesh.geometry?.dispose();
    if (mesh.material is three.Material) {
      (mesh.material as three.Material).dispose();
    } else if (mesh.material is List<three.Material> && mesh.material != null) {
      for (var mat in (mesh.material as List<three.Material>)) {
        mat.dispose();
      }
    }

    cannon.Body body = bodies[index];
    world.removeBody(body);

    meshes.removeAt(index);
    bodies.removeAt(index);*/
  }
}
