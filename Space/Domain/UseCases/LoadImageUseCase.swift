//
//  LoadImageUseCase.swift
//  Space
//
//  Created by Illia Suvorov on 13.06.2025.
//

import Foundation
import Combine

protocol LoadDataUseCase {
    func execute(url: URL) -> AnyPublisher<Data, Error>
}

struct DefaultLoadDataUseCase: LoadDataUseCase {
    let urlSession: URLSession
    
    func execute(url: URL) -> AnyPublisher<Data, Error> {
        urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
