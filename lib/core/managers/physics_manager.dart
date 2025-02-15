import 'package:cannon_physics/cannon_physics.dart' as cannon;

class PhysicsManager {
  late cannon.World world;
  late double lastCallTime;

  PhysicsManager();

  void initializePhysicsWorld() {
    world = cannon.World();
    world.quatNormalizeSkip = 0;
    world.quatNormalizeFast = false;

    cannon.GSSolver solver = cannon.GSSolver();
    solver.iterations = 20;
    solver.tolerance = 0.1;
    world.solver = cannon.SplitSolver(solver);

    world.gravity = cannon.Vec3(0, -200, 0);
    world.broadphase = cannon.NaiveBroadphase();
    world.defaultContactMaterial.contactEquationStiffness = 1e9;
    world.defaultContactMaterial.contactEquationRelaxation = 4;
  }

  void pauseGravity() {
    world.gravity = cannon.Vec3(0, 0, 0);
  }

  void resumeGravity() {
    world.gravity = cannon.Vec3(0, -200, 0);
  }

  void updatePhysics(double dt) {
    world.step(dt);
  }
}
