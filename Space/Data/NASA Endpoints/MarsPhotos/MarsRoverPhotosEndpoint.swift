//
//  MarsPhotosEndpoint.swift
//  Space
//
//  Created by Illia Suvorov on 13.06.2025.
//

import Foundation

enum MarsRoverPhotosEndpoint: Enpoint {
    private enum Key: String {
        case sol = "sol"
        case camer = "camera"
        case page = "page"
        case apiKey = "api_key"
    }
    
    static var subpath: String { "mars-photos/api/v1/rovers" }
    static let maxRecordsPerPage = 25
    
    case photos(
        rover: MarsRover,
        sol: Int,
        camera: MarsRover.Camera,
        page: Int = 1
    )
    
    func request(baseUrl: String, apiKey: String) throws -> URLRequest {
        var components: URLComponents!
        
        switch self {
        case let .photos(rover, sol, camera, page):
            let url = URL(string: "\(baseUrl)/\(Self.subpath)/\(rover)/photos")!
            components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: Key.sol.rawValue, value: "\(sol)"),
                URLQueryItem(name: Key.camer.rawValue, value: camera.rawValue),
                URLQueryItem(name: Key.page.rawValue, value: "\(page)"),
            ]
        }
        
        components.queryItems?
            .append(URLQueryItem(name: Key.apiKey.rawValue, value: apiKey))
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        return request
    }
}

struct MarsRoverPhotoResult: Codable {
    let photos: [Photo]
    
    struct Photo: Codable {
        let id, sol: Int
        let camera: Camera
        let imgSrc: String
        let earthDate: String
        let rover: Rover

        enum CodingKeys: String, CodingKey {
            case id, sol, camera
            case imgSrc = "img_src"
            case earthDate = "earth_date"
            case rover
        }
    }
    
    struct Camera: Codable {
        let id: Int
        let name: String
        let roverID: Int
        let fullName: String

        enum CodingKeys: String, CodingKey {
            case id, name
            case roverID = "rover_id"
            case fullName = "full_name"
        }
    }
    
    struct Rover: Codable {
        let id: Int
        let name, landingDate, launchDate, status: String

        enum CodingKeys: String, CodingKey {
            case id, name
            case landingDate = "landing_date"
            case launchDate = "launch_date"
            case status
        }
    }
}

enum MarsRoverPhotoResultMapper {
    static func map(_ response: (data: Data, response: URLResponse)) throws -> MarsRoverPhotoResult {
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
            let object = try decoder.decode(MarsRoverPhotoResult.self, from: data)
            return object
        }
        catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
}
