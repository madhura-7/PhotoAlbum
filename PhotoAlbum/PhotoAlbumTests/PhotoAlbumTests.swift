//
//  PhotoAlbumTests.swift
//  PhotoAlbumTests
//
//  Created by MADHURA BHAT on 02/03/21.
//

import XCTest
@testable import PhotoAlbum

class PhotoAlbumTests: XCTestCase {

    override class func setUp() {
        let viewModel = PhotoAlbumViewModel(withManager: MockDataManager())
        viewModel.getAlbumDetails()
    }

    override class func tearDown() {
        //Do Nothing…
    }

}

class MockDataManager: DataManager {
    func getAlbumDetails() {
        let mockResponse =  """
                [
                  {
                    "userId": 1,
                    "id": 1,
                    "title": "Sample test String 1"
                  },
                  {
                    "userId": 1,
                    "id": 2,
                    "title": "Sample Test String 2"
                  }
                ]
            """
        if let stringData = mockResponse.data(using: .utf8) {
            if let jsonArray = try? JSONSerialization.jsonObject(with: stringData, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                print(jsonArray) // use the json here
            } else {
                print("bad json")
            }
        }
    }
}
