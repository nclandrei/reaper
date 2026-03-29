import XCTest
@testable import Reaper

final class MenuBarRendererTests: XCTestCase {

    // MARK: - skull

    func testSkullReturnsNonTemplateImage() {
        let img = MenuBarRenderer.skull(fill: 0.5)
        XCTAssertFalse(img.isTemplate)
        XCTAssertEqual(img.size.width, 18, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 18, accuracy: 0.01)
    }

    func testSkullAtDifferentFills() {
        // Green eyes
        let low = MenuBarRenderer.skull(fill: 0.2)
        XCTAssertFalse(low.isTemplate)
        // Yellow eyes
        let mid = MenuBarRenderer.skull(fill: 0.5)
        XCTAssertFalse(mid.isTemplate)
        // Red eyes
        let high = MenuBarRenderer.skull(fill: 0.8)
        XCTAssertFalse(high.isTemplate)
    }

    // MARK: - pillBar

    func testPillBarReturnsTemplateImage() {
        let img = MenuBarRenderer.pillBar(fill: 0.5)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 24, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 10, accuracy: 0.01)
    }

    func testPillBarAtZero() {
        let img = MenuBarRenderer.pillBar(fill: 0.0)
        XCTAssertTrue(img.isTemplate)
        XCTAssertGreaterThan(img.size.width, 0)
    }

    func testPillBarAtFull() {
        let img = MenuBarRenderer.pillBar(fill: 1.0)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 24, accuracy: 0.01)
    }

    // MARK: - segments

    func testSegmentsReturnsTemplateImage() {
        let img = MenuBarRenderer.segments(fill: 0.5)
        XCTAssertTrue(img.isTemplate)
        // 8 segments * (3 + 1.5) - 1.5 = 34.5
        XCTAssertEqual(img.size.width, 34.5, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 10, accuracy: 0.01)
    }

    // MARK: - thinLine

    func testThinLineReturnsTemplateImage() {
        let img = MenuBarRenderer.thinLine(fill: 0.5)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 32, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 4, accuracy: 0.01)
    }

    // MARK: - ringGauge

    func testRingGaugeReturnsTemplateImage() {
        let img = MenuBarRenderer.ringGauge(fill: 0.75)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 14, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 14, accuracy: 0.01)
    }

    func testRingGaugeAtZeroStillReturnsImage() {
        let img = MenuBarRenderer.ringGauge(fill: 0.0)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 14, accuracy: 0.01)
    }

    // MARK: - battery

    func testBatteryReturnsTemplateImage() {
        let img = MenuBarRenderer.battery(fill: 0.5)
        XCTAssertTrue(img.isTemplate)
        // totalW = 26 + 4 = 30
        XCTAssertEqual(img.size.width, 30, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 11, accuracy: 0.01)
    }

    // MARK: - dots

    func testDotsReturnsTemplateImage() {
        let img = MenuBarRenderer.dots(fill: 0.5)
        XCTAssertTrue(img.isTemplate)
        // 8 * (4 + 2.5) - 2.5 = 49.5
        XCTAssertEqual(img.size.width, 49.5, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 4, accuracy: 0.01)
    }

    // MARK: - miniBars

    func testMiniBarsReturnsTemplateImage() {
        let samples = [10.0, 30.0, 50.0, 70.0, 90.0, 60.0, 40.0, 20.0]
        let img = MenuBarRenderer.miniBars(samples: samples)
        XCTAssertTrue(img.isTemplate)
        // 8 * (3 + 1.5) - 1.5 = 34.5
        XCTAssertEqual(img.size.width, 34.5, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 14, accuracy: 0.01)
    }

    func testMiniBarsWithEmptySamples() {
        let img = MenuBarRenderer.miniBars(samples: [])
        XCTAssertTrue(img.isTemplate)
        XCTAssertGreaterThan(img.size.width, 0)
    }

    func testMiniBarsWithFewerThanEightSamples() {
        let img = MenuBarRenderer.miniBars(samples: [50.0, 75.0])
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 34.5, accuracy: 0.01)
    }

    func testMiniBarsWithMoreThanEightSamples() {
        let samples = Array(stride(from: 10.0, through: 100.0, by: 10.0))
        let img = MenuBarRenderer.miniBars(samples: samples)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 34.5, accuracy: 0.01)
    }

    // MARK: - dualStack

    func testDualStackReturnsTemplateImage() {
        let img = MenuBarRenderer.dualStack(cpu: 0.5, mem: 0.7)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 28, accuracy: 0.01)
        XCTAssertEqual(img.size.height, 12, accuracy: 0.01)
    }

    func testDualStackAtZero() {
        let img = MenuBarRenderer.dualStack(cpu: 0.0, mem: 0.0)
        XCTAssertTrue(img.isTemplate)
        XCTAssertEqual(img.size.width, 28, accuracy: 0.01)
    }
}
