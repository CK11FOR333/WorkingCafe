//
//  UIWindow+Extension.swift
//  0610
//
//  Created by Chris on 2019/7/12.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

extension UIWindow {

    var visibleViewController: UIViewController? {
        guard let rootViewController: UIViewController = self.rootViewController  else { return nil }
        return UIWindow.getVisibleViewController(from: rootViewController)
    }

    class func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        switch vc {
        case is UINavigationController:
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewController(from: navigationController.visibleViewController!)
        case is UITabBarController:
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewController(from: tabBarController.selectedViewController!)
        default:
            guard let presentedViewController = vc.presentedViewController else { return vc }
            return UIWindow.getVisibleViewController(from: presentedViewController)
        }
    }

}
