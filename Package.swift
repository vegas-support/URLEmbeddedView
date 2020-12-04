// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "URLEmbeddedView",
    platforms: [ .iOS(.v9) ],
    products: [
        .library(name: "URLEmbeddedView", targets: ["URLEmbeddedView"])
    ],
    targets: [
        .target(
            name: "URLEmbeddedView",
            path: "URLEmbeddedView",
            exclude: ["URLEmbeddedView.h"],
            resources: [
                .process("../Resources/URLEmbeddedViewOGData.xcdatamodeld"),
                .process("../Resources/LinkIcon.pdf")
            ])
    ]
)
