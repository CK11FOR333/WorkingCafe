//
//  SettingViewController.swift
//  0610
//
//  Created by Chris on 2019/6/11.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MessageUI
import Crashlytics
import SwifterSwift


class SettingsViewController: UIViewController {

    var vcType: MyViewControllerType!

    let selectedBackgroundView = UIView()

    var loginTitle: String = "登入"

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if loginManager.isLogin {
            loginTitle = "登出"
            tableView.reloadData()
        } else {
            loginTitle = "登入"
            tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTheme()
    }

    func setupNavigationBar() {
        navigationItem.title = MyViewControllerType.viewController2.rawValue
        
        navigationController?.navigationBar.barStyle = UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? .default : .black
        
        navigationController?.navigationBar.backgroundColor = Theme.current.navigationBar
        navigationController?.navigationBar.barTintColor = Theme.current.navigationBar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = Theme.current.tint
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.current.tint]
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        selectedBackgroundView.backgroundColor = Theme.current.tableViewCellSelectedBackground
    }

    fileprivate func applyTheme() {
        view.backgroundColor = Theme.current.tableViewBackground
        tableView.backgroundColor = Theme.current.tableViewBackground
        tableView.reloadData()

        self.setupNavigationBar()

        self.tabBarController?.tabBar.barTintColor = Theme.current.tabBar
        self.tabBarController?.tabBar.tintColor = Theme.current.tint
        if #available(iOS 10.0, *) {
            self.tabBarController?.tabBar.unselectedItemTintColor = Theme.current.tabBarUnSelected
        } else {
            // Fallback on earlier versions
        }
    }

    func presentContactUsPage() {
        guard MFMailComposeViewController.canSendMail() else { return }

        let mailController = MFMailComposeViewController()

        mailController.navigationBar.tintColor = Theme.current.accent
        mailController.mailComposeDelegate = self

        mailController.setSubject("咖啡田 \(appVersionString)")

        let toRecipients = ["qkaytime@gmail.com"]
        mailController.setToRecipients(toRecipients)

        present(mailController, animated: true, completion: nil)
    }

}

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 5
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "我的收藏"
            cell.textLabel?.textColor = Theme.current.tableViewCellLightText
            cell.detailTextLabel?.text = nil
            cell.backgroundColor = Theme.current.tableViewCellBackgorund
            cell.selectedBackgroundView = selectedBackgroundView

            return cell
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell

                cell.titleLabel.text = "夜間模式"
                cell.delegate = self

                if UserDefaults.standard.bool(forKey: "kIsDarkTheme") {
                    cell.switch.setOn(true, animated: false)
                } else {
                    cell.switch.setOn(false, animated: false)
                }

                cell.backgroundColor = Theme.current.tableViewCellBackgorund
                //            cell.selectedBackgroundView = selectedBackgroundView
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "回報問題"
                cell.textLabel?.textColor = Theme.current.tableViewCellLightText
                cell.detailTextLabel?.text = nil
                cell.backgroundColor = Theme.current.tableViewCellBackgorund
                cell.selectedBackgroundView = selectedBackgroundView
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "隱私權政策"
                cell.textLabel?.textColor = Theme.current.tableViewCellLightText
                cell.detailTextLabel?.text = nil
                cell.backgroundColor = Theme.current.tableViewCellBackgorund
                cell.selectedBackgroundView = selectedBackgroundView
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "資料來源"
                cell.textLabel?.textColor = Theme.current.tableViewCellLightText
                cell.detailTextLabel?.text = "Cafe Nomad 工作咖啡廳"
                cell.detailTextLabel?.textColor = Theme.current.tableViewCellLightText
                cell.backgroundColor = Theme.current.tableViewCellBackgorund
                cell.selectedBackgroundView = selectedBackgroundView
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "關於"
                cell.textLabel?.textColor = Theme.current.tableViewCellLightText
                cell.detailTextLabel?.text = nil
                cell.backgroundColor = Theme.current.tableViewCellBackgorund
                cell.selectedBackgroundView = selectedBackgroundView
                return cell
            default:
                assertionFailure("no match cell with type")
            }

            let cell = UITableViewCell()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = loginTitle
            cell.textLabel?.textColor = Theme.current.tableViewCellLightText
            cell.detailTextLabel?.text = nil
            cell.backgroundColor = Theme.current.tableViewCellBackgorund
            cell.selectedBackgroundView = selectedBackgroundView
            return cell
        }
    }

}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "我的"
        } else if section == 1 {
            return "其他"
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "version \(appVersionString)(\(appBuildString))"
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            if loginManager.isLogin {
                let myCollectedVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "MyCollectedViewController") as! MyCollectedViewController
                navigationController?.pushViewController(myCollectedVC)
            } else {
                appDelegate.presentAlertView("登入以使用收藏功能", message: nil) {
                    let loginVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    self.navigationController?.pushViewController(loginVC)
                }
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                presentContactUsPage()
            case 2:
                if let url = URL(string: "https://ka-pei-tian.flycricket.io/privacy.html") {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            case 3:
                if let url = URL(string: "https://cafenomad.tw") {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            case 4:
                if let url = URL(string: "https://www.facebook.com/%E5%92%96%E5%95%A1%E7%94%B0-CoffeeMap-224168719004516?view_public_for=224168719004516") {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            default:
                break
            }
        } else {
            if loginManager.isLogin {
                loginManager.delegate = self
                loginManager.forceLogout()
            } else {
                let loginVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                navigationController?.pushViewController(loginVC)
            }
        }
    }

}

extension SettingsViewController: SwitchTableViewCellDelegate {

    func switchTheme() {
        applyTheme()
    }

}

// MARK: - MF Mail compose view controller delegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: LoginManagerDelegate {
    func signUpSuccess() {
        //
    }

    func signUpFail(with errorString: String) {
        //
    }

    func loginSuccess() {
        //
    }

    func loginFail(with errorString: String) {
        //
    }

    func loginCancel() {
        //
    }

    func logoutSuccess() {
//        realmManager.removeAllCafes()
        appDelegate.presentAlertView("登出成功", message: nil) {
            self.loginTitle = "登入"
            self.tableView.reloadData()
        }
    }

    func logoutFail(with errorString: String) {
        //
    }

}
