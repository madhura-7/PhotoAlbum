//
//  PhotoAlbumCell.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 02/03/21.
//

import Foundation
import UIKit

protocol CellDataSource {
    var title: String? { get }
}

class PhotoAlbumCell: UICollectionViewCell {

    @IBOutlet weak var photoAlbumLabel: UILabel!

    override class func awakeFromNib() {
        //Update theme here
    }

    func updateCellContents(_ dataSource: CellDataSource) {
        photoAlbumLabel.text = dataSource.title
    }
}
