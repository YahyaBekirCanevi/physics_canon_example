import 'package:cannon_physics/cannon_physics.dart' as cannon;
import 'package:three_js/three_js.dart' as three;
import 'package:vector_math/vector_math.dart' as vmath;

extension CanonQuaternion on cannon.Quaternion {
  three.Quaternion toQuaternion() {
    return three.Quaternion(x, y, z, w);
  }
}

extension CanonVec3 on cannon.Vec3 {
  three.Vector3 toVector3() {
    return three.Vector3(x, y, z);
  }
}

extension VMathVector3 on vmath.Vector3 {
  cannon.Vec3 toCanonVec3() {
    return cannon.Vec3(x, y, z);
  }
}

extension ThreeVector3 on three.Vector3 {
  three.Vector3 operator + (three.Vector3 v) {
    return three.Vector3(x + v.x, y + v.y, z + v.z);
  }
  three.Vector3 operator - (three.Vector3 v) {
    return three.Vector3(x - v.x, y - v.y, z - v.z);
  }
}