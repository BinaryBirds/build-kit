# BuildKit (🔨)

A Swift wrapper around common Swift commands.

## Usage

Some basic examples:

```swift
import BuildKit

let project = Project(path: "~/example")

try project.run(.package(.initialize(.executable)))
try project.run(.package(.update))
try project.run(.package(.generateXcodeProject))

try project.run(.build, flags: [.config(.debug), .stdlib(true)]) 
try project.run(.test, flags: [.parallel])
```

## Install

Just use the Swift Package Manager as usual:

```swift
.package(url: "https://github.com/binarybirds/build-kit", from: "1.0.0"),
```

Don't forget to add "PackageManagerKit" to your target as a dependency:

```swift
.product(name: "BuildKit", package: "build-kit"),
```

That's it.

## License

[WTFPL](LICENSE) - Do what the fuck you want to.
