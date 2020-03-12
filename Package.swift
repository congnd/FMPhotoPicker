// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "FMPhotoPicker",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "FMPhotoPicker",
            targets: ["FMPhotoPicker"])
    ],
    targets: [
        .target(
            name: "FMPhotoPicker",
            path: ".",
            sources: ["FMPhotoPicker/FMPhotoPicker"])
    ],
    swiftLanguageVersions: [.v5]
)