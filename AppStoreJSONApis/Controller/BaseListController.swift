//
//  BaseListController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 14.12.2022.
//

import UIKit

class BaseListController: UICollectionViewController {
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
