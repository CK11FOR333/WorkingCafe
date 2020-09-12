//
//  ThemeProtocol.swift
//  0610
//
//  Created by Chris on 2019/7/5.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

protocol ThemeProtocol {
    var navigationBar: UIColor { get }
    var tabBar: UIColor { get }
    var tabBarUnSelected: UIColor { get }
    var tableViewBackground: UIColor { get }
    var tableViewCellBackgorund: UIColor { get }
    var tableViewCellSelectedBackground: UIColor { get }
    var tableViewCellLightText: UIColor { get }
    var tableViewCellDarkText: UIColor { get }
    var accent: UIColor { get }
    var tint: UIColor { get }
    var shadow: UIColor { get }

    var fullStar: UIColor { get }
    var cornerButton: UIColor { get }
}
