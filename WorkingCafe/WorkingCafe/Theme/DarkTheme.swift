//
//  DarkTheme.swift
//  0610
//
//  Created by Chris on 2019/7/5.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class DarkTheme: ThemeProtocol {
	/// Return an UIColor with hex string: `#24C4B3`
    var navigationBar: UIColor = #colorLiteral(red: 0.1411764706, green: 0.768627451, blue: 0.7019607843, alpha: 1)
	/// Return an UIColor with hex string: `#24C4B3`
    var tabBar: UIColor = #colorLiteral(red: 0.1411764706, green: 0.768627451, blue: 0.7019607843, alpha: 1)
	/// Return an UIColor with hex string: `#828282`
    var tabBarUnSelected: UIColor = #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5098039216, alpha: 1)
	/// Return an UIColor with hex string: UIColor.black
    var tableViewBackground: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	/// Return an UIColor with hex string: `#1B1B1D`
    var tableViewCellBackgorund: UIColor = #colorLiteral(red: 0.1058823529, green: 0.1058823529, blue: 0.1137254902, alpha: 1)
	/// Return an UIColor with hex string: `#7F6450`
    var tableViewCellSelectedBackground: UIColor = #colorLiteral(red: 0.4980392157, green: 0.3921568627, blue: 0.3137254902, alpha: 1)
	/// Return an UIColor with hex string: UIColor.white
    var tableViewCellLightText: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
	/// Return an UIColor with hex string: UIColor.black
    var tableViewCellDarkText: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	/// Return an UIColor with hex string: `#24C4B3`
    var accent: UIColor = #colorLiteral(red: 0.1411764706, green: 0.768627451, blue: 0.7019607843, alpha: 1)
	/// Return an UIColor with hex string: UIColor.black
    var tint: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	/// Return an UIColor with hex string: UIColor.black
    var shadow: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	/// Return an UIColor with hex string: `#F5D468`
    var fullStar: UIColor = #colorLiteral(red: 0.9607843137, green: 0.831372549, blue: 0.4078431373, alpha: 1)
	/// Return an UIColor with hex string: `#7F6450`
    var cornerButton: UIColor = #colorLiteral(red: 0.4980392157, green: 0.3921568627, blue: 0.3137254902, alpha: 1)
}
