//
//  HorizontalSnappingController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 15.12.2022.
//

import UIKit

class HorizontalSnappingController: UICollectionViewController {
    init() {
       let layout = BetterSnappingLayout()
        layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
    }
                   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//class SnappingLayout: UICollectionViewFlowLayout {
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        
//        guard let collectionView = self.collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)}
//        
//        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
//        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left + 20
//                
//        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
//        
//        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
//        
//        layoutAttributesArray?.forEach({ (layoutAttributes) in
//            let itemOffset = layoutAttributes.frame.origin.x
//            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
//                offsetAdjustment = itemOffset - horizontalOffset
//            }
//        })
//        
//        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
//    }
//}


                   
