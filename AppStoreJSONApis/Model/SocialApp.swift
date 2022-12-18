//
//  SocialApp.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 15.12.2022.
//

import Foundation

struct SocialApp: Decodable, Hashable {
    let id, name, imageUrl, tagline: String
}
