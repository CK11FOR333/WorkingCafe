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
	
	private let collectionView: UICollectionView = {
		let viewLayout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
		collectionView.backgroundColor = .white
		return collectionView
	}()

	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(getCafes), for: .valueChanged)
		return refreshControl
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupCollectionView()
        setupNavigationBar()
		getCafes()
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
	
	func setupCollectionView() {
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
		])
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(cellWithClass: CafeCollectionViewCell.self)
		
		
		collectionView.refreshControl = refreshControl
	}

	@objc func getCafes() {
        favoriteManager.getCafes({ [weak self] (cafes) in
			guard let strongSelf = self else { return }
			strongSelf.cafes = cafes
			if #available(iOS 10.0, *) {
				strongSelf.collectionView.refreshControl?.endRefreshing()
			} else {
				// Fallback on earlier versions
				strongSelf.refreshControl.endRefreshing()
			}
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
				strongSelf.collectionView.reloadData()
				strongSelf.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
				self?.applyTheme()
			})
        })
    }

    fileprivate func applyTheme() {
        view.backgroundColor = Theme.current.tableViewBackground
		
		refreshControl.tintColor = Theme.current.accent
		refreshControl.backgroundColor = Theme.current.tableViewBackground
		
		collectionView.backgroundColor = Theme.current.tableViewBackground
		collectionView.reloadData()
		
        setupNavigationBar()
    }
}

// MARK: - UICollectionViewDataSource

extension MyCollectedViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cafes.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cafe = cafes[indexPath.row]
		
		let cell = collectionView.dequeueReusableCell(withClass: CafeCollectionViewCell.self, for: indexPath)
		cell.delegate = self
		cell.indexPath = indexPath
		cell.cafe = cafe
		cell.applyTheme()
		
		return cell
	}
}

// MARK: - UICollectionViewDelegate

extension MyCollectedViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cafe = cafes[indexPath.row]
		
		let cafeDetailVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "CafeDetailViewController") as! CafeDetailViewController
		cafeDetailVC.cafe = cafe
		cafeDetailVC.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(cafeDetailVC)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MyCollectedViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if UIDevice.current.userInterfaceIdiom == .pad {
			let width = (collectionView.frame.size.width - 20 - 10) / 2
			return CGSize(width: width, height: 120)
			
		} else {
			let width = (collectionView.frame.size.width - 20)
			return CGSize(width: width, height: 120)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
}

// MARK: - CafeCollectionViewCellDelegate

extension MyCollectedViewController: CafeCollectionViewCellDelegate {
	func didClickCollectButton(_ sender: UIButton, at indexPath: IndexPath) {
		var cafe: Cafe
		cafe = cafes[indexPath.row]
		
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
	}
}
