@testable import PhotoshopReader
import XCTest

final class PhotoshopDocumentTests: XCTestCase {
    func testExample() throws {
        do {
            let data = try getData(name: "customerscanvas_text", fileExtension: "psd")
            let document = try PhotoshopDocument(data: data)
            print(document)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
