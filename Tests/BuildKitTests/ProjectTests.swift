/**
    PackageManagerTests.swift
    BuildKitTests
 
    Created by Tibor Bödecs on 2019.01.01.
    Copyright Binary Birds. All rights reserved.
 */

import XCTest
@testable import BuildKit

final class ProjectTests: XCTestCase {

    static var allTests = [
        ("testInit", testInit),
        ("testUpdate", testUpdate),
        ("testClean", testClean),
        ("testRun", testRun),
        ("testXcodeProjectGeneration", testXcodeProjectGeneration),
    ]
    
    // MARK: - helpers
    
    private func assert<T: Equatable>(type: String, result: T, expected: T) {
        XCTAssertEqual(result, expected, "Invalid \(type) `\(result)`, expected `\(expected)`.")
    }
    
    private func clean(path: String) throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue == true {
            try FileManager.default.removeItem(atPath: path)
        }
    }

    private func _test(_ command: Project.Command, path: String, expectation: String) throws {
        let path = path
        try self.clean(path: path)
        let expectedOutput = expectation
        let project = Project(path: path)
        try project.run(.package(.initialize(.executable)))
        let output = try project.run(command)
        self.assert(type: "output", result: output, expected: expectedOutput)
        try self.clean(path: path)
    }

    // MARK: - test functions

    func testInit() throws {
        let path = "./spm-init-test"

        try self.clean(path: path)

        let expectedOutput = """
            Creating executable package: spm-init-test
            Creating Package.swift
            Creating README.md
            Creating .gitignore
            Creating Sources/
            Creating Sources/spm-init-test/main.swift
            Creating Tests/
            Creating Tests/LinuxMain.swift
            Creating Tests/spm-init-testTests/
            Creating Tests/spm-init-testTests/spm_init_testTests.swift
            Creating Tests/spm-init-testTests/XCTestManifests.swift
            """

        let project = Project(path: path)
        let output = try project.run(.package(.initialize(.executable)))
        self.assert(type: "output", result: output, expected: expectedOutput)
        try self.clean(path: path)
    }
    
    
    
    func testUpdate() throws {
        try self._test(.package(.update),
                       path: "./spm-update-test",
                       expectation: "Everything is already up-to-date")
    }
    
    func testClean() throws {
        try self._test(.package(.clean),
                       path: "./spm-clean-test",
                       expectation: "")
    }
    
    func testRun() throws {
        try self._test(.run,
                       path: "./spm-run-test",
                       expectation: "Hello, world!")
    }

    func testXcodeProjectGeneration() throws {
        try self._test(.package(.generateXcodeProject),
                       path: "./spm-xcode-generation-test",
                       expectation: "generated: ./spm-xcode-generation-test.xcodeproj")
    }
    
    #if os(macOS)
    func testAsyncRun() throws {
        let path = "./spm-async-run-test"
        try self.clean(path: path)
        let expectedOutput = "Hello, world!"
        let project = Project(path: path)
        try project.run(.package(.initialize(.executable)))
 
        let expectation = XCTestExpectation(description: "Shell command finished.")
        project.run(.run, flags: [.config(.release)]) { result, error in
            if let error = error {
                try? self.clean(path: path)
                return XCTFail("There should be no errors. (error: `\(error.localizedDescription)`)")
            }
            guard let output = result else {
                try? self.clean(path: path)
                return XCTFail("Empty result, expected `\(expectedOutput)`.")
            }
            self.assert(type: "output", result: output, expected: expectedOutput)
            try? self.clean(path: path)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 5)
    }
    #endif

}
