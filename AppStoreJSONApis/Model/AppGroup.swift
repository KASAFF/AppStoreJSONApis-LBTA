//
//  AppGroup.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 15.12.2022.
//

import Foundation

struct AppGroup: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let title: String
    let results: [FeedResult]
}

struct FeedResult: Decodable {
    let id, name, artistName, artworkUrl100: String
}

