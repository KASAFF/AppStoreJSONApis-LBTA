//
//  SearchResult.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 14.12.2022.
//

import Foundation

struct SearchResult: Decodable {
    let resultCount: Int
    let results: [Result]
}

struct Result: Decodable {
    let trackId: Int
    let trackName: String
    let primaryGenreName: String
    let averageUserRating: Float?
    let screenshotUrls: [String]
    let artworkUrl100: String // app icon
    var formattedPrice: String?
    let description: String
    var releaseNotes: String?
}
