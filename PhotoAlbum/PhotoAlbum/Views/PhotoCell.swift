//
//  PhotoCell.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 03/03/21.
//

import Foundation
import UIKit

protocol PhotoCellDataSource {
    var photoImageTitle: String? { get }
    var photoImage: UIImage? { get }
    var isLoading: Bool? { get }
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var photoLoadingIndicator: UIActivityIndicatorView!

    override class func awakeFromNib() {
        //Handle theme functions here
    }

    func updateCell(_ dataSource: PhotoCellDataSource?) {
        photoLoadingIndicator.startAnimating()
        self.photoTitleLabel.text = dataSource?.photoImageTitle ?? ""
        if let loadedImage = dataSource?.photoImage {
            self.photoImageView.image = loadedImage
        }
        if !(dataSource?.isLoading ?? false) {
            photoLoadingIndicator.stopAnimating()
        }
    }
}
