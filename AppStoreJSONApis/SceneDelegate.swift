//
//  SceneDelegate.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 13.12.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
                
        if #available(iOS 15, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
        }
        
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = BaseTabBarController()
        
        
    }
    
}

