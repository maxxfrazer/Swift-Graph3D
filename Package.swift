// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Graph3D",
    platforms: [
      .iOS(.v10),
      .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Graph3D",
            targets: ["Graph3D"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Graph3D",
            dependencies: []),
        .testTarget(
            name: "Graph3DTests",
            dependencies: ["Graph3D"]),
    ]
)
