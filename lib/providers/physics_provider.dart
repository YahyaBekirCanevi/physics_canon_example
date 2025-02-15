import 'package:cannon_physics/cannon_physics.dart' as cannon;
import 'package:flutter/material.dart';
import 'package:physics_canon_example/core/extensions.dart';
import 'package:physics_canon_example/core/managers/custom_object_manager.dart';
import 'package:physics_canon_example/core/managers/object_manager.dart';
import 'package:physics_canon_example/core/managers/physics_manager.dart';
import 'package:physics_canon_example/core/managers/scene_manager.dart';
import 'package:three_js/three_js.dart' as three;

class PhysicsProvider with ChangeNotifier {
  late final three.ThreeJS threeJs;
  late final SceneManager sceneManager;
  late final PhysicsManager physicsManager;
  late final ObjectManager objectManager;
  late final CustomObjectManager customObjectManager;

  bool _paused = false;

  PhysicsProvider() {
    threeJs = three.ThreeJS(
      onSetupComplete: () => notifyListeners(),
      setup: _setup,
      settings: three.Settings(useSourceTexture: true),
    );
  }

  Future<void> _setup() async {
    sceneManager = SceneManager(threeJs);
    sceneManager.setupScene();

    physicsManager = PhysicsManager();
    physicsManager.initializePhysicsWorld();

    objectManager = ObjectManager(threeJs, physicsManager.world);
    objectManager.createGeometriesAndMaterials();
    objectManager.populateScene(4);

    customObjectManager = CustomObjectManager(threeJs, physicsManager.world);

    await customObjectManager.loadObject(
      'models/d6.obj',
      'models/d6.mtl',
      position: [0, 100, 0],
      scale: [12,12,12],
      mass: 1,
    );

    threeJs.addAnimationEvent((dt) {
      if(_paused) return;
      sceneManager.controls.update();
      physicsManager.updatePhysics(dt);
      customObjectManager.updatePhysics();
      _updateObjects();
    });
  }

  void _updateObjects() {
    for (int i = 0; i < objectManager.bodies.length; i++) {
      cannon.Body body = objectManager.bodies[i];
      three.Mesh mesh = objectManager.meshes[i];

      if (body.sleepState != cannon.BodySleepStates.sleeping) {
        mesh.position = body.position.toVector3();
        mesh.quaternion = body.quaternion.toQuaternion();

        if (mesh.position.y < -100) {
          objectManager.removeObject(i);
        }
      }
    }
  }
  /// Pause the update loop
  void pause() {
    physicsManager.pauseGravity();
    _paused = true;
  }

  /// Resume the update loop
  void resume() {
    physicsManager.resumeGravity();
    _paused = false;
  }
}