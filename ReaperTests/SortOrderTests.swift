import XCTest
@testable import Reaper

final class SortOrderTests: XCTestCase {

    func testAllCasesExist() {
        let cases = SortOrder.allCases
        XCTAssertEqual(cases.count, 3)
        XCTAssertTrue(cases.contains(.cpu))
        XCTAssertTrue(cases.contains(.memory))
        XCTAssertTrue(cases.contains(.name))
    }

    func testRawValues() {
        XCTAssertEqual(SortOrder.cpu.rawValue, "CPU")
        XCTAssertEqual(SortOrder.memory.rawValue, "Memory")
        XCTAssertEqual(SortOrder.name.rawValue, "Name")
    }

    func testIdentifiableConformance() {
        // id should equal rawValue
        XCTAssertEqual(SortOrder.cpu.id, "CPU")
        XCTAssertEqual(SortOrder.memory.id, "Memory")
        XCTAssertEqual(SortOrder.name.id, "Name")
    }

    func testIdentifiableIDsAreUnique() {
        let ids = SortOrder.allCases.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All SortOrder ids should be unique")
    }
}
