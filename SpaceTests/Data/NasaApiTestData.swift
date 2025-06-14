//
//  NasaApiTestData.swift
//  SpaceTests
//
//  Created by Illia Suvorov on 14.06.2025.
//

import Foundation

enum NasaApiTestData {
    static let serverError = """
        {
            "code": "SERVER_ERROR",
            "message": "An unexpected error occurred.",
        }
        """
    
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
    
    static let photoResponse = """
    {"photos":[{"id":287319,"sol":1,"camera":{"id":27,"name":"FHAZ","rover_id":7,"full_name":"Front Hazard Avoidance Camera"},"img_src":"http://mars.nasa.gov/mer/gallery/all/2/f/001/2F126468064EDN0000P1001L0M1-BR.JPG","earth_date":"2004-01-05","rover":{"id":7,"name":"Spirit","landing_date":"2004-01-04","launch_date":"2003-06-10","status":"complete"}},{"id":287320,"sol":1,"camera":{"id":27,"name":"FHAZ","rover_id":7,"full_name":"Front Hazard Avoidance Camera"},"img_src":"http://mars.nasa.gov/mer/gallery/all/2/f/001/2F126468064EDN0000P1001R0M1-BR.JPG","earth_date":"2004-01-05","rover":{"id":7,"name":"Spirit","landing_date":"2004-01-04","launch_date":"2003-06-10","status":"complete"}}]}
    """
    
    static let metadataResponse = """
        {
            "photo_manifest":
            {
                "name":"Spirit",
                "landing_date":"2004-01-04",
                "launch_date":"2003-06-10",
                "status":"complete",
                "max_sol":2208,
                "max_date":"2010-03-21",
                "total_photos":124550,
                "photos":
                [
                    {
                        "sol":1,
                        "earth_date":"2004-01-05",
                        "total_photos":77,
                        "cameras":["ENTRY","FHAZ","NAVCAM","PANCAM","RHAZ"]
                    }
                ]
            }
        }
        """
}
