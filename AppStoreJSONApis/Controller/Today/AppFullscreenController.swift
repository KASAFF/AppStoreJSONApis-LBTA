//
//  AppFullscreenController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 16.12.2022.
//

import UIKit

class AppFullScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var todayItem: TodayItem?
    
    var dismissHandler: (() ->())?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
        
        print(scrollView.contentOffset.y)
        let translationY = -90 - UIApplication.shared.statusBarFrame.height
        let transform = scrollView.contentOffset.y > 100 ? CGAffineTransform(translationX: 0, y: translationY) : .identity
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            
            self.floatingContainerView.transform = transform
        })
    }
                       
    let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.dataSource = self
        tableView.delegate = self
        setupCloseButton()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.contentInsetAdjustmentBehavior = .never
        let height = CGFloat(47) //UIApplication.shared.statusBarFrame.height
        tableView.contentInset = .init(top: 0, left: 0, bottom: height, right: 0)
        
        setupFloatingControls()
    }
    
    let floatingContainerView = UIView()
    
    @objc fileprivate func handleTap() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut) {
            self.floatingContainerView.transform = .init(translationX: 0, y: -90)
        }
    }
    
    fileprivate func setupFloatingControls() {
       
        floatingContainerView.clipsToBounds = true
        floatingContainerView.layer.cornerRadius = 16
        view.addSubview(floatingContainerView)
        floatingContainerView.anchor(top: nil, leading: view.leadingAnchor,
                              bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                              padding: .init(top: 0, left: 16, bottom: -90, right: 16),
                              size: .init(width: 0, height: 90))
        let blurVisiualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        floatingContainerView.addSubview(blurVisiualEffectView)
        blurVisiualEffectView.fillSuperview()
        
       // view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        //add our subviews
        let imageView = UIImageView(cornerRadius: 16)
        imageView.image = todayItem?.image
        imageView.constrainHeight(constant: 68)
        imageView.constrainWidth(constant: 68)
        
        let getButton = UIButton(title: "GET")
        getButton.setTitleColor(.white, for: .normal)
        getButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        getButton.backgroundColor = .darkGray
        getButton.layer.cornerRadius = 16
        getButton.constrainWidth(constant: 80)
        getButton.constrainHeight(constant: 32)
        
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            VerticalStackView(arrangedSubviews: [
                UILabel(text: "Life Hack", font: .boldSystemFont(ofSize: 18)),
                UILabel(text: "Utilizing your Time", font: .systemFont(ofSize: 16))
            ], spacing: 4)
           ,
            getButton
        ], customSpacing: 16)
        
        floatingContainerView.addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        stackView.alignment = .center
    }
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "close_button") , for: .normal)
        return button
    }()
    
    fileprivate func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 0), size: .init(width: 80, height: 40))
        closeButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.item == 0 {
            let headerCell = AppFullscreenHeaderCell()
            
            headerCell.todayCell.todayItem = todayItem
            headerCell.todayCell.layer.cornerRadius = 0
            headerCell.clipsToBounds = true
            headerCell.todayCell.backgroundView = nil
            return headerCell
    }
        
        let cell = AppFullscreenDescriptionCell()
        return cell
    }
    
    @objc fileprivate func handleDismiss(button: UIButton) {
        print("Button pressed")
        button.isHidden = true
        dismissHandler?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return TodayController.cellSize
        }
        return UITableView.automaticDimension
    }
    

    
}
