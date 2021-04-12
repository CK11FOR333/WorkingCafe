//
//  CafeDetailViewController.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/12/9.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit
import SafariServices

class CafeDetailViewController: UIViewController {
	var cafe: Cafe?
	
	var collectButton: UIButton!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableHeaderView: UIView!
	@IBOutlet weak var tableFooterView: UIView!
	@IBOutlet weak var linkButton: UIButton!
}

extension CafeDetailViewController {
	@IBAction func clickLinkButton(_ sender: UIButton) {
		if let id = cafe?.id, let url = URL(string: "https://cafenomad.tw/shop/\(id)") {
			let safari = SFSafariViewController(url: url)
			safari.delegate = self
			present(safari, animated: true, completion: nil)
		}
	}
}

extension CafeDetailViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		setupTableView()		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		applyTheme()
	}
}

extension CafeDetailViewController {
	func setupNavigationBar() {
//		navigationItem.title = MyViewControllerType.viewController0.rawValue
		
		collectButton = UIButton(type: .custom)
		collectButton.tintColor = Theme.current.tint
		collectButton.setImage(UIImage(named: "navbar_icon_picked_default")?.withRenderingMode(.alwaysTemplate), for: .normal)
		collectButton.setImage(UIImage(named: "navbar_icon_picked_pressed"), for: .selected)
		collectButton.addTarget(self, action: #selector(didClickCollectButton), for: .touchUpInside)
		var isCollected = false
		if let cafe = cafe {
			favoriteManager.isCafeCollected(cafe) { [weak self] (collected) in
				isCollected = collected
				self?.collectButton.isSelected = isCollected ? true : false
				self?.collectButton.tintColor = Theme.current.tint
			}
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: collectButton)
				
		navigationController?.navigationBar.barStyle = UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? .default : .black
		
		navigationController?.navigationBar.backgroundColor = Theme.current.navigationBar
		navigationController?.navigationBar.barTintColor = Theme.current.navigationBar
		navigationController?.navigationBar.tintColor = Theme.current.tint
		navigationController?.navigationBar.isTranslucent = false
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.current.tint]
		navigationController?.navigationBar.shadowImage = UIImage()
	}
	
	fileprivate func setupTableView() {
		tableView.dataSource = self
		tableView.separatorStyle = .none
//		tableView.rowHeight = 590
		tableView.estimatedRowHeight = 670
	}
	
	fileprivate func applyTheme() {
		view.backgroundColor = Theme.current.tableViewCellBackgorund
		setupNavigationBar()
		tableView.backgroundColor = Theme.current.tableViewBackground
		tableView.reloadData()
		tableHeaderView.backgroundColor = Theme.current.tableViewBackground
		tableFooterView.backgroundColor = Theme.current.tableViewBackground
		linkButton.backgroundColor = Theme.current.cornerButton
		linkButton.setTitleColor(Theme.current.tint, for: .normal)
	}
	
	@objc func didClickCollectButton(_ sender: UIButton) {
		var isCollected = false
		if let cafe = cafe {
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
		}
	}
}

extension CafeDetailViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case 0:
				return 1
			case 1:
				return 1
			case 2:
				return 6
			case 3:
				return 6
			default:
				return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailNameTableViewCell", for: indexPath) as! CafeDetailNameTableViewCell
				cell.selectionStyle = .none
				cell.cafe = self.cafe
				cell.applyTheme()
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailAddressTableViewCell", for: indexPath) as! CafeDetailAddressTableViewCell
				cell.selectionStyle = .none
				cell.cafe = self.cafe
				cell.applyTheme()
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailStarTableViewCell", for: indexPath) as! CafeDetailStarTableViewCell
				cell.selectionStyle = .none
				switch indexPath.row {
					case 0:
						cell.valueStarTitle = .wifi
					case 1:
						cell.valueStarTitle = .seat
					case 2:
						cell.valueStarTitle = .quiet
					case 3:
						cell.valueStarTitle = .tasty
					case 4:
						cell.valueStarTitle = .cheap
					case 5:
						cell.valueStarTitle = .music
					default:
						break
				}
				cell.cafe = self.cafe
				cell.applyTheme()
				return cell
			case 3:
				let cell = tableView.dequeueReusableCell(withIdentifier: "CafeDetailContentTableViewCell", for: indexPath) as! CafeDetailContentTableViewCell
				cell.selectionStyle = .none
				switch indexPath.row {
					case 0:
						cell.contentTitle = .limitedTime
					case 1:
						cell.contentTitle = .socket
					case 2:
						cell.contentTitle = .standingDesk
					case 3:
						cell.contentTitle = .openTime
					case 4:
						cell.contentTitle = .mrt
					case 5:
						cell.contentTitle = .url
					default:
						break
				}
				cell.cafe = self.cafe
				cell.applyTheme()
				cell.delegate = self
				return cell
			default:
				return UITableViewCell()
		}
	}
}

extension CafeDetailViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
}

extension CafeDetailViewController: SFSafariViewControllerDelegate {
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		//
	}
}

extension CafeDetailViewController: CafeDetailContentTableViewCellDelegate {
	func didClickLinkButton() {
		if let url = cafe?.url, let link = URL(string: url) {
			let safari = SFSafariViewController(url: link)
			safari.delegate = self
			present(safari, animated: true, completion: nil)
		}
	}
}
