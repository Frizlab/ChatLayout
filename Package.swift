// swift-tools-version:5.1
import PackageDescription


let package = Package(
	name: "ChatLayout",
	platforms: [
		.iOS(.v12)
	],
	products: [
		.library(name: "ChatLayout",                        targets: ["ChatLayout"]),
		.library(name: "ChatLayoutStatic",  type: .static,  targets: ["ChatLayout"]),
		.library(name: "ChatLayoutDynamic", type: .dynamic, targets: ["ChatLayout"])
	],
	targets: [
		.target(name: "ChatLayout"),
		.testTarget(
			name: "ChatLayoutTests",
			dependencies: ["ChatLayout"]
		)
	]
)
