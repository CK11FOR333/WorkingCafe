//
//  DarkTheme.swift
//  0610
//
//  Created by Chris on 2019/7/5.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class DarkTheme: ThemeProtocol {
    var navigationBar: UIColor = UIColor(hexString: "24C4B3")!
    var tabBar: UIColor = UIColor(hexString: "24C4B3")!
    var tabBarUnSelected: UIColor = UIColor(hexString: "828282")!
    var tableViewBackground: UIColor = UIColor.black
    var tableViewCellBackgorund: UIColor = UIColor(hexString: "1B1B1D")!

//    var tableViewCellSelectedBackground: UIColor = UIColor(hexString: "24C4B3")!
    var tableViewCellSelectedBackground: UIColor = UIColor(hexString: "7F6450")!

    var tableViewCellLightText: UIColor = UIColor.white
    var tableViewCellDarkText: UIColor = UIColor.black
    var accent: UIColor = UIColor(hexString: "24C4B3")!
    var tint: UIColor = UIColor.black
    var shadow: UIColor = UIColor.black

    var fullStar: UIColor = UIColor(hexString: "F5D468")!
    var cornerButton: UIColor = UIColor(hexString: "7F6450")!
}
