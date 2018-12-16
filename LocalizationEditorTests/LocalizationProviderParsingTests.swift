//
//  LocalizationEditorTests.swift
//  LocalizationEditorTests
//
//  Created by Igor Kulman on 16/12/2018.
//  Copyright © 2018 Igor Kulman. All rights reserved.
//

import XCTest
import AppKit
@testable import LocalizationEditor

class LocalizationProviderParsingTests: XCTestCase {

    func testSingleLanguageParsing() {
        let provider = LocalizationProvider()
        let groups = provider.getLocalizations(url: createTestingDirectory(with: [TestFile(originalFileName: "LocalizableStrings-en.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "Base.lproj")]))

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].name, "LocalizableStrings.strings")
        XCTAssertEqual(groups[0].localizations.count, 1)
        XCTAssertEqual(groups[0].localizations[0].language, "Base")
        XCTAssertEqual(groups[0].localizations[0].translations.count, 18)
    }

    func testMultipleLanguagesParsing() {
        let provider = LocalizationProvider()
        let groups = provider.getLocalizations(url: createTestingDirectory(with: [TestFile(originalFileName: "LocalizableStrings-en.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "Base.lproj"), TestFile(originalFileName: "LocalizableStrings-sk.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "sk.lproj")]))

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].name, "LocalizableStrings.strings")
        XCTAssertEqual(groups[0].localizations.count, 2)
        XCTAssertEqual(groups[0].localizations[0].language, "Base")
        XCTAssertEqual(groups[0].localizations[1].language, "sk")
        XCTAssertEqual(groups[0].localizations[0].translations.count, 18)
        XCTAssertEqual(groups[0].localizations[1].translations.count, 18)
    }

    func testMultipleLanguageParsingWithMissingTranslations() {
        let provider = LocalizationProvider()
        let groups = provider.getLocalizations(url: createTestingDirectory(with: [TestFile(originalFileName: "LocalizableStrings-en.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "Base.lproj"), TestFile(originalFileName: "LocalizableStrings-sk-missing.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "sk.lproj")]))

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].name, "LocalizableStrings.strings")
        XCTAssertEqual(groups[0].localizations.count, 2)
        XCTAssertEqual(groups[0].localizations[0].language, "Base")
        XCTAssertEqual(groups[0].localizations[1].language, "sk")
        XCTAssertEqual(groups[0].localizations[0].translations.count, 18)
        XCTAssertEqual(groups[0].localizations[1].translations.count, 15)
    }

    func testMultipleGroupsAndLanguagesParsing() {
        let provider = LocalizationProvider()
        let groups = provider.getLocalizations(url: createTestingDirectory(with: [TestFile(originalFileName: "LocalizableStrings-en.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "Base.lproj"), TestFile(originalFileName: "LocalizableStrings-sk.strings", destinationFileName: "LocalizableStrings.strings", destinationFolder: "sk.lproj"),TestFile(originalFileName: "InfoPlist-en.strings", destinationFileName: "InfoPlist.strings", destinationFolder: "Base.lproj"), TestFile(originalFileName: "InfoPlist-sk.strings", destinationFileName: "InfoPlist.strings", destinationFolder: "sk.lproj")]))

        XCTAssertEqual(groups.count, 2)

        XCTAssertEqual(groups[0].name, "InfoPlist.strings")
        XCTAssertEqual(groups[0].localizations.count, 2)
        XCTAssertEqual(groups[0].localizations[0].language, "Base")
        XCTAssertEqual(groups[0].localizations[1].language, "sk")
        XCTAssertEqual(groups[0].localizations[0].translations.count, 2)
        XCTAssertEqual(groups[0].localizations[1].translations.count, 2)

        XCTAssertEqual(groups[1].name, "LocalizableStrings.strings")
        XCTAssertEqual(groups[1].localizations.count, 2)
        XCTAssertEqual(groups[1].localizations[0].language, "Base")
        XCTAssertEqual(groups[1].localizations[1].language, "sk")
        XCTAssertEqual(groups[1].localizations[0].translations.count, 18)
        XCTAssertEqual(groups[1].localizations[1].translations.count, 18)
    }

    private func getFullPath(for fileName: String) -> URL {
        let bundle = Bundle(for: type(of: self))
        return bundle.bundleURL.appendingPathComponent("Contents").appendingPathComponent("Resources").appendingPathComponent(fileName)
    }

    private func createTestingDirectory(with files: [TestFile]) -> URL {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
        for file in try! FileManager.default.contentsOfDirectory(atPath: tmp.path) {
            try? FileManager.default.removeItem(at: tmp.appendingPathComponent(file))
        }
        for file in files {
            try? FileManager.default.createDirectory(at: tmp.appendingPathComponent(file.destinationFolder), withIntermediateDirectories: false, attributes: nil)
            try? FileManager.default.removeItem(at: tmp.appendingPathComponent(file.destinationFolder).appendingPathComponent(file.destinationFileName))
            try! FileManager.default.copyItem(at: getFullPath(for: file.originalFileName), to: tmp.appendingPathComponent(file.destinationFolder).appendingPathComponent(file.destinationFileName))
        }
        return tmp
    }
}
