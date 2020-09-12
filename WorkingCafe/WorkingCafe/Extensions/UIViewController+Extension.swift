//
//  UIViewController+Extension.swift
//  0610
//
//  Created by Chris on 2019/7/12.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentAlertView(_ title: String?, message: String?, completion: (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確定", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
            completion?()
        }
        alertViewController.addAction(confirmAction)

        present(alertViewController, animated: true, completion: nil)
    }

}
