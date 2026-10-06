// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "carrotquest_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "carrotquest-sdk", targets: ["carrotquest_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/carrotquest/carrotquest-ios-spm", exact: "3.4.1")
    ],
    targets: [
        .target(
            name: "carrotquest_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "CarrotSDK", package: "carrotquest-ios-spm")
            ]
        )
    ]
)
