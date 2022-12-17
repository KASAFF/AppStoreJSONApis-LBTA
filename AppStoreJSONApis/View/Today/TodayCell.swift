//
//  TodayCell.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 16.12.2022.
//

import UIKit

class TodayCell: BaseTodayCell {
    
    override var todayItem: TodayItem! {
        didSet {
            categoryLabel.text = todayItem.category
            titleLabel.text = todayItem.title
            imageView.image = todayItem.image
            descriptionLabel.text = todayItem.description
            
            backgroundColor = todayItem.backgroundColor
            backgroundView?.backgroundColor = todayItem.backgroundColor
        }
    }
    
    let categoryLabel = UILabel(text: "LIFE HACK", font: .boldSystemFont(ofSize: 20))
    let titleLabel = UILabel(text: "Utilizing your Time", font: .boldSystemFont(ofSize: 28))
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "garden"))
    
    let descriptionLabel = UILabel(text: "All the tools and apps you need to intelligently organize your life the right way.", font: .systemFont(ofSize: 16), numberOfLines: 3)
    
    var topConstrint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 16
        //clipsToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        let imageContrainerView = UIView()
        imageContrainerView.addSubview(imageView)
        imageView.centerInSuperview(size: .init(width: 240, height: 240))
        let stackView = VerticalStackView(arrangedSubviews: [
            categoryLabel, titleLabel, imageContrainerView, descriptionLabel
        ], spacing: 8)
        addSubview(stackView)
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 24, bottom: 24, right: 24))
//        stackView.fillSuperview(padding: .init(top: 24, left: 24, bottom: 24, right: 24))
        self.topConstrint = stackView.topAnchor.constraint(equalTo: topAnchor, constant: 24)
        self.topConstrint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
