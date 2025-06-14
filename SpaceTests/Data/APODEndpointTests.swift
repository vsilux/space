//
//  NasaRepositoryTests.swift
//  SpaceTests
//
//  Created by Illia Suvorov on 12.06.2025.
//

import Foundation
import XCTest
import Combine

@testable import Space

final class APODEndpointTests: XCTestCase {
    var cancelables = Set<AnyCancellable>()
    
    func testAPODEndpoint() throws {
        let urlSession = MockUrlProtocol.urlSession
        MockUrlProtocol.requestHandler = { request in
            return NasaEndpointTestHelper.responseTuple(
                data: TestData.apodResponse.data(using: .utf8)!,
                subpath: APODEndpoint.subpath
            )
        }
        
        let request = try APODEndpoint.recent(thumbs: false).request(
            baseUrl: NasaEndpointTestHelper.baseURL,
            apiKey: ""
        )
        
        let expectations = NasaEndpointTestHelper.responseExpectations(
            self,
            success: true
        )
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.Single.map)
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
    
    func testAPODEndpointErrorResponse() throws {
        let urlSession = MockUrlProtocol.urlSession
        MockUrlProtocol.requestHandler = { request in
            return NasaEndpointTestHelper.responseTuple(
                statusCode: 500,
                data: TestData.serverError.data(using: .utf8)!,
                subpath: APODEndpoint.subpath
            )
        }
        
        let request = try APODEndpoint.recent(thumbs: false).request(
            baseUrl: NasaEndpointTestHelper.baseURL,
            apiKey: ""
        )
        
        let expectations = NasaEndpointTestHelper.responseExpectations(
            self,
            success: false
        )
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.List.map)
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
    
    func testAPODEndpointSuccessListResponse() throws {
        let urlSession = MockUrlProtocol.urlSession
        MockUrlProtocol.requestHandler = { request in
            return NasaEndpointTestHelper.responseTuple(
                data: "[\(TestData.apodResponse)]".data(using: .utf8)!,
                subpath: APODEndpoint.subpath
            )
        }
        
        let request = try APODEndpoint.recent(thumbs: false).request(
            baseUrl: NasaEndpointTestHelper.baseURL,
            apiKey: ""
        )
        
        let expectations = NasaEndpointTestHelper.responseExpectations(
            self,
            success: true
        )
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.List.map)
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

extension APODEndpointTests {
    enum TestData {
        static let apodResponse: String = """
            {
                "copyright": "Fred Espenak",
                "date": "2025-06-12",
                "explanation": "On April 20",
                "hdurl": "https://apod.nasa.gov/apod/image/2506/TSE2023-Comp48-2a.jpg",
                "media_type": "image",
                "service_version": "v1",
                "title": "Solar Eclipse",
                "url": "https://apod.nasa.gov/apod/image/2506/TSE2023-Comp48-2a1024.jpg"
            }
            """
        
        static let serverError = """
            {
                "code": "SERVER_ERROR",
                "message": "An unexpected error occurred.",
            }
            """
    }
}

