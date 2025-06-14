//
//  MarsRoverMetadataEndpoint.swift
//  Space
//
//  Created by Illia Suvorov on 14.06.2025.
//

import Foundation

enum MarsRoverMetadataEndpoint: Enpoint {
    static var subpath: String { "mars-photos/api/v1/manifests" }
        
    case metadata(rover: MarsRover)
    
    func request(baseUrl: String, apiKey: String) throws -> URLRequest {
        var url: URL!
        switch self {
        case .metadata(let rover):
            url = URL(string: "\(baseUrl)/\(Self.subpath)/\(rover)")
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        return request
    }
}

struct RoverManifestResult: Codable {
    let photoManifest: PhotoManifest

    enum CodingKeys: String, CodingKey {
        case photoManifest = "photo_manifest"
    }
    
    struct PhotoManifest: Codable {
        let name, landingDate, launchDate, status: String
        let maxSol: Int
        let maxDate: Date
        let totalPhotos: Int
        let photos: [Photo]

        enum CodingKeys: String, CodingKey {
            case name
            case landingDate = "landing_date"
            case launchDate = "launch_date"
            case status
            case maxSol = "max_sol"
            case maxDate = "max_date"
            case totalPhotos = "total_photos"
            case photos
        }
    }
    
    struct Photo: Codable {
        let sol: Int
        let earthDate: Date
        let totalPhotos: Int
        let cameras: [MarsRover.Camera]

        enum CodingKeys: String, CodingKey {
            case sol
            case earthDate = "earth_date"
            case totalPhotos = "total_photos"
            case cameras
        }
    }
}

enum RoverManifestResultMapper {
    static func map(_ response: (data: Data, response: URLResponse)) throws -> RoverManifestResult {
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
            let object = try decoder.decode(RoverManifestResult.self, from: data)
            return object
        }
        catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
}
