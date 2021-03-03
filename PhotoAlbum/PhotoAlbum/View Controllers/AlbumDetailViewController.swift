//
//  AlbumDetailViewController.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 03/03/21.
//

import Foundation
import UIKit

class AlbumDetailViewController: UIViewController {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var albumPhotosCollectionView: UICollectionView!
    var viewModel: AlbumDetailViewModel?
    let cellIdentifier = "photoCellIdentifier"

    override func viewDidLoad() {
        loadingIndicator.startAnimating()
        self.title = viewModel?.screenTitle
        let collectionLayout = albumPhotosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionLayout?.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionLayout?.estimatedItemSize = CGSize(width: 110, height: 110)
        
        viewModel?.getAlbumPhotos() { error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    if error == nil {
                        self.albumPhotosCollectionView.reloadData()
                    } else {
                        let alertController = UIAlertController(title: "Oops!",
                                                                message: "There was an error fetching photo details.",
                                                                preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        viewModel?.updateUI = { (indexPath) in
            DispatchQueue.main.async {
                self.albumPhotosCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
}

//MARK: Collection view DataSource and Delegate
extension AlbumDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfPhotos ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
        viewModel?.setDataSourceIndex(indexPath)
        viewModel?.isScrolling = !collectionView.isDragging && !collectionView.isDecelerating
        cell.updateCell(viewModel)

        return cell
    }


}
