//
//  APODEndpoint.swift
//  Space
//
//  Created by Illia Suvorov on 12.06.2025.
//

import Foundation
import Combine

protocol Enpoint {
    static var subpath: String { get }
    func request(baseUrl: String, apiKey: String) throws -> URLRequest
}

enum APODEndpoint: Enpoint {
    private enum Key: String {
        case date = "date"
        case startDate = "start_date"
        case endDate = "end_date"
        case count = "count"
        case thumbs = "thumbs"
        case apiKey = "api_key"
    }
    /// The Astronomy Picture of the Day (APOD) for today.
    case recent(thumbs: Bool)
    /// The Astronomy Picture of the Day (APOD) for a specific date.
    case date(Date, thumbs: Bool)
    /// The list of Astronomy Pictures of the Day (APOD) for a date range.
    case range(Date, Date, thumbs: Bool)
    /// The list of random Astronomy Pictures of the Days (APODs)
    case random(Int, thumbs: Bool)
    
    static var subpath: String { "planetary/apod" }
    
    func request(baseUrl: String, apiKey: String) throws -> URLRequest {
        let url = URL(string: "\(baseUrl)/\(Self.subpath)")!
        var components = {
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )!
            switch self {
            case .date(let date, let thumbs):
                components.queryItems = [
                    URLQueryItem(
                        name: Key.date.rawValue,
                        value: Formatters.nasaDateFormatter.string(from: date)
                    ),
                    URLQueryItem(
                        name: Key.thumbs.rawValue,
                        value: thumbs ? "true" : "false"
                    )
                ]
            case .range(let startDate, let endDate, let thumbs):
                components.queryItems = [
                    URLQueryItem(
                        name: Key.startDate.rawValue,
                        value: Formatters.nasaDateFormatter
                            .string(from: startDate)
                    ),
                    URLQueryItem(
                        name: Key.endDate.rawValue,
                        value: Formatters.nasaDateFormatter
                            .string(from: endDate)
                    ),
                    URLQueryItem(
                        name: Key.thumbs.rawValue,
                        value: thumbs ? "true" : "false"
                    )
                ]
            case .random(let count, let thumbs):
                components.queryItems = [
                    URLQueryItem(
                        name: Key.count.rawValue,
                        value: String(count)
                    ),
                    URLQueryItem(
                        name: Key.thumbs.rawValue,
                        value: thumbs ? "true" : "false"
                    )
                ]
            case .recent(let thumbs):
                components.queryItems = [
                    URLQueryItem(
                        name: Key.thumbs.rawValue,
                        value: thumbs ? "true" : "false"
                    )
                ]
            }
            return components
        }()
        
        components.queryItems?
            .append(URLQueryItem(name: Key.apiKey.rawValue, value: apiKey))
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        return request
    }
}

enum APODResultMapper {
    private static func map<T: Decodable>(_ response: (data: Data, response: URLResponse)) throws -> T {
        let data = response.data
        guard let response = response.response as? HTTPURLResponse else {
            throw RequestError(
                message: "Invalid response",
                code: "INVALID_RESPONSE"
            )
        }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(Formatters.nasaDateFormatter)

        guard response.statusCode == 200 else {
            throw try decoder.decode(RequestError.self, from: data)
        }
        
        
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        }
        catch {
            throw error
        }
        
        
    }
    
    enum Single {
        static func map(_ response: (data: Data, response: URLResponse)) throws -> APODResult {
            return try APODResultMapper
                .map(
                    (
                        data: response.data,
                        response: response.response as! HTTPURLResponse
                    )
                )
        }
    }
    
    enum List {
        static func map(_ response: (data: Data, response: URLResponse)) throws -> [APODResult] {
            return try APODResultMapper.map(response)
        }
    }
}

struct APODResult: Codable {
    enum MediaType: String, Codable {
        case image
        case video
        case audio
    }
    
    let title: String
    let explanation: String?
    let url: URL
    let hdUrl: URL?
    let mediaType: MediaType
    let copyright: String?
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case title
        case explanation
        case url
        case hdUrl = "hdurl"
        case mediaType = "media_type"
        case copyright
        case date
    }
}

extension APODResult {
    func toDomain() -> AstronomyPicture {
        AstronomyPicture(
            pictureURL: url,
            date: date,
            title: title,
            description: explanation,
            copyright: copyright
        )
    }
}
