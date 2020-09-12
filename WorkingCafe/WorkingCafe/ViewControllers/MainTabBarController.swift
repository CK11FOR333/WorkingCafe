//
//  MainTabBarController.swift
//  0610
//
//  Created by Chris on 2019/6/10.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SwiftyJSON


class MainTabBarController: UITabBarController {    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
}

extension MainTabBarController {
    
    func setupTabBar() {
        var vcs = [UIViewController]()
        
        /////////////////////////////////////////////////////////////////////////////////
        
        let homeVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

        let homeNav = UINavigationController.init(rootViewController: homeVC)
        //        homeNav.navigationBar.prefersLargeTitles = true
        homeNav.tabBarItem.image = UIImage(named: "tabbar_icon_shop_default")
        //        homeNav.tabBarItem.title = MyViewControllerType.viewController0.rawValue

        vcs.append(homeNav)
        
        /////////////////////////////////////////////////////////////////////////////////
        
        let collectiveVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let collectiveNav = UINavigationController.init(rootViewController: collectiveVC)
        collectiveNav.tabBarItem.image = UIImage(named: "tabbar_icon_map_default")
//        collectiveNav.tabBarItem.title = MyViewControllerType.viewController1.rawValue

        vcs.append(collectiveNav)
        
        /////////////////////////////////////////////////////////////////////////////////
        
        let settingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as! SettingsViewController
        let settingNav = UINavigationController.init(rootViewController: settingVC)
        settingNav.tabBarItem.image = UIImage(named: "tabbar_icon_mine_default")
//        settingNav.tabBarItem.title = MyViewControllerType.viewController2.rawValue

        vcs.append(settingNav)
        
        /////////////////////////////////////////////////////////////////////////////////
        
        self.setViewControllers(vcs, animated: false)
    }
    
}
