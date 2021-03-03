//
//  ImageDownloadHelper.swift
//  PhotoAlbum
//
//  Created by MADHURA BHAT on 03/03/21.
//

import Foundation
import UIKit

class ImageDownLoadHelper {
    lazy var imagesInProgress: [IndexPath: Operation] = [:]
    lazy var imageQueues: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: Operation {
    var imageLoaderModel: ImageLoaderModel
    init(_ model: ImageLoaderModel) {
        self.imageLoaderModel = model
    }
    override func main() {
        if isCancelled {
            return
        }

        guard let url = URL(string: imageLoaderModel.photoModel?.thumbnailUrl ?? ""), let imageData = try? Data(contentsOf: url) else { return }
        if isCancelled {
            return
        }
        if !imageData.isEmpty {
            imageLoaderModel.thumbnailImage = UIImage(data:imageData)
            imageLoaderModel.downloadState = .downloaded
        } else {
            imageLoaderModel.downloadState = .failed
            imageLoaderModel.thumbnailImage = nil
        }
    }
}
