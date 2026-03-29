import XCTest
@testable import Reaper

final class MenuBarStyleTests: XCTestCase {

    func testAllCasesExist() {
        let cases = MenuBarStyle.allCases
        XCTAssertEqual(cases.count, 10)
        XCTAssertTrue(cases.contains(.skull))
        XCTAssertTrue(cases.contains(.pillBar))
        XCTAssertTrue(cases.contains(.segments))
        XCTAssertTrue(cases.contains(.thinLine))
        XCTAssertTrue(cases.contains(.ringGauge))
        XCTAssertTrue(cases.contains(.battery))
        XCTAssertTrue(cases.contains(.dots))
        XCTAssertTrue(cases.contains(.miniBars))
        XCTAssertTrue(cases.contains(.dualStack))
        XCTAssertTrue(cases.contains(.textOnly))
    }

    func testRawValues() {
        XCTAssertEqual(MenuBarStyle.skull.rawValue, "Skull")
        XCTAssertEqual(MenuBarStyle.pillBar.rawValue, "Pill Bar")
        XCTAssertEqual(MenuBarStyle.segments.rawValue, "Segments")
        XCTAssertEqual(MenuBarStyle.thinLine.rawValue, "Thin Line")
        XCTAssertEqual(MenuBarStyle.ringGauge.rawValue, "Ring Gauge")
        XCTAssertEqual(MenuBarStyle.battery.rawValue, "Battery")
        XCTAssertEqual(MenuBarStyle.dots.rawValue, "Dots")
        XCTAssertEqual(MenuBarStyle.miniBars.rawValue, "Mini Bars")
        XCTAssertEqual(MenuBarStyle.dualStack.rawValue, "Dual Stack")
        XCTAssertEqual(MenuBarStyle.textOnly.rawValue, "Text Only")
    }

    func testIdentifiableConformance() {
        for style in MenuBarStyle.allCases {
            XCTAssertEqual(style.id, style.rawValue)
        }
    }

    func testIdentifiableIDsAreUnique() {
        let ids = MenuBarStyle.allCases.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All MenuBarStyle ids should be unique")
    }

    func testDefaultForCPU() {
        XCTAssertEqual(MenuBarStyle.defaultForCPU, .skull)
    }

    func testDefaultForMemory() {
        XCTAssertEqual(MenuBarStyle.defaultForMemory, .skull)
    }
}
