//
//  NasaRepository.swift
//  Space
//
//  Created by Illia Suvorov on 12.06.2025.
//

import Foundation
import Combine

protocol NasaRepository {
    func fetchAPOD() throws -> AnyPublisher<APODResult, Error>
    func fetchAPOD(for date: Date) throws -> AnyPublisher<APODResult, Error>
    func fetchAPOD(for startDate: Date, endDate: Date) throws -> AnyPublisher<[APODResult], Error>
    func fetchRandomAPODs(count: Int) throws -> AnyPublisher<[APODResult], Error>
}

class DefaultNasaRepository: NasaRepository {
    private let baseURL = "https://api.nasa.gov"
    private let apiKey: String = "F1rccbbRPs8wrK32tOdraCOYJNQ988bYtuLzEbEp"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchAPOD() throws -> AnyPublisher<APODResult, any Error> {
        let request = try APODEndpoint.recent(thumbs: false)
            .request(baseUrl: baseURL, apiKey: apiKey)
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.Single.map)
            .eraseToAnyPublisher()
    }
    
    func fetchAPOD(for date: Date) throws -> AnyPublisher<APODResult, any Error> {
        let request = try APODEndpoint.date(date, thumbs: false)
            .request(baseUrl: baseURL, apiKey: apiKey)
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.Single.map)
            .eraseToAnyPublisher()
    }
    
    func fetchAPOD(for startDate: Date, endDate: Date) throws -> AnyPublisher<[APODResult], any Error> {
        let request = try APODEndpoint.range(startDate, endDate, thumbs: false)
            .request(baseUrl: baseURL, apiKey: apiKey)
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.List.map)
            .eraseToAnyPublisher()
    }
    
    func fetchRandomAPODs(count: Int) throws -> AnyPublisher<[APODResult], any Error> {
        let request = try APODEndpoint.random(count, thumbs: false)
            .request(baseUrl: baseURL, apiKey: apiKey)
        
        return urlSession.dataTaskPublisher(for: request)
            .tryMap(APODResultMapper.List.map)
            .eraseToAnyPublisher()
    }
}
