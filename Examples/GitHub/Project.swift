import ProjectDescription

// MARK: - Constants

let name = "GitHub"
let organizationnName = "jjgp.schematics"

// MARK: - Info

let infoPlist: [String: InfoPlist.Value] = [
    "CFBundleShortVersionString": "1.0",
    "CFBundleVersion": "1",
    "UIMainStoryboardFile": "",
    "UILaunchStoryboardName": "LaunchScreen"
]

// MARK: - Packages

let packages: [Package] = [
    .package(path: "../../") // Schematics
]

// MARK: - Targets

let mainTarget = Target(
    name: name,
    platform: .iOS,
    product: .app,
    bundleId: "\(organizationnName).\(name)",
    infoPlist: .extendingDefault(with: infoPlist),
    sources: ["Targets/\(name)/Sources/**"],
    resources: ["Targets/\(name)/Resources/**"],
    dependencies: [
        .package(product: "UnidirectionalSchema")
    ]
)

let testTarget = Target(
    name: "\(name)Tests",
    platform: .iOS,
    product: .unitTests,
    bundleId: "\(organizationnName).\(name)Tests",
    infoPlist: .default,
    sources: ["Targets/\(name)/Tests/**"],
    dependencies: [
        .target(name: "\(name)")
    ]
)

let targets = [mainTarget, testTarget]

// MARK: - Project

let project = Project(name: name,
                      organizationName: organizationnName,
                      packages: packages,
                      targets: targets)
