//
//  DateFormatters.swift
//  Space
//
//  Created by Illia Suvorov on 12.06.2025.
//

import Foundation

enum Formatters {
    static var nasaDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
