//
//  AstronomyPictureView.swift
//  Space
//
//  Created by Illia Suvorov on 13.06.2025.
//

import SwiftUI

struct AstronomyPictureView: View {
    @StateObject var viewModel: AstronomyPictureViewModel
    
    init(viewModel: AstronomyPictureViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                imageView
                    .frame(height: 350)
                    .scaledToFill()
                Text(viewModel.pictureModel.title)
                    .font(.title.bold())
                    .padding(.horizontal)
                Text(viewModel.pictureModel.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                if let description = viewModel.pictureModel.description {
                    Text(description)
                        .padding()
                }
                
                if let copyright = viewModel.pictureModel.copyright {
                    Text("© \(copyright)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Picture of the day")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var imageView: some View {
        Group {
            switch viewModel.imageLoadingState {
            case .loading:
                ProgressView()
            case .loaded:
                viewModel.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failed:
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AstronomyPictureView(
            viewModel: AstronomyPictureViewModel(
                pictureModel: AstronomyPicture(
                    pictureURL: URL(
                        string: "https://apod.nasa.gov/apod/image/2506/TSE2023-Comp48-2a1024.jpg"
                    )!,
                    date: Date(),
                    title: "Total Solar Eclipse",
                    description: "On April 20, 2023, a total solar eclipse crossed parts of Australia and Indonesia. This image captures the moment of totality, where the moon completely obscures the sun.",
                    copyright: "Fred Espenak"
                ),
                loadDataUseCase: DefaultLoadDataUseCase(urlSession: .shared)
            )
        )
    }
}
