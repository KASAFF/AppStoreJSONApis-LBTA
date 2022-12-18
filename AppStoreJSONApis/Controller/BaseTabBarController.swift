//
//  BaseTabBarController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 13.12.2022.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    //3- maybe introduce our appSearchController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            createNavController(viewController: TodayController(),
                                title: "Today", imageName: "today_icon"),
            createNavController(viewController: AppsPageController(),
                                title: "Apps", imageName: "apps"),
            createNavController(viewController: AppSearchController(),
                                title: "Search", imageName: "search"),
            createNavController(viewController: MusicController(),
                                title: "Music", imageName: "music")
        ]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fixTabNavBar()
    }
    
    private func fixTabNavBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        // correct the transparency bug for Navigation bars
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    fileprivate func createNavController(viewController: UIViewController, title: String, imageName: String) -> UIViewController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.title = title
        viewController.view.backgroundColor = .white
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
