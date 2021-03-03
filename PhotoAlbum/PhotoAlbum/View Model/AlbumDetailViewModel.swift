//
//  AlbumDetailViewModel.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 03/03/21.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case new, downloaded, failed
}

struct ImageLoaderModel {
    var photoModel: PhotoModel?
    var thumbnailImage: UIImage?
    var urlImage: UIImage?
    var downloadState: PhotoRecordState
}

class AlbumDetailViewModel {
    var updateUI: ((_ indexPath: IndexPath) -> Void)?
    var hasStoppedScrolling: Bool
    private let dataManager: DataManager?
    private let failedImageName = "FailedImage"
    private let selectedAlbum: PhotoAlbumModel?
    fileprivate var currentIndex: IndexPath?
    fileprivate var currentAlbumDetails: [PhotoModel]? {
        didSet {
            for eachPhoto in currentAlbumDetails ?? [] {
                let imageLoader = ImageLoaderModel(photoModel: eachPhoto, thumbnailImage: nil, urlImage: nil, downloadState: .new)
                allLoaders.append(imageLoader)
            }
        }
    }
    fileprivate var allLoaders: [ImageLoaderModel] = []
    fileprivate let downloadOperations = ImageDownLoadHelper()

    var numberOfPhotos: Int {
        return currentAlbumDetails?.count ?? 0
    }
    var screenTitle: String {
        return self.selectedAlbum?.title ?? ""
    }

    required init(_ album: PhotoAlbumModel?, withManager: DataManager = PhotoAlbumDataManager()) {
        dataManager = withManager
        selectedAlbum = album
        hasStoppedScrolling = false
    }

    func getAlbumPhotos(callback: @escaping(Error?)-> Void) {
        dataManager?.getAlbumPhotos(selectedAlbumId: selectedAlbum?.id) { (allPhotos, error) in
            self.currentAlbumDetails = allPhotos
            callback(error)
        }
    }
}

//MARK: View Controller communications
extension AlbumDetailViewModel {
    func setDataSourceIndex(_ indexPath: IndexPath?) {
        currentIndex = indexPath
    }

    func suspendAll() {
        downloadOperations.imageQueues.isSuspended = true
    }

    func resumeAll() {
        downloadOperations.imageQueues.isSuspended = false
    }

    func loadImagesForOnscreenCells(_ visibleRows: [IndexPath]?) {
        if let pathsArray = visibleRows {
            let allPendingOperations = Set(downloadOperations.imagesInProgress.keys)
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            //Handling Cancel
            for indexPath in toBeCancelled {
                if let pendingDownload = downloadOperations.imagesInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                downloadOperations.imagesInProgress.removeValue(forKey: indexPath)
            }
            //Handling start
            for indexPath in toBeStarted {
                let recordToProcess = allLoaders[indexPath.row]
                startOperations(for: recordToProcess, at: indexPath)
            }
        }
    }

}

//MARK: Cell Data Source
extension AlbumDetailViewModel: PhotoCellDataSource {
    var photoImageTitle: String? {
        return currentAlbumDetails?[currentIndex?.row ?? 0].title
    }

    var photoImage: UIImage? {
        let currentImageLoader = allLoaders[currentIndex?.row ?? 0]
        switch (currentImageLoader.downloadState) {
            case .failed:
                return UIImage(named: failedImageName)
            case .new:
                if hasStoppedScrolling {
                    startOperations(for: currentImageLoader, at: currentIndex)
                }
            case .downloaded:
                return currentImageLoader.thumbnailImage
            default: break
        }

        return currentImageLoader.thumbnailImage
    }

    var isLoading: Bool? {
        let currentImageLoader = allLoaders[currentIndex?.row ?? 0]
        return (currentImageLoader.downloadState != .downloaded)
    }

    private func startOperations(for photoLoader: ImageLoaderModel?, at indexPath: IndexPath?) {
        guard let validLoader = photoLoader else { return }
        switch (validLoader.downloadState) {
            case .new:
                startDownload(for: validLoader, at: indexPath)
            default:
                NSLog("do nothing")
        }
    }

    private func startDownload(for photoLoader: ImageLoaderModel?, at indexPath: IndexPath?) {
        guard let validLoader = photoLoader, let validIndexPath = indexPath,
              downloadOperations.imagesInProgress[validIndexPath] == nil else { return }

        let downloader = ImageDownloader(validLoader)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            //Handle UI update
            DispatchQueue.main.async {
                self.allLoaders[validIndexPath.row] = downloader.imageLoaderModel
                self.updateUI?(validIndexPath)
                self.downloadOperations.imagesInProgress.removeValue(forKey: validIndexPath)
            }
        }
        downloadOperations.imagesInProgress[validIndexPath] = downloader
        downloadOperations.imageQueues.addOperation(downloader)
    }

}
