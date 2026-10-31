// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PingoLogic",
    platforms: [.macOS(.v13), .iOS(.v17)],
    products: [.library(name: "PingoLogic", targets: ["PingoLogic"])],
    targets: [
        .target(name: "PingoLogic", path: "Shared/Logic"),
        .testTarget(name: "PingoLogicTests", dependencies: ["PingoLogic"], path: "Tests/PingoLogicTests"),
    ]
)
