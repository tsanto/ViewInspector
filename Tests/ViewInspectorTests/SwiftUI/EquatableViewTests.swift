import XCTest
import SwiftUI
@testable import ViewInspector

final class EquatableViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = sampleView.equatable()
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testRetainsModifiers() throws {
        let view = Text("Test").equatable().padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 2)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(EquatableView(content: Text("")))
        XCTAssertNoThrow(try view.inspect().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            EquatableView(content: Text(""))
            EquatableView(content: Text(""))
        }
        XCTAssertNoThrow(try view.inspect().text(0))
        XCTAssertNoThrow(try view.inspect().text(1))
    }
}
