import XCTest
@testable import Graph3D

final class Graph3DTests: XCTestCase {

  var basicGraph: Graph3D {
    let vertices: [[Float]] = [[1,1,1], [2,2,2], [3,3,3]]
    return Graph3D(vertices: vertices, edges: [[0, 1], [1,2]])
  }
  var flatGridGraph: Graph3D {
    let vertices: [[Float]] = [
      [0,0,1], [1,0,1], [2,0,1], [3,0,1],
      [0,1,1], [1,1,1], [2,1,1], [3,1,1],
      [0,2,1], [1,2,1], [2,2,1], [3,2,1],
      [0,3,1], [1,3,1], [2,3,1], [3,3,1],
      [0,4,1], [1,4,1], [2,4,1], [3,4,1],
      [0,5,1], [1,5,1], [2,5,1], [3,5,1],
    ]
    let edges: [[Int]] = [
      [0,1], [0,4], [1,2], [1,5], [2,3], [2,6],
      [3,7], [4,5], [4,8], [5,6], [5,9], [6,7],
      [6,10], [7,11], [8,9], [8,12], [9,10], [9,13],
      [10,11], [10,14], [11,15], [12,13], [12,16],
      [13,14], [13,17], [14,15], [14,18], [15,19],
      [16,17], [16,20], [17,18], [17,21], [18,19],
      [18,22], [19,23], [20,21], [21,22], [22,23]
    ]
    return Graph3D(vertices: vertices, edges: edges)
  }

  func testNearestNode() {
    let myGraph = self.basicGraph
    let nearestNode = myGraph.findNearestNode(to: [2,3,2])
    XCTAssertEqual(nearestNode.position, [2,2,2])
  }

  func testManhattanDistance() {
    let myGraph = self.flatGridGraph
    let path = myGraph.doRouting(from: [0,0,1], to: [3,5,1])
    XCTAssertEqual(9, path.count,
      "top left to bottom right returned \(path.count), should be 9"
    )
  }

  static var allTests = [
    ("testNearestNode", testNearestNode),
    ("testManhattanDistance", testManhattanDistance),
  ]
}
