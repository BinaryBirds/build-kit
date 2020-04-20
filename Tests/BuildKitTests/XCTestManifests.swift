/**
   LinuxMain.swift
   BuildKitTests

   Created by Tibor Bödecs on 2019.01.01.
   Copyright Binary Birds. All rights reserved.
*/

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ProjectTests.allTests),
    ]
}
#endif
