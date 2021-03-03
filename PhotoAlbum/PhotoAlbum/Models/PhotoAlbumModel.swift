//
//  PhotoAlbumModel.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 02/03/21.
//

import Foundation

class PhotoAlbumModel: Decodable {
    var userId: Int64?
    var id: Int64?
    var title: String?
}

class PhotoModel: Decodable {
    var albumId: Int64?
    var id: Int64?
    var title: String?
    var url: String?
    var thumbnailUrl: String?
}
