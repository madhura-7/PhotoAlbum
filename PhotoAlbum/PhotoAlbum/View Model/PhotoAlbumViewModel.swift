//
//  PhotoAlbumViewModel.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 02/03/21.
//

import Foundation

class PhotoAlbumViewModel {
    private var dataManager: DataManager?
    private var currentIndex: IndexPath?
    fileprivate var albums: [PhotoAlbumModel]?
    fileprivate var filteredAlbums: [PhotoAlbumModel]?
    private var searchText = ""

    var numberOfItems: Int {
        return isFiltering ? filteredAlbums?.count ?? 0 : albums?.count ?? 0
    }
    var isFiltering: Bool = false

    required init(withManager: DataManager = PhotoAlbumDataManager()) {
        dataManager = withManager
    }

    func getAlbumDetails(callback: @escaping(Error?) -> Void) {
        dataManager?.getAlbumDetails() {(albums, error) in
            //Handle UI update
            guard let validAlbums = albums else { return }
            self.albums = validAlbums
            callback(error)
        }
    }
}

//MARK: View controller communications
extension PhotoAlbumViewModel {
    func setDataSourceIndex(_ indexPath: IndexPath?) {
        currentIndex = indexPath
    }

    func updateSearchText(_ searchString: String, callback: @escaping()-> ()) {
        searchText = searchString

        filteredAlbums = albums?.filter { (album) -> Bool in
            return (album.title?.lowercased().contains(searchString.lowercased()) ?? false)
        }
        callback()
    }

    func getDetailViewModel(_ indexPath: IndexPath) -> AlbumDetailViewModel {
        let selectedAlbum: PhotoAlbumModel?
        if isFiltering {
            selectedAlbum = filteredAlbums?[indexPath.row]
        } else {
            selectedAlbum = albums?[indexPath.row]
        }
        return AlbumDetailViewModel(selectedAlbum) 
    }
}

//MARK: Cell Data Source
extension PhotoAlbumViewModel: CellDataSource {
    var title: String? {
        guard let validDataSource = currentIndex?.row else { return "" }
        if isFiltering {
            return filteredAlbums?[validDataSource].title ?? ""
        }
        return albums?[validDataSource].title ?? ""
    }
}
