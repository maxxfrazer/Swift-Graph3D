import XCTest
@testable import Graph3D

final class Graph3DTests: XCTestCase {
    func testNearestNode() {
      let vertices: [[Float]] = [[1,1,1], [2,2,2], [3,3,3]]
      let myGraph = Graph3D(vertices: vertices, edges: [[0, 1], [1,2]])
      let nearestNode = myGraph.findNearestNode(to: [2,3,2])
      XCTAssertEqual(nearestNode.position, [2,2,2])
    }

    static var allTests = [
        ("testNearestNode", testNearestNode),
    ]
}
