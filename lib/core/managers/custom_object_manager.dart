import 'package:physics_canon_example/core/extensions.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:cannon_physics/cannon_physics.dart' as cannon;
import 'package:vector_math/vector_math.dart' as vmath;

class CustomObjectManager {
  final three.ThreeJS threeJs;
  final cannon.World world;

  List<three.Object3D> customMeshes = [];
  List<cannon.Body> customBodies = [];

  CustomObjectManager(this.threeJs, this.world);

  Future<void> loadObject(String objPath, String mtlPath,
      {List<double>? position, List<double>? scale, double mass = 1}) async {
    try {
      final objLoader = three.OBJLoader();
      final mtlLoader = three.MTLLoader();

      if (mtlPath.isNotEmpty) {
        final materials = await mtlLoader.fromAsset(mtlPath);
        if (materials == null) {
          throw Exception('Failed to load material file: $mtlPath');
        }
        materials.preload();
        objLoader.setMaterials(materials);
      }
      final object = await objLoader.fromAsset(objPath);
      if (object == null) {
        throw Exception('Failed to load object file: $objPath');
      }

      if (object.children.isEmpty) {
        throw Exception('Loaded object has no meshes');
      }
      if (scale != null) {
        object.scale.setValues(scale[0], scale[1], scale[2]);
      }
      if (position != null) {
        object.position.setValues(position[0], position[1], position[2]);
      }

      threeJs.scene.add(object);
      customMeshes.add(object);

      final body = _createPhysicsBody(object, mass);
      if (body != null) {
        customBodies.add(body);
        world.addBody(body);
      }
    } catch (e, trace) {
      print('Error loading custom object: $e, $trace');
    }
  }

  cannon.Body? _createPhysicsBody(three.Object3D object, double mass) {
    final boundingBox = three.BoundingBox().setFromObject(object);
    final size = boundingBox.min;

    final shape = cannon.Box(vmath.Vector3(size.x / 2, size.y / 2, size.z / 2).toCanonVec3());
      final body = cannon.Body(
      mass: mass,
      position: vmath.Vector3(
        object.position.x,
        object.position.y,
        object.position.z,
      ).toCanonVec3(),
      shape: shape,
    );

    return body;
  }

  void removeObject(int index) {
    /*if (index < 0 || index >= customMeshes.length) return;

    final mesh = customMeshes[index];
    threeJs.scene.remove(mesh);

    mesh.traverse((child) {
      if (child is three.Mesh) {
        child.geometry?.dispose();
        if (child.material is three.Material) {
          (child.material as three.Material).dispose();
        } else if (child.material is List<three.Material>) {
          for (var mat in (child.material as List<three.Material>)) {
            mat.dispose();
          }
        }
      }
    });

    final body = customBodies[index];
    world.removeBody(body);

    customMeshes.removeAt(index);
    customBodies.removeAt(index);*/
  }

  void updatePhysics() {
    //print(customMeshes);
    for (int i = 0; i < customMeshes.length; i++) {
      final mesh = customMeshes[i];
      final body = customBodies[i];

      mesh.position = body.position.toVector3();
      mesh.quaternion = body.quaternion.toQuaternion();
    }
  }
}