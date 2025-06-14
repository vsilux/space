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
                data: TestData.photoResponse.data(using: .utf8)!,
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
                data: TestData.serverError.data(using: .utf8)!,
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

extension MarsRoverPhotosEndpointTests {
    enum TestData {
        static let photoResponse = """
        {"photos":[{"id":287319,"sol":1,"camera":{"id":27,"name":"FHAZ","rover_id":7,"full_name":"Front Hazard Avoidance Camera"},"img_src":"http://mars.nasa.gov/mer/gallery/all/2/f/001/2F126468064EDN0000P1001L0M1-BR.JPG","earth_date":"2004-01-05","rover":{"id":7,"name":"Spirit","landing_date":"2004-01-04","launch_date":"2003-06-10","status":"complete"}},{"id":287320,"sol":1,"camera":{"id":27,"name":"FHAZ","rover_id":7,"full_name":"Front Hazard Avoidance Camera"},"img_src":"http://mars.nasa.gov/mer/gallery/all/2/f/001/2F126468064EDN0000P1001R0M1-BR.JPG","earth_date":"2004-01-05","rover":{"id":7,"name":"Spirit","landing_date":"2004-01-04","launch_date":"2003-06-10","status":"complete"}}]}
        """
        
        static let serverError = """
            {
                "code": "SERVER_ERROR",
                "message": "An unexpected error occurred.",
            }
            """
    }
}
