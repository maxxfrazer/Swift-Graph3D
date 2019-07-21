//
//  Graph3D.swift
//
//
//  Created by Max Cobb on 7/21/19.
//

import GameplayKit

public enum RouterError: Error {
  case noVertices
  case badVertex
  case noEdges
  case badEdge
  case emptyListOfDestinations
  case edgeOutOfBounds
  case noShortestPath
  case failedToParse
  case couldNotRoute
  case noRouting
}

extension Array where Element: RouteVertex {
  internal func length() -> Float {
    let arr = self as [RouteVertex]
    return arr.enumerated().map({ (arg) -> Float in
      let (index, value) = arg
      return index > 0 ? value.distance(to: arr[index - 1]) : 0
    }).reduce(0, +)
  }
}
extension Array where Element: SIMD {
  internal func length() -> Float {
    let arr = self as! [SIMD3<Float>]
    return arr.enumerated().map({ (arg) -> Float in
      let (index, value) = arg
      return index > 0 ? value.distance(to: arr[index - 1]) : 0
    }).reduce(0, +)
  }
}

public class Graph3D: GKGraph {
  var edges = [[Int]]()
  var vertices = [[Float]]()
  internal var vertexNodes = [RouteVertex]()

  public convenience init(vertices: [[Double]], edges: [[Int]]) {
    self.init(
      vertices: vertices.map{$0.map { Float($0)}},
      edges: edges
    )
  }

  public init(vertices: [[Float]], edges: [[Int]]) {
    super.init()
    self.edges = edges
    self.vertices = vertices
    let nodes = vertices.map { vertice in RouteVertex(position: vertice) }
    edges.forEach { edge in
      nodes[edge[0]].addConnection(to: nodes[edge[1]])
    }
    self.vertexNodes = nodes
  }


  internal func findNearestNode(to position: SIMD3<Float>, between nodes: [RouteVertex]) -> RouteVertex {
    let newNode = RouteVertex(position)
    return nodes.reduce(nodes[0]) { (best, next) -> RouteVertex in
      return newNode.cost(to: next) < newNode.cost(to: best) ? next : best
    }
  }

  internal func findNearestNode(to position: SIMD3<Float>) -> RouteVertex {
    return self.findNearestNode(to: position, between: self.vertexNodes)
  }


  /// Find the closest point on the graph to a given point
  internal func findPointOnEdge(from startPoint: SIMD3<Float>) -> (SIMD3<Float>, [RouteVertex]) {
    var closestPoint = self.vertexNodes[edges[0][0]].getVectorPos()
    var closestDistance = startPoint.distance(to: closestPoint)
    var matchingNodes = [self.vertexNodes[edges[0][0]], self.vertexNodes[edges[0][1]]]
    for point in edges {
      let node1 = self.vertexNodes[point[0]]
      let node2 = self.vertexNodes[point[1]]
      let p1 = node1.getVectorPos()
      let p2 = node2.getVectorPos()
      if startPoint == p1 {
        return (p1, [node1])
      } else if startPoint == p2 {
        return (p2, [node2])
      }

      let newPoint = startPoint.onLine(start: p1, end: p2)

      let newDistance = newPoint.distance(to: startPoint)
      if closestDistance > newDistance {
        closestPoint = newPoint
        closestDistance = newDistance
        matchingNodes = [node1, node2]
      }
    }
    return (closestPoint, matchingNodes)
  }
//  internal func doRouting(from start: RouteVertex, to end: RouteVertex) -> [RouteVertex] {
//    [self.findPath(from: start, to: end) as! RouteVertex]
//  }
  internal func doRouting(from worldPosition: SIMD3<Float>, to targetPosition: SIMD3<Float>) -> [SIMD3<Float>]
  {
    let (edgeStart, endsOfEdgeStart) = self.findPointOnEdge(from: worldPosition)
    let (edgeEnd, endsOfEdgeEnd) = self.findPointOnEdge(from: targetPosition)
    var allPaths = [[RouteVertex]]()
    let startEdgesSet = Set(endsOfEdgeStart)
    let endEdgesSet = Set(endsOfEdgeEnd)
    let endsOfEdgesIntersection = startEdgesSet.intersection(endEdgesSet)
    if endsOfEdgesIntersection.count > 0 {
      var myResult: [SIMD3<Float>] = [edgeStart, edgeEnd]
      if endsOfEdgesIntersection.count == 1, let firstIntersection = endsOfEdgesIntersection.first {
        myResult.insert(firstIntersection.getVectorPos(), at: 1)
      }
      if let firstResult = myResult.first, firstResult != worldPosition && firstResult.distance(to: worldPosition) > 0.5 {
        myResult.insert(SIMD3<Float>(worldPosition.x, firstResult.y, worldPosition.z), at: 0)
      }
      return myResult
    }
    for endStart in endsOfEdgeStart {
      for endEnd in endsOfEdgeEnd {
        allPaths.append(self.findPath(from: endStart, to: endEnd) as! [RouteVertex])
      }
    }

    var newPath = allPaths.reduce(nil) { (bestPath, nextPath) -> [SIMD3<Float>] in
      var nextval = nextPath.length()
      nextval += edgeStart.distance(to: nextPath[0].getVectorPos())
      nextval += edgeEnd.distance(to: nextPath.last!.getVectorPos())
      if let bestPath = bestPath, nextval >= bestPath.length() {
        return bestPath
      }
      var newBest = nextPath.map { $0.getVectorPos() }
      if newBest.first! != edgeStart {
        newBest.insert(edgeStart, at: 0)
      }
      if newBest.last! != edgeEnd {
        newBest.append(edgeEnd)
      }
      return newBest
    }
    if let pathFirst = newPath?.first, pathFirst != worldPosition, pathFirst.distance(to: worldPosition) > 0.5 {
      newPath?.insert(SIMD3<Float>(worldPosition.x, pathFirst.y, worldPosition.z), at: 0)
    }
    return newPath!
  }
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public func parseRouter(data: Data) throws -> Graph3D {
  do {
    if let parsedJson = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
      if let jsonBlock = parsedJson["routing"] as? [String: Any]  {
        return try parseRouter(jsonBlock: jsonBlock)
      } else {
        throw RouterError.noRouting
      }
    } else {
      throw RouterError.failedToParse
    }
  } catch {
    print("could not serialize json \(error)")
    throw RouterError.failedToParse
  }
}


internal func parseRouter(jsonBlock: [String: Any]) throws -> Graph3D {
  if let vertices = jsonBlock["vertices"] as? [[Double]], let edges = jsonBlock["edges"] as? [[Int]] {
    if vertices.count < 2 {
      throw vertices.isEmpty ? RouterError.noVertices : RouterError.noEdges
    }
    for v in vertices {
      if v.count != 3 {
        throw RouterError.badVertex
      }
    }
    for e in edges {
      if e.count != 2 {
        throw RouterError.badEdge
      } else if e[0] >= vertices.count || e[1] >= vertices.count {
        throw RouterError.edgeOutOfBounds
      }
    }

    let router = Graph3D(vertices: vertices, edges: edges)
    return router
  } else {
    throw RouterError.failedToParse
  }
}
