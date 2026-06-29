// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "native_translator",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "native-translator",
            type: .dynamic,
            targets: ["native_translator"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "native_translator",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/native_translator",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
