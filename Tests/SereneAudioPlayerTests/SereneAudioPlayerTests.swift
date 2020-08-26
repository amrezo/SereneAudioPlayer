import XCTest
@testable import SereneAudioPlayer

final class SereneAudioPlayerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SereneAudioPlayer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
