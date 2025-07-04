//
//  MarsRoverPhotosEndpointTests.swift
//  SpaceTests
//
//  Created by Illia Suvorov on 14.06.2025.
//

import XCTest
import Combine
@testable import Space

final class MarsRoverPhotosEndpointTests: XCTestCase {
    var cancelables = Set<AnyCancellable>()
    
    func testMarsRoverPhotosEndpoint() throws {
        let urlSession = MockUrlProtocol.urlSession
        MockUrlProtocol.requestHandler = { request in
            return NasaEndpointTestHelper.responseTuple(
                data: NasaApiTestData.photoResponse.data(using: .utf8)!,
                subpath: MarsRoverPhotosEndpoint.subpath
            )
        }
        
        let request = try MarsRoverPhotosEndpoint.photos(rover: .curiosity, sol: 1, camera: .fhaz, page: 1)
            .request(baseUrl: NasaEndpointTestHelper.baseURL, apiKey: "")
        let expectations = NasaEndpointTestHelper.responseExpectations(self, success: true)
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(MarsRoverPhotoResultMapper.map)
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
        
        let request = try MarsRoverPhotosEndpoint.photos(rover: .curiosity, sol: 1, camera: .fhaz, page: 1)
            .request(baseUrl: NasaEndpointTestHelper.baseURL, apiKey: "")
        
        let expectations = NasaEndpointTestHelper.responseExpectations(self, success: false)
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(MarsRoverPhotoResultMapper.map)
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
