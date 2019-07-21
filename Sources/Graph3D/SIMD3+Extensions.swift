//
//  SIMD3+Extensions.swift
//  
//
//  Created by Max Cobb on 7/21/19.
//

import Foundation
import simd

internal extension SIMD3 where SIMD3.Scalar: FloatingPoint {
  func lengthSq() -> Scalar {
    var lengthSq = self.x * self.x
    lengthSq += self.y * self.y
    lengthSq += self.z * self.z
    return lengthSq
  }
  func length() -> Scalar {
    return sqrt(self.lengthSq())
  }
  /**
  * Calculates the dot product between two SIMD3<Scalar>.
  */
  func dot(vector: SIMD3<Scalar>) -> Scalar {
    return x * vector.x + y * vector.y + z * vector.z
  }

  func distanceSq(to point: SIMD3<Scalar>) -> Scalar {
    return (self - point).lengthSq()
  }

  func distance(to point: SIMD3<Scalar>) -> Scalar {
    return sqrt(distanceSq(to: point))
  }
  func onLine(start: SIMD3<Scalar>, end: SIMD3<Scalar>) -> SIMD3<Scalar> {
    let lineDist = (start - end).lengthSq()
    let selfStart = self - start
    let endStart = end - start
    let dotProd = selfStart.dot(vector: endStart)
    var t = dotProd / lineDist
    if t < 0 {
      t = 0
    } else if t > 1 {
      t = 1
    }
    return end * t + start * (1 - t)
  }
}

//func -(lhs: SIMD3<SIMD.Scalar.Scalar>, rhs: SIMD3<SIMD3.Scalar>) -> SIMD3<SIMD3.Scalar> {
//  SIMD3<SIMD3.Scalar>(
//}


