//
//  TodayItem.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 16.12.2022.
//

import UIKit

struct TodayItem {
    
    let category: String
    let title: String
    let image: UIImage
    let description: String
    let backgroundColor: UIColor
    
    //Enum
    let cellType: CellType
    
    var apps: [FeedResult]
    
    enum CellType: String {
        case single, multiple
    }
    
}
