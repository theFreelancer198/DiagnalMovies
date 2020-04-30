//
//  DMMovieListViewController.swift
//  DiagnalMovies
//
//  Created by Abhishek on 27/04/20.
//  Copyright © 2020 Abhishek. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MovieListCell"
private let sectionInsets = UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15)
private let itemsPerRow: CGFloat = 3

class DMMovieListViewController: UIViewController {
    
    @IBOutlet weak var movieListCollectionView: UICollectionView!
    private var viewModel: MoviesViewModel!
    private let searchController = UISearchController(searchResultsController: nil)
    var filteredMovies: [Movie] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        movieListCollectionView.dataSource = self
        movieListCollectionView.delegate = self
        movieListCollectionView.prefetchDataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barStyle = .black
        searchController.searchBar.returnKeyType = UIReturnKeyType.default

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav_bar.png"), for: .default)

        getMovieDetails()
        
        self.title = viewModel.title
    }
    private func getMovieDetails(){
        viewModel = MoviesViewModel(delegate: self)
        viewModel.fetchMovies()
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    func filterContentForSearchText(_ searchText: String) {
        filteredMovies = viewModel.movies.filter{(movie: Movie) -> Bool in
            return movie.name.lowercased().contains(searchText.lowercased())
        }
        movieListCollectionView.reloadData()
    }
  
}

// MARK: UICollectionViewDataSource
extension DMMovieListViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemCount:Int = 0
        if isFiltering {
           itemCount = filteredMovies.count
        }
        else{
            itemCount = Int(viewModel.totalCount)
        }
        if itemCount == 0 {
            collectionView.setEmptyView(title: "Oops!!!", message: "No items found.")
        } else {
            collectionView.restore()
        }
        return itemCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DMMovieListCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DMMovieListCell
        if isFiltering {
            cell.configure(with: filteredMovies[indexPath.row])
        }
        else{
            if isLoadingCell(for: indexPath) {
                cell.configure(with: .none)
            } else {
                cell.configure(with: viewModel.movie(at: indexPath.row))
            }
        }
        return cell
    }
}
// MARK: UICollectionViewPrefetchDataSource
extension DMMovieListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchMovies()
        }
    }
}
// MARK: - Collection View Flow Layout Delegate
extension DMMovieListViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem*1.5 + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
}

//MARK: ViewModel Delegate
extension DMMovieListViewController: MoviesViewModelDelegate,AlertHandler {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            movieListCollectionView.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        movieListCollectionView.reloadItems(at: indexPathsToReload)
    }
    func onFetchFailed(with reason: String) {
        displayAlert(with: "Error", message: reason, actions: [ UIAlertAction(title: "OK", style: .default)])
    }
}
//MARK: Logic to load visible cells
private extension DMMovieListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currentCount
    }
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = movieListCollectionView.indexPathsForVisibleItems 
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

extension DMMovieListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
