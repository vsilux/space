//
//  MarsRoverMetadataEndpointTests.swift
//  SpaceTests
//
//  Created by Illia Suvorov on 14.06.2025.
//

import Foundation
import XCTest
import Combine

@testable import Space

final class MarsRoverMetadataEndpointTests: XCTestCase {
    var cancelables = Set<AnyCancellable>()
    
    func testMarsRoverMetadataEndpoint() throws {
        let urlSession = MockUrlProtocol.urlSession
        MockUrlProtocol.requestHandler = { request in
            return NasaEndpointTestHelper.responseTuple(
                data: NasaApiTestData.metadataResponse.data(using: .utf8)!,
                subpath: MarsRoverMetadataEndpoint.subpath
            )
        }
        
        let request = try MarsRoverMetadataEndpoint.metadata(rover: .spirit)
            .request(baseUrl: NasaEndpointTestHelper.baseURL, apiKey: "")
        let expectations = NasaEndpointTestHelper.responseExpectations(self, success: true)
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(MarsRoverManifestResultMapper.map)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    print("Error: \(error)")
                    expectations.failure.fulfill()
                }
            }, receiveValue: { _ in
                expectations.success.fulfill()
            }).store(in: &cancelables)
                
        wait(for: [expectations.success, expectations.failure], timeout: 1.0)
    }
    
    func testMarsRoverPhotosEndpointErrorResponse() throws {
        let urlSession = MockUrlProtocol.urlSession
        MockUrlProtocol.requestHandler = { request in
            return NasaEndpointTestHelper.responseTuple(
                statusCode: 500,
                data: NasaApiTestData.serverError.data(using: .utf8)!,
                subpath: MarsRoverPhotosEndpoint.subpath
            )
        }
        
        let request = try MarsRoverMetadataEndpoint.metadata(rover: .spirit)
            .request(baseUrl: NasaEndpointTestHelper.baseURL, apiKey: "")
        
        let expectations = NasaEndpointTestHelper.responseExpectations(self, success: false)
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(MarsRoverManifestResultMapper.map)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    print("Error: \(error)")
                    expectations.failure.fulfill()
                }
            }, receiveValue: { _ in
                expectations.success.fulfill()
            }).store(in: &cancelables)
        
        wait(for: [expectations.success, expectations.failure], timeout: 1.0)
    }
}
