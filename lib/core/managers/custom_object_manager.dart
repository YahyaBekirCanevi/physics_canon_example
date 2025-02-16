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

  Future<cannon.Body?> loadObject(String objPath, String mtlPath,
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
        const texturePath = 'assets/models/dice_map.png';
        final texture = await three.TextureLoader().fromAsset(texturePath);
        if (texture == null) {
          throw Exception('Failed to load texture: $texturePath');
        }

        for (var material in materials.materials.values) {
          if (material.map == null) {
            material.map = texture;
            material.needsUpdate = true;
          }
        }
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

      final body = _createPhysicsBody(object, mass);
      if (body == null) {
        throw Exception('Couldn\'t create physics body');
      }
      threeJs.scene.add(object);
      customMeshes.add(object);

      customBodies.add(body);
      world.addBody(body);
      return body;
    } catch (e) {
      print('Error loading custom object: $e');
      rethrow;
    }
  }

  cannon.Body? _createPhysicsBody(three.Object3D object, double mass) {
    final shapes = <cannon.ConvexPolyhedron>[];
    final offsets = <cannon.Vec3>[];

    object.traverse((child) {
      if (child is three.Mesh && child.geometry != null) {
        child.updateMatrixWorld(true);

        final vertices = _extractVertices(child.geometry!);
        final faces = _extractFaces(child.geometry!);
        var normals = <vmath.Vector3>[];
        if (child.geometry!.attributes['normal'] == null) {
          normals = _computeNormals(vertices, faces);
        }
        final shape = _createConvexPolyhedron(vertices, normals, faces);

        shapes.add(shape);
        offsets.add(cannon.Vec3(
          child.position.x,
          child.position.y,
          child.position.z,
        ));
      }
    });

    if (shapes.isEmpty) {
      return null;
    }

    final body = cannon.Body(
      mass: mass,
      position: vmath.Vector3(
        object.position.x,
        object.position.y,
        object.position.z,
      ).toCanonVec3(),
    );

    /*for (var i = 0; i < shapes.length; i++) {
      body.addShape(shapes[i], offsets[i]);
    }*/
    body.addShape(shapes[0]); // Test with a single shape first


    return body;
  }

  List<vmath.Vector3> _extractVertices(three.BufferGeometry geometry) {
    final vertices = <vmath.Vector3>[];
    final positions = geometry.attributes['position'].array;

    for (var i = 0; i < positions.length; i += 3) {
      vertices
          .add(vmath.Vector3(positions[i], positions[i + 1], positions[i + 2]));
    }

    return vertices;
  }

  List<List<int>> _extractFaces(three.BufferGeometry geometry) {
    final faces = <List<int>>[];
    final indices = geometry.index?.array;

    if (indices != null) {
      if (indices.length % 3 != 0) {
        throw Exception('Indices array length must be a multiple of 3');
      }

      for (var i = 0; i < indices.length; i += 3) {
        if (i + 2 >= indices.length) {
          break;
        }

        faces.add([
          indices[i].toInt(),
          indices[i + 1].toInt(),
          indices[i + 2].toInt(),
        ]);
      }
    } else {
      final positions = geometry.attributes['position'].array;
      if (positions.length % 9 != 0) {
        throw Exception('Invalid non-indexed geometry: vertex count must be a multiple of 3');
      }
      for (var i = 0; i < positions.length ~/ 3; i += 3) {
        faces.add([i, i + 1, i + 2]);
      }
    }

    return faces;
  }
  List<vmath.Vector3> _computeNormals(List<vmath.Vector3> vertices, List<List<int>> faces) {
    final normals = List.generate(vertices.length, (_) => vmath.Vector3.zero());

    for (final face in faces) {
      final v0 = vertices[face[0]];
      final v1 = vertices[face[1]];
      final v2 = vertices[face[2]];

      final edge1 = v1 - v0;
      final edge2 = v2 - v0;
      final normal = edge1.cross(edge2)..normalize();

      normals[face[0]] += normal;
      normals[face[1]] += normal;
      normals[face[2]] += normal;
    }

    for (var normal in normals) {
      normal.normalize();
    }

    return normals;
  }

  cannon.ConvexPolyhedron _createConvexPolyhedron(
      List<vmath.Vector3> vertices,List<vmath.Vector3> normals, List<List<int>> faces) {
    final cannonVertices = vertices.map((v) => v.toCanonVec3()).toList();
    final cannonNormals = normals.map((n) => n.toCanonVec3()).toList();
    final cannonFaces = faces.map((f) => f.map((i) => i).toList()).toList();

    return cannon.ConvexPolyhedron(
      vertices: cannonVertices,
      faces: cannonFaces,
      normals: cannonNormals.isEmpty ? null: cannonNormals,
    );
  }

  void updatePhysics() {
    for (int i = 0; i < customMeshes.length; i++) {
      final mesh = customMeshes[i];
      final body = customBodies[i];

      mesh.position = body.position.toVector3();
      mesh.quaternion = body.quaternion.toQuaternion();
    }
  }
}
