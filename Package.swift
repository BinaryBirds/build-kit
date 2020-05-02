// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "build-kit",
    products: [
        .library(name: "BuildKit", targets: ["BuildKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/binarybirds/shell-kit", from: "1.0.0"),
    ],
    targets: [
        .target(name: "BuildKit", dependencies: [
            .product(name: "ShellKit", package: "shell-kit"),
        ]),
        .testTarget(name: "BuildKitTests", dependencies: ["BuildKit"]),
    ]
)
