# PhotoshopReader

Swift library to read [Photoshop PSD files](https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/).

## Example Usage

Add the following line to your project's SwiftPM dependencies:
```swift
.package(url: "https://github.com/hughbe/PhotoshopReader", from: "1.0.0"),
```

```swift
import PhotoshopReader

let data = Data(contentsOfFile: "<path-to-file>.psdb")!
let document = try PhotoshopDocument(data: data)
print(document.header)
print(document.colorModeData)
for resource in document.imageResources.resources {
    let data = try ImageResourceBlockData(resource: resource)
    print("\(resource.id.hexString): \(resource.data.count) bytes")
}

if let layers = document.layerAndMaskInformation.layerInfo?.layers {
    for layer in layers {
        for additionalInformation in layer.additionalLayerInformation {
            let data = try AdditionalLayerInformationData(layer: additionalInformation)
            print("\(additionalInformation.key): \(additionalInformation.data.count) bytes")
        }
    }
}
```


