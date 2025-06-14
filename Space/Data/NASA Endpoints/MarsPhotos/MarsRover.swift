//
//  MarsRover.swift
//  Space
//
//  Created by Illia Suvorov on 14.06.2025.
//

import Foundation

enum MarsRover: String {
    case curiosity = "curiosity"
    case opportunity = "opportunity"
    case spirit = "spirit"
    enum Camera: String, Codable, CaseIterable {
        case entry = "ENTRY"
        case fhaz = "FHAZ" // Front Hazard Avoidance Camera
        case rhaz = "RHAZ" // Rear Hazard Avoidance Camera
        case navcam = "NAVCAM" // Navigation Camera
        // Curiocity specific cameras
        case mast = "MAST" // Mast Camera
        case chemcam = "CHEMCAM" // Chemistry and Camera Complex
        case mahli = "MAHLI" // Mars Hand Lens Imager
        case mardi = "MARDI" // Mars Descent Imager
        // Opportunity and Spirit specific cameras
        case pancam = "PANCAM" // Panoramic Camera
        case minites = "MINITES" // Miniature Thermal Emission Spectrometer
    }
}
