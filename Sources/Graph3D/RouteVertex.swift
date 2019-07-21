//
//  RouteVertex.swift
//  
//
//  Created by Max Cobb on 7/21/19.
//

import GameplayKit.GKGraph

internal class RouteVertex: GKGraphNode3D {
  var travelCost: [GKGraphNode: Float] = [:]

  var simdPos: SIMD3<Float> {
    return SIMD3<Float>(self.position)
  }

  convenience init(position: [Float]) {
    self.init(point: vector_float3(position))
  }

  convenience init(_ position: SIMD3<Float>) {
    self.init(point: vector_float3(position))
  }

  override init(point: vector_float3) {
    super.init(point: point)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func getVectorPos() -> SIMD3<Float> {
    return SIMD3<Float>(self.position)
  }

  func addConnection(to node: RouteVertex) {
    self.addConnections(to: [node], bidirectional: true)
    let weight = self.distance(to: node)
    travelCost[node] = weight
    node.travelCost[self] = weight
  }
  func distance(to: RouteVertex) -> Float {
    let pos = SIMD3<Float>(self.position)
    return pos.distance(to: SIMD3<Float>(to.position))
  }
  func distanceSq(to: RouteVertex) -> Float {
    return self.simdPos.distanceSq(to: to.simdPos)
  }

  func cost(to node: RouteVertex) -> Float {
    return self.distance(to: node)
  }

  override public func cost(to node: GKGraphNode) -> Float {
    if let node = node as? RouteVertex {
      return self.distance(to: node)
    } else {
      return super.cost(to: node)
    }
  }
}
