//
//  AstronomyPictureViewModel.swift
//  Space
//
//  Created by Illia Suvorov on 13.06.2025.
//

import Foundation
import SwiftUI
import Combine

class AstronomyPictureViewModel: ObservableObject {
    @Published var pictureModel: AstronomyPicture
    @Published var imageLoadingState: ImageLoadingState = .loading
    @Published var image: Image? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let loadDataUseCase: LoadDataUseCase
    
    init(pictureModel: AstronomyPicture, loadDataUseCase: LoadDataUseCase) {
        self.pictureModel = pictureModel
        self.loadDataUseCase = loadDataUseCase
        loadImage()
    }
    
    private func loadImage() {
        imageLoadingState = .loading
        loadDataUseCase.execute(url: pictureModel.pictureURL)
            .map { Image(uiImage: UIImage(data: $0)!) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.imageLoadingState = .failed
                }
            } receiveValue: { [weak self] uiImage in
                self?.image = uiImage
                self?.imageLoadingState = .loaded
            }
            .store(in: &cancellables)
    }

}

extension AstronomyPictureViewModel {
    enum ImageLoadingState {
        case loading
        case loaded
        case failed
    }
}
