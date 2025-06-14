//
//  EndpointTestHelper.swift
//  SpaceTests
//
//  Created by Illia Suvorov on 14.06.2025.
//

import Foundation
import XCTest

enum NasaEndpointTestHelper {
    static let baseURL = "https://api.nasa.gov"
    
    static func responseTuple(statusCode: Int = 200, data: Data, subpath: String) -> (
        HTTPURLResponse,
        Data
    ) {
        let response = HTTPURLResponse(
            url: URL(string: "\(baseURL)/\(subpath)")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (response, data)
    }
    
    static func responseExpectations(_ testCase: XCTestCase, success: Bool) -> (
        success: XCTestExpectation,
        failure: XCTestExpectation
    ) {
        let successExpectation = testCase.expectation(
            description: success ? "should succeed" : "should not succeed"
        )
        successExpectation.isInverted = !success
        let failureExpectation = testCase.expectation(
            description: success ? "should not fail" : "should fail"
        )
        failureExpectation.isInverted = success
        return (successExpectation, failureExpectation)
    }
}
