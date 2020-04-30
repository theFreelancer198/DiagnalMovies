//
//  DMMoviesListViewModel.swift
//  DiagnalMovies
//
//  Created by Abhishek on 30/04/20.
//  Copyright © 2020 Abhishek. All rights reserved.
//

import Foundation

protocol MoviesViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

final class MoviesViewModel {
    private weak var delegate: MoviesViewModelDelegate?
    
    var movies: [Movie] = []
    var title: String = ""
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    
    init(delegate: MoviesViewModelDelegate) {
        self.delegate = delegate
    }
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return movies.count
    }
    
    func movie(at index: Int) -> Movie {
        return movies[index]
    }
    
    func fetchMovies() {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        
        if let path = Bundle.main.path(forResource: "CONTENTLISTINGPAGE-PAGE\(currentPage)", ofType: "json") {
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: data)
                self.currentPage += 1
                self.isFetchInProgress = false
                self.total = Int(apiResponse.responseDetails.totalItems)!
                self.title = apiResponse.responseDetails.title
                self.movies.append(contentsOf: apiResponse.responseDetails.contentItem.content)
                if Int(apiResponse.responseDetails.currentPage)! > 1 {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: apiResponse.responseDetails.contentItem.content)
                    self.delegate?.onFetchCompleted(with: indexPathsToReload)
                } else {
                    self.delegate?.onFetchCompleted(with: .none)
                }
            } catch {
                self.isFetchInProgress = false
                self.delegate?.onFetchFailed(with: error.localizedDescription)
            }
            
        }
        else{
            self.isFetchInProgress = false
            self.delegate?.onFetchFailed(with: "Json file not found.")
        }
    }
    
    private func calculateIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
        let startIndex = movies.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}
