//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 02/03/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var viewModel = PhotoAlbumViewModel()
    let cellIdentifier = "PhotoAlbumCellIdentifier"
    let detailViewControllerId = "albumDetailViewController"
    let searchController = UISearchController(searchResultsController: nil)
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingIndicator.startAnimating()
        viewModel.isFiltering = false
        let collectionLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionLayout?.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionLayout?.estimatedItemSize = CGSize(width: 110, height: 110)
        viewModel.getAlbumDetails() { error in
            //Reload UI
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                if error == nil {
                    self.photoCollectionView.reloadData()
                    self.viewModel.isFiltering = self.isFiltering
                } else {
                    let alertController = UIAlertController(title: "Oops!",
                                                            message: "There was an error fetching album details.",
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Album"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

//MARK: Collection View Data Source and Delegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.isFiltering = isFiltering
        return viewModel.numberOfItems
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoAlbumCell
        viewModel.setDataSourceIndex(indexPath)
        viewModel.isFiltering = isFiltering
        cell.updateCellContents(viewModel)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Load Albums
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: detailViewControllerId) as? AlbumDetailViewController {
            detailViewController.viewModel = viewModel.getDetailViewModel(indexPath)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}

//MARK: Search View Controller
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //Update with search filter
        let searchBar = searchController.searchBar
        viewModel.updateSearchText(searchBar.text ?? "") {
            DispatchQueue.main.async {
                self.photoCollectionView.reloadData()
                self.photoCollectionView.setNeedsLayout()
            }
        }
    }

}

