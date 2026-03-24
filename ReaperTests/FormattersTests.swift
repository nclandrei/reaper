import XCTest
@testable import Reaper

final class FormattersTests: XCTestCase {

    // MARK: - memory(_:)

    func testMemoryFormatsSmallBytesAsMB() {
        // 100 MB in bytes
        let bytes: UInt64 = 100 * 1_048_576
        XCTAssertEqual(Formatters.memory(bytes), "100 MB")
    }

    func testMemoryFormatsZeroBytesAsMB() {
        XCTAssertEqual(Formatters.memory(0), "0 MB")
    }

    func testMemoryFormatsSubMBValueAsMB() {
        // 512 KB = 524288 bytes → ~0.5 MB → rounds to "0 MB" (%.0f)
        let bytes: UInt64 = 524_288
        XCTAssertEqual(Formatters.memory(bytes), "0 MB")
    }

    func testMemoryFormatsExactlyOneGBAsMB() {
        // 1024 MB → should trigger GB formatting
        let bytes: UInt64 = 1024 * 1_048_576
        XCTAssertEqual(Formatters.memory(bytes), "1.0 GB")
    }

    func testMemoryFormatsLargeValueAsGB() {
        // 8 GB
        let bytes: UInt64 = 8 * 1_073_741_824
        XCTAssertEqual(Formatters.memory(bytes), "8.0 GB")
    }

    func testMemoryFormatsJustUnderOneGBAsMB() {
        // 1023 MB in bytes — should stay as MB
        let bytes: UInt64 = 1023 * 1_048_576
        XCTAssertEqual(Formatters.memory(bytes), "1023 MB")
    }

    func testMemoryFormatsDecimalGB() {
        // 1.5 GB = 1536 MB
        let bytes: UInt64 = 1536 * 1_048_576
        XCTAssertEqual(Formatters.memory(bytes), "1.5 GB")
    }

    // MARK: - cpu(_:)

    func testCPUFormatsSmallValueWithOneDecimal() {
        XCTAssertEqual(Formatters.cpu(5.3), "5.3%")
    }

    func testCPUFormatsZero() {
        XCTAssertEqual(Formatters.cpu(0), "0.0%")
    }

    func testCPUFormatsSingleDigitWithDecimal() {
        XCTAssertEqual(Formatters.cpu(9.9), "9.9%")
    }

    func testCPUFormatsExactly10WithoutDecimal() {
        XCTAssertEqual(Formatters.cpu(10.0), "10%")
    }

    func testCPUFormatsLargeValue() {
        XCTAssertEqual(Formatters.cpu(100.0), "100%")
    }

    func testCPUFormatsDoubleDigitRounded() {
        XCTAssertEqual(Formatters.cpu(55.7), "56%")
    }

    // MARK: - memoryFraction(used:total:)

    func testMemoryFractionFormats() {
        let used: UInt64 = 6 * 1_073_741_824  // 6 GB
        let total: UInt64 = 16 * 1_073_741_824 // 16 GB
        XCTAssertEqual(Formatters.memoryFraction(used: used, total: total), "6.0/16 GB")
    }

    func testMemoryFractionWithDecimalUsed() {
        let used: UInt64 = UInt64(6.5 * 1_073_741_824) // ~6.5 GB
        let total: UInt64 = 16 * 1_073_741_824
        XCTAssertEqual(Formatters.memoryFraction(used: used, total: total), "6.5/16 GB")
    }

    func testMemoryFractionZeroUsed() {
        let total: UInt64 = 16 * 1_073_741_824
        XCTAssertEqual(Formatters.memoryFraction(used: 0, total: total), "0.0/16 GB")
    }

    // MARK: - memoryShort(used:total:)

    func testMemoryShortFormats() {
        let used: UInt64 = 6 * 1_073_741_824
        let total: UInt64 = 16 * 1_073_741_824
        XCTAssertEqual(Formatters.memoryShort(used: used, total: total), "6/16G")
    }

    func testMemoryShortZeroUsed() {
        let total: UInt64 = 32 * 1_073_741_824
        XCTAssertEqual(Formatters.memoryShort(used: 0, total: total), "0/32G")
    }

    func testMemoryShortRoundsToNearest() {
        // 6.7 GB → rounds to 7 in short format
        let used: UInt64 = UInt64(6.7 * 1_073_741_824)
        let total: UInt64 = 16 * 1_073_741_824
        XCTAssertEqual(Formatters.memoryShort(used: used, total: total), "7/16G")
    }
}
