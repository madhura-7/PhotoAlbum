//
//  PhotoAlbumDataManager.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 02/03/21.
//

import Foundation

protocol DataManager {
    func getAlbumDetails(callback: @escaping([PhotoAlbumModel]?, Error?) -> Void)
    func getAlbumPhotos(selectedAlbumId: Int64?, callback: @escaping([PhotoModel]?, Error?) -> Void)
}

class PhotoAlbumDataManager: DataManager {
    func getAlbumDetails(callback: @escaping([PhotoAlbumModel]?, Error?) -> Void) {
        //Handling Albums API call
        let urlString: String = "https://jsonplaceholder.typicode.com/albums"
        if let url = URL(string: urlString) {
            let sessionTask = URLSession.shared.dataTask(with: url) { (jsonData, response, error) in
                guard let data = jsonData else { return }
                let decoder = JSONDecoder()
                let albums = try? decoder.decode([PhotoAlbumModel].self, from: data)
                callback(albums, error)
            }
            sessionTask.resume()
        }
    }

    func getAlbumPhotos(selectedAlbumId: Int64? = -1, callback: @escaping([PhotoModel]?, Error?) -> Void) {
        //Handle Photos API call
        var urlString: String = "https://jsonplaceholder.typicode.com/photos"
        if let validAlbumId = selectedAlbumId, validAlbumId >= 0 {
            urlString += "?albumId=\(validAlbumId)"
        }

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url, timeoutInterval: TimeInterval(180))
            URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
                guard let data = jsonData else { return }
                let decoder = JSONDecoder()
                let allPhotos = try? decoder.decode([PhotoModel].self, from: data)
                callback(allPhotos, error)
            }.resume()
        }
    }
}
