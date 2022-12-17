//
//  TodayController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 16.12.2022.
//

import UIKit

class TodayController: BaseListController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    
    var items = [TodayItem]()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.color = .darkGray
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.superview?.setNeedsLayout()
    }
    
    let blurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurVisualEffectView)
        blurVisualEffectView.fillSuperview()
        blurVisualEffectView.alpha = 0
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerInSuperview()
        
        fetchData()
        
        navigationController?.isNavigationBarHidden = true
        
        collectionView.backgroundColor = #colorLiteral(red: 0.9490136504, green: 0.949013412, blue: 0.9490136504, alpha: 1)
      //collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TodayCell.self, forCellWithReuseIdentifier: TodayItem.CellType.single.rawValue)
        collectionView.register(TodayMultipleAppCell.self, forCellWithReuseIdentifier: TodayItem.CellType.multiple.rawValue)
    }
    
    fileprivate func fetchData() {
        // dispatchGroup
        let dispatchGroup = DispatchGroup()
        
        var topPaidGroup: AppGroup?
        var topFreeGroup: AppGroup?
        
        dispatchGroup.enter()
        Service.shared.fetchTopPaid { appGroup, err in
            if let err = err {
                print(err, "dd")
                dispatchGroup.leave()
            }
            topPaidGroup = appGroup
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        Service.shared.fetchTopFree { appGroup, err in
            if let err = err {
                print(err, "dd")
                dispatchGroup.leave()
            }
            topFreeGroup = appGroup
            dispatchGroup.leave()
            
        }
        
        dispatchGroup.notify(queue: .main) {
            //i ll have access to top grossing and games somehow
            print("Finished Fetching")
            self.activityIndicatorView.stopAnimating()
                        
            self.items = [
                TodayItem(category: "LIFE HACK", title: "Utilizing your time",
                          image: UIImage(named: "garden") ?? UIImage(),
                          description: "All the tools and apps you need to intelligently organize your life the right way.",
                          backgroundColor: .white, cellType: .single, apps: []),
                TodayItem(category: "Daily List", title: topPaidGroup?.feed.title ?? "",
                          image: UIImage(named: "garden") ?? UIImage(),
                          description: "All the tools and apps you need to intelligently organize your life the right way.",
                          backgroundColor: .white, cellType: .multiple, apps: topPaidGroup?.feed.results ?? []),
                TodayItem(category: "Daily List", title: topFreeGroup?.feed.title ?? "",
                          image: UIImage(named: "garden") ?? UIImage(),
                          description: "All the tools and apps you need to intelligently organize your life the right way.",
                          backgroundColor: .white, cellType: .multiple, apps: topFreeGroup?.feed.results ?? []),
               TodayItem(category: "HOLIDAYS", title: "Travel on a Budget",
                          image: UIImage(named: "holiday") ?? UIImage(),
                          description: "Find out all you need to know on how to travel without packing everything!",
                          backgroundColor: #colorLiteral(red: 0.9853077531, green: 0.9594048858, blue: 0.7252270579, alpha: 1), cellType: .single, apps: [])
            ]
            
            
            self.collectionView.reloadData()
        }
    }
    
    
    var appFullScreenController: AppFullScreenController!
    
    var topConstraint: NSLayoutConstraint?
    var leadingConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    
    fileprivate func showDailyListFullScreen(_ indexPath: IndexPath) {
        let fullController = TodayMultipleAppsController(mode: .fullscreen)
        fullController.apps = self.items[indexPath.item].apps
        present(BackEnabledNavigationController(rootViewController: fullController), animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch items[indexPath.item].cellType {
        case .multiple:
            showDailyListFullScreen(indexPath)
        default:
            showSingleAppFullscreen(indexPath: indexPath)
        }
    }
    
    fileprivate func setupSingleAppFullscreenController(_ indexPath: IndexPath) {
        let appFullScreenController = AppFullScreenController()
        appFullScreenController.todayItem = items[indexPath.item]
        appFullScreenController.dismissHandler = {
            self.handleAppFullscreenDismissal()
        }
        appFullScreenController.view.layer.cornerRadius = 16
        self.appFullScreenController = appFullScreenController
        
        //#1 setup our pan gesture
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag))
        gesture.delegate = self
        appFullScreenController.view.addGestureRecognizer(gesture)
        
        //#2 add a blur effect view
        //#3 not to intefere with our UITableView scrolling
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    var appFullscreenBeginOffset: CGFloat = 0
    
    @objc func handleDrag(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .began {
            appFullscreenBeginOffset = appFullScreenController.tableView.contentOffset.y
           // print(appFullscreenBeginOffset)
        }
        
        let translationY = gesture.translation(in: appFullScreenController.view).y
        
        if appFullScreenController.tableView.contentOffset.y > 0 {
            return
        }
            
        if gesture.state == .changed {
            if translationY > 0 {
                let trueOffset = translationY - appFullscreenBeginOffset
                var scale = 1 - trueOffset / 1000
                print(trueOffset, scale)
                
                scale = min(1, scale)
                scale = max(0.5, scale)
                
                let transform: CGAffineTransform = .init(scaleX: scale, y: scale)
                self.appFullScreenController.view.transform = transform
            }
            
            
        } else if gesture.state == .ended {
            if translationY > 0 {
                handleAppFullscreenDismissal()
            }
            
        }
    }
    
    fileprivate func setupStartingCellFrame(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        guard let startingFrame = cell.superview?.convert(cell.frame, to: nil) else { return  }
        
        self.startingFrame = startingFrame
    }
    
    fileprivate func setupAppFullscreenStartingPosition(_ indexPath: IndexPath) {
        let fullscreenView = appFullScreenController.view!
        
//        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(handleAppFullscreenDismissal))
//        gesture1.numberOfTapsRequired = 5
//        gesture1
        
      //fullscreenView.addGestureRecognizer(gesture1)
        view.addSubview(fullscreenView)
        
        addChild(appFullScreenController)
        
        
        self.collectionView.isUserInteractionEnabled = false
        setupStartingCellFrame(indexPath)
        
        guard let startingFrame = self.startingFrame else { return }
        
        //autolayout constrint animations
        //4 anchors
        fullscreenView.translatesAutoresizingMaskIntoConstraints = false
        
        self.anchoredConstraints =
        fullscreenView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil,
        padding: .init(top: startingFrame.origin.y, left: startingFrame.origin.x, bottom: 0, right: 0),
        size: .init(width: startingFrame.width, height: startingFrame.height))
        
        
        
        self.view.layoutIfNeeded()
    }
    
    var anchoredConstraints: AnchoredConstraints?
    
    fileprivate func beginAnimationAppFullscreen() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            self.blurVisualEffectView.alpha = 1

            self.anchoredConstraints?.top?.constant = 0
            self.anchoredConstraints?.leading?.constant = 0
            self.anchoredConstraints?.width?.constant = self.view.frame.width
            self.anchoredConstraints?.height?.constant = self.view.frame.height
            
            self.view.layoutIfNeeded() // startAnimation
            
            self.tabBarController?.tabBar.frame.origin.y += 100
            
            guard let cell = self.appFullScreenController.tableView.cellForRow(at: [0,0]) as? AppFullscreenHeaderCell else { return }
            
            cell.todayCell.topConstrint.constant = 48
            cell.layoutIfNeeded()
        }
    }
    
    
    fileprivate func showSingleAppFullscreen(indexPath: IndexPath) {
        // #1
        setupSingleAppFullscreenController(indexPath)
        
        // #2 setup fullscreen in its starting position
        setupAppFullscreenStartingPosition(indexPath)
        
        // #3 begin the fullscreen animation
        beginAnimationAppFullscreen()
    }
    
    var startingFrame: CGRect?
    
    @objc func handleAppFullscreenDismissal() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
           
            self.blurVisualEffectView.alpha = 0
            self.appFullScreenController.view.transform = .identity
            self.appFullScreenController.tableView.contentOffset = .init(x: 0, y: -32)
            guard let startingFrame = self.startingFrame else { return }
            
            self.anchoredConstraints?.top?.constant = startingFrame.origin.y
            self.anchoredConstraints?.leading?.constant = startingFrame.origin.x
            self.anchoredConstraints?.width?.constant = startingFrame.width
            self.anchoredConstraints?.height?.constant = startingFrame.height
            self.view.layoutIfNeeded() // startAnimation
            
            
            self.tabBarController?.tabBar.frame.origin.y -= 100
            
            guard let cell = self.appFullScreenController.tableView.cellForRow(at: [0,0]) as? AppFullscreenHeaderCell else { return }
            //cell.closeButton.alpha = 0
            self.appFullScreenController.closeButton.alpha = 0
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
        
        (cell as? TodayMultipleAppCell)?.multipleAppsController.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMultiAppsTap)))
        return cell
  
    }
    
    @objc fileprivate func handleMultiAppsTap(gesture: UIGestureRecognizer) {
        let collectionView = gesture.view
        // figure out which cell wew clicking into
        
        var superview = collectionView?.superview
        while superview != nil {
            if let cell = superview as? TodayMultipleAppCell {
                guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
                let apps = self.items[indexPath.item].apps
                
                let fullController = TodayMultipleAppsController(mode: .fullscreen)
                fullController.modalPresentationStyle = .fullScreen
                fullController.apps = apps
                present(BackEnabledNavigationController(rootViewController: fullController), animated: true)
                return
            }
            
            superview = superview?.superview
        }
        
        //
       
         
    }
    
    static let cellSize: CGFloat = 450
    
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
