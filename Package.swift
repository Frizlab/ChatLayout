// swift-tools-version:5.1
import PackageDescription


let package = Package(
	name: "STableLayout",
	platforms: [
		.iOS(.v12)
	],
	products: [
		.library(name: "STableLayout",                        targets: ["STableLayout"]),
		.library(name: "STableLayoutStatic",  type: .static,  targets: ["STableLayout"]),
		.library(name: "STableLayoutDynamic", type: .dynamic, targets: ["STableLayout"])
	],
	targets: [
		.target(name: "STableLayout"),
		.testTarget(
			name: "STableLayoutTests",
			dependencies: ["STableLayout"]
		)
	]
)
