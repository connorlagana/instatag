//
//  MainTabBarController.swift
//  instatag
//
//  Created by Connor Lagana on 7/9/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        
        setupNav()
        
        
    }
    
    func setupNav() {
        let homeNavController = templateNavController(image: #imageLiteral(resourceName: "home"), rootViewController: HomeFeedController(collectionViewLayout: UICollectionViewFlowLayout()))
    
        let searchNavController = templateNavController(image: #imageLiteral(resourceName: "search"), rootViewController: SearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let layout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: layout)
        profileController.tabBarItem.image = #imageLiteral(resourceName: "profile")
        
        let profileNavController = UINavigationController(rootViewController: profileController)
        
        viewControllers = [
            homeNavController,
            searchNavController,
            profileNavController
        ]
        
        tabBar.tintColor = .black
    }
    
    fileprivate func templateNavController(image: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = image
        return navController
    }
}
