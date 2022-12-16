//
//  PreviewCell.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 15.12.2022.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    
    let previewLabel = UILabel(text: "Preview", font: .boldSystemFont(ofSize: 24))
    let horizontalController = PreviewScreenshotsController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(previewLabel)
        addSubview(horizontalController.view)
        previewLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        
        horizontalController.view.anchor(top: previewLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
