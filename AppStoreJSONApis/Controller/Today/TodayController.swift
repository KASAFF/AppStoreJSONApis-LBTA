//
//  TodayController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 16.12.2022.
//

import UIKit

class TodayController: BaseListController, UICollectionViewDelegateFlowLayout {
    
//    fileprivate let cellId = "cellId"
//    fileprivate let multipleAppCellId = "multipleAppCellId"
    
    let items = [
        
        TodayItem(category: "LIFE HACK", title: "Utilizing your time",
                  image: UIImage(named: "garden") ?? UIImage(),
                  description: "All the tools and apps you need to intelligently organize your life the right way.",
                  backgroundColor: .white, cellType: .single),
        TodayItem(category: "HOLIDAYS", title: "Travel on a Budget",
                  image: UIImage(named: "holiday") ?? UIImage(),
                  description: "Find out all you need to know on how to travel without packing everything!",
                  backgroundColor: #colorLiteral(red: 0.9774857163, green: 0.9597125649, blue: 0.7252056003, alpha: 1), cellType: .single),
        TodayItem(category: "THE DAILY LIST", title: "Test-Drive These CarPlay Apps",
                  image: UIImage(named: "garden") ?? UIImage(),
                  description: "All the tools and apps you need to intelligently organize your life the right way.",
                  backgroundColor: .white, cellType: .multiple)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9490136504, green: 0.949013412, blue: 0.9490136504, alpha: 1)
      //collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TodayCell.self, forCellWithReuseIdentifier: TodayItem.CellType.single.rawValue)
        collectionView.register(TodayMultipleAppCell.self, forCellWithReuseIdentifier: TodayItem.CellType.multiple.rawValue)
    }
    
    var appFullScreenController: AppFullScreenController!
    
    var topConstraint: NSLayoutConstraint?
    var leadingConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let appFullScreenController = AppFullScreenController()
        appFullScreenController.todayItem = items[indexPath.item]
        appFullScreenController.dismissHandler = {
            self.handleRemoveRedView()
        }
        
        let fullscreenView = appFullScreenController.view!
        
        fullscreenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRemoveRedView)))
        view.addSubview(fullscreenView)
        
        addChild(appFullScreenController)
        
        self.appFullScreenController = appFullScreenController
        
        self.collectionView.isUserInteractionEnabled = false
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { fatalError() }
        
        guard let startingFrame = cell.superview?.convert(cell.frame, to: nil) else { fatalError()  }
        
        self.startingFrame = startingFrame
        //autolayout constrint animations
        //4 anchors
        fullscreenView.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = fullscreenView.topAnchor.constraint(equalTo: view.topAnchor, constant: startingFrame.origin.y)
        leadingConstraint = fullscreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: startingFrame.origin.x)
        widthConstraint = fullscreenView.widthAnchor.constraint(equalToConstant: startingFrame.width)
        heightConstraint = fullscreenView.heightAnchor.constraint(equalToConstant: startingFrame.height)
        
        [topConstraint, leadingConstraint, widthConstraint, heightConstraint].forEach({$0?.isActive = true})
        self.view.layoutIfNeeded()
        fullscreenView.layer.cornerRadius = 16
        
        
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            self.topConstraint?.constant = 0
            self.leadingConstraint?.constant = 0
            self.widthConstraint?.constant = self.view.frame.width
            self.heightConstraint?.constant = self.view.frame.height
            self.view.layoutIfNeeded() // startAnimation
            
            self.tabBarController?.tabBar.frame.origin.y += 100
            
            guard let cell = appFullScreenController.tableView.cellForRow(at: [0,0]) as? AppFullscreenHeaderCell else { return }
            cell.todayCell.topConstrint.constant = 48
            cell.layoutIfNeeded()
        }
    }
    
    var startingFrame: CGRect?
    
    @objc func handleRemoveRedView() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
           
            self.appFullScreenController.tableView.contentOffset = .init(x: 0, y: -32)
            guard let startingFrame = self.startingFrame else { return }
            
            self.topConstraint?.constant = startingFrame.origin.y
            self.leadingConstraint?.constant = startingFrame.origin.x
            self.widthConstraint?.constant = startingFrame.width
            self.heightConstraint?.constant = startingFrame.height
            self.view.layoutIfNeeded() // startAnimation
            
            
            self.tabBarController?.tabBar.frame.origin.y -= 100
            
            guard let cell = self.appFullScreenController.tableView.cellForRow(at: [0,0]) as? AppFullscreenHeaderCell else { return }
            cell.todayCell.topConstrint.constant = 24
            cell.layoutIfNeeded()
            
        }, completion: {_ in
            self.appFullScreenController.view?.removeFromSuperview()
            self.appFullScreenController.removeFromParent()
            self.collectionView.isUserInteractionEnabled = true
            
        })
        //access starting Frame
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellId = items[indexPath.item].cellType.rawValue
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BaseTodayCell
        cell.todayItem = items[indexPath.item]
        return cell
  
    }
    
    static let cellSize: CGFloat = 500
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 64, height: TodayController.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 32, left: 0, bottom: 32, right: 0)
    }
}
