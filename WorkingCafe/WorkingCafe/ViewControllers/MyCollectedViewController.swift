//
//  MyCollectedViewController.swift
//  0610
//
//  Created by Chris on 2019/7/3.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class MyCollectedViewController: UIViewController {

    let theme = Theme.current

    var cafes: [Cafe] = []
    var searchResult: [Cafe] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        getJSON()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    func setupNavigationBar() {
        // NavigationBar
        self.title = "我的收藏"

        navigationController?.navigationBar.barStyle = UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? .default : .black

        navigationController?.navigationBar.backgroundColor = theme.navigationBar
        navigationController?.navigationBar.barTintColor = theme.navigationBar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = theme.tint
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.current.tint]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.current.tint]
        } else {
            // Fallback on earlier versions
        }
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        tableView.register(nibWithCellClass: CafeTableViewCell.self)
    }

    @objc func getJSON() {
//        cafes = realmManager.getCafes()
        favoriteManager.getCafes({ [weak self] (cafes) in
            self?.cafes = cafes
            self?.tableView.reloadData()
        })
    }

    fileprivate func applyTheme() {
        view.backgroundColor = Theme.current.tableViewBackground
        tableView.backgroundColor = Theme.current.tableViewBackground
        tableView.reloadData()

        setupNavigationBar()
    }

}

extension MyCollectedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeTableViewCell", for: indexPath) as! CafeTableViewCell
        cell.selectionStyle = .none

        cell.delegate = self

        cell.indexPath = indexPath

        let cafe = cafes[indexPath.row]
        cell.cafe = cafe

        cell.applyTheme()

        return cell
    }

}

extension MyCollectedViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cafe = cafes[indexPath.row]
        if let url = URL(string: cafe.url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }

}

extension MyCollectedViewController: CafeTableViewCellDelegate {

    func didClickCollectButton(_ sender: UIButton, at indexPath: IndexPath) {
        var cafe: Cafe

        cafe = cafes[indexPath.row]

        if loginManager.isLogin {

            var isCollected = false
            favoriteManager.isCafeCollected(cafe) { (collected) in
                isCollected = collected
                if isCollected {
                    favoriteManager.removeFavoriteCafe(cafe)
                } else {
                    favoriteManager.addFavoriteCafe(cafe)
                }

                isCollected = !isCollected

                sender.isSelected = isCollected
                if isCollected {
                    sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: .allowUserInteraction, animations: {
                        sender.transform = .identity
                    }, completion: nil)
                }
            }

//            var isCollected = realmManager.isCafeCollected(cafe)

//            if isCollected {
//                realmManager.removeFavoriteCafe(cafe)
//            } else {
//                realmManager.addFavoriteCafe(cafe)
//            }


        } else {
            appDelegate.presentAlertView("登入以使用收藏功能", message: nil) {
                let loginVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(loginVC)
            }
        }
    }

}
