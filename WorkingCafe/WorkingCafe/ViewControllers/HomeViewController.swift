//
//  HomeViewController.swift
//  0610
//
//  Created by Chris on 2019/6/11.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {
    // MARK: - Property
    
    var vcType: MyViewControllerType!
    
    /// 預設台北
    var city = TaiwanCity.taipei
    
    var cafes: [Cafe] = []
    var searchResult: [Cafe] = []
    
    var authHandle: AuthStateDidChangeListenerHandle?
    var isLogin: Bool = false
    
    // 用此變數表示現在是否為搜尋模式
    var isSearching = false
    
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
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortImageView: UIImageView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
}

// MARK: - IBAction

extension HomeViewController {
    @IBAction func clickFilterButton(_ sender: UIButton) {
        showFilterActions()
    }
    
    @IBAction func clickSortButton(_ sender: UIButton) {
        showSortActions()
    }
}

// MARK: - View LifeCycle

extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        setupLayouts()
        setupNavigationBar()
        setupSortButton()
        getCafes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTheme()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
}

// MARK: - Helpers

extension HomeViewController {
    private func setupLayouts() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for `collectionView`
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        view.bringSubviewToFront(sortView)
    }
    
    func setupNavigationBar() {
        navigationItem.title = MyViewControllerType.viewController0.rawValue
        navigationController?.navigationBar.barStyle = UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? .default : .black
        
        navigationController?.navigationBar.backgroundColor = Theme.current.navigationBar
        navigationController?.navigationBar.barTintColor = Theme.current.navigationBar
        navigationController?.navigationBar.tintColor = Theme.current.tint
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.current.tint]
        navigationController?.navigationBar.shadowImage = UIImage()
        
        headerView.backgroundColor = Theme.current.navigationBar
        
        locationLabel.text = city.description
        locationLabel.textColor = Theme.current.tint
        
        filterImageView.image = UIImage(named: "navbar_icon_filter_default")?.withRenderingMode(.alwaysTemplate)
        filterImageView.tintColor = Theme.current.tint
    }
    
    func setupSearchBar() {
        searchBar.placeholder = "搜尋店家名稱、地址"
        searchBar.delegate = self
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellWithClass: CafeCollectionViewCell.self)
        collectionView.refreshControl = refreshControl
    }
    
    func setupSortButton() {
        sortImageView.image = UIImage(named: "navbar_icon_sort_default")?.withRenderingMode(.alwaysTemplate)
        sortImageView.tintColor = Theme.current.tint
        sortView.backgroundColor = Theme.current.accent
        sortView.layer.cornerRadius = 30
        sortView.layer.shadowColor = UIColor.black.cgColor
        sortView.layer.shadowOffset = CGSize(width: 0, height: 2)
        sortView.layer.shadowOpacity = 0.5
        sortView.layer.masksToBounds = false
    }
    
    fileprivate func applyTheme() {
        view.backgroundColor = Theme.current.tableViewCellBackgorund
        
        setupNavigationBar()
        
        searchBar.tintColor = Theme.current.tint
        searchBar.barTintColor = Theme.current.accent
        searchBar.searchTextField.textColor = Theme.current.tableViewCellDarkText
        searchBar.searchTextField.setPlaceHolderTextColor(Theme.current.tableViewCellSelectedBackground)
        
        refreshControl.tintColor = Theme.current.accent
        refreshControl.backgroundColor = Theme.current.tableViewBackground
        
        collectionView.backgroundColor = Theme.current.tableViewBackground
        collectionView.reloadData()
        
        sortImageView.tintColor = Theme.current.tint
        
        self.tabBarController?.tabBar.barTintColor = Theme.current.tabBar
        self.tabBarController?.tabBar.tintColor = Theme.current.tint
        self.tabBarController?.tabBar.unselectedItemTintColor = Theme.current.tabBarUnSelected
    }
    
    @objc func getCafes() {
        requestManager.getCafe(with: city.rawValue) { [weak self] (cafes) in
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
        }
    }
    
    func filterContentForSearchText(searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty else {
            searchResult.removeAll()
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchResult = cafes.filter({ (cafe) -> Bool in
            if cafe.name.lowercased().range(of: searchText.lowercased()) != nil {
                return true
            }
            if cafe.address.lowercased().range(of: searchText.lowercased()) != nil {
                return true
            }
            return false
        })
    }
    
    @objc func showFilterActions() {
        let alertController = UIAlertController.init(title: "選擇城市", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(title: TaiwanCity.keelung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.keelung
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.taipei.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taipei
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.taoyuan.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taoyuan
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.hsinchu.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.hsinchu
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.miaoli.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.miaoli
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.taichung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taichung
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.changhua.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.changhua
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.nantou.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.nantou
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.yunlin.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.yunlin
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.chiayi.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.chiayi
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.tainan.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.tainan
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.kaohsiung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.kaohsiung
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.pingtung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.pingtung
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.taitung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taitung
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.hualien.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.hualien
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.yilan.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.yilan
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.penghu.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.penghu
            self.getCafes()
        }
        alertController.addAction(title: TaiwanCity.lienchiang.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.lienchiang
            self.getCafes()
        }
        alertController.addAction(title: "取消", style: .cancel, isEnabled: true) { (action) in
            //
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            //            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            alertController.popoverPresentationController?.permittedArrowDirections = .up
            alertController.popoverPresentationController?.sourceView = filterImageView
            alertController.popoverPresentationController?.sourceRect = filterImageView.bounds
            // alertController.popoverPresentationController?.sourceRect = filterImageView.bounds = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
        }
        
        alertController.show()
    }
    
    @objc func showSortActions() {
        let alertController = UIAlertController.init(title: "依種類排序", message: "由大到小", preferredStyle: .actionSheet)
        alertController.addAction(title: "WIFI穩定", style: .default, isEnabled: true) { (action) in
            self.sortCafes(with: .wifi)
        }
        alertController.addAction(title: "通常有位", style: .default, isEnabled: true) { (action) in
            self.sortCafes(with: .seat)
        }
        alertController.addAction(title: "安靜程度", style: .default, isEnabled: true) { (action) in
            self.sortCafes(with: .quiet)
        }
        alertController.addAction(title: "咖啡好喝", style: .default, isEnabled: true) { (action) in
            self.sortCafes(with: .tasty)
        }
        alertController.addAction(title: "價格便宜", style: .default, isEnabled: true) { (action) in
            self.sortCafes(with: .cheap)
        }
        alertController.addAction(title: "裝潢音樂", style: .default, isEnabled: true) { (action) in
            self.sortCafes(with: .music)
        }
        alertController.addAction(title: "取消", style: .cancel, isEnabled: true) { (action) in
            //
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.permittedArrowDirections = .down
            alertController.popoverPresentationController?.sourceView = self.sortView
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: self.sortView.frame.width, height: self.sortView.frame.height)
        }
        
        alertController.show()
    }
    
    func sortCafes(with type: CafeRatingType) {
        if isSearching {
            switch type {
            case .wifi:
                searchResult.sort { (a, b) -> Bool in
                    return a.wifi > b.wifi
                }
                collectionView.reloadData()
            case .seat:
                searchResult.sort { (a, b) -> Bool in
                    return a.seat > b.seat
                }
                collectionView.reloadData()
            case .quiet:
                searchResult.sort { (a, b) -> Bool in
                    return a.quiet > b.quiet
                }
                collectionView.reloadData()
            case .cheap:
                searchResult.sort { (a, b) -> Bool in
                    return a.cheap > b.cheap
                }
                collectionView.reloadData()
            case .music:
                searchResult.sort { (a, b) -> Bool in
                    return a.music > b.music
                }
                collectionView.reloadData()
            case .tasty:
                searchResult.sort { (a, b) -> Bool in
                    return a.tasty > b.tasty
                }
                collectionView.reloadData()
            }
        } else {
            switch type {
            case .wifi:
                cafes.sort { (a, b) -> Bool in
                    return a.wifi > b.wifi
                }
                collectionView.reloadData()
            case .seat:
                cafes.sort { (a, b) -> Bool in
                    return a.seat > b.seat
                }
                collectionView.reloadData()
            case .quiet:
                cafes.sort { (a, b) -> Bool in
                    return a.quiet > b.quiet
                }
                collectionView.reloadData()
            case .cheap:
                cafes.sort { (a, b) -> Bool in
                    return a.cheap > b.cheap
                }
                collectionView.reloadData()
            case .music:
                cafes.sort { (a, b) -> Bool in
                    return a.music > b.music
                }
                collectionView.reloadData()
            case .tasty:
                cafes.sort { (a, b) -> Bool in
                    return a.tasty > b.tasty
                }
                collectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return searchResult.count
        } else {
            return cafes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CafeCollectionViewCell.self, for: indexPath)
        cell.delegate = self
        cell.indexPath = indexPath
        
        if isSearching {
            let cafe = searchResult[indexPath.row]
            cell.cafe = cafe
        } else {
            let cafe = cafes[indexPath.row]
            cell.cafe = cafe
        }
        
        cell.applyTheme()
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSearching {
            let cafe = searchResult[indexPath.row]
            
            let cafeDetailVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "CafeDetailViewController") as! CafeDetailViewController
            cafeDetailVC.cafe = cafe
            cafeDetailVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(cafeDetailVC)
        } else {
            let cafe = cafes[indexPath.row]
            
            let cafeDetailVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "CafeDetailViewController") as! CafeDetailViewController
            cafeDetailVC.cafe = cafe
            cafeDetailVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(cafeDetailVC)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
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

extension HomeViewController: CafeCollectionViewCellDelegate {
    func didClickCollectButton(_ sender: UIButton, at indexPath: IndexPath) {
        var cafe: Cafe
        if isSearching {
            cafe = searchResult[indexPath.row]
        } else {
            cafe = cafes[indexPath.row]
        }
        
        if loginManager.isLogin {
            //            var isCollected = realmManager.isCafeCollected(cafe)
            var isCollected = false
            favoriteManager.isCafeCollected(cafe) { (collected) in
                isCollected = collected
                
                if isCollected {
                    //                realmManager.removeFavoriteCafe(cafe)
                    
                    favoriteManager.removeFavoriteCafe(cafe)
                } else {
                    //                realmManager.addFavoriteCafe(cafe)
                    
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
            
        } else {
            appDelegate.presentAlertView("登入以使用收藏功能", message: nil) {
                let loginVC = UIStoryboard.main?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(loginVC)
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchText)
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
