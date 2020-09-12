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

    var vcType: MyViewControllerType!

    /// 預設台北
    var city = TaiwanCity.taipei

    var cafes: [Cafe] = []
    var searchResult: [Cafe] = []

    var refreshControl: UIRefreshControl!
    var searchController: UISearchController!

    var authHandle: AuthStateDidChangeListenerHandle?
    var isLogin: Bool = false

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var SortView: UIView!
    @IBOutlet weak var SortImageView: UIImageView!
    @IBOutlet weak var SortButton: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    
    @IBAction func clickFilterButton(_ sender: UIButton) {
        showFilterActions()
    }
    
    @IBAction func clickSortButton(_ sender: UIButton) {
        showSortActions()
    }

//    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSortButton()
        getCafes()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTheme()
    }

    func setupNavigationBar() {
        navigationItem.title = MyViewControllerType.viewController0.rawValue
        //        navigationItem.title = city.description
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_icon_filter_default"), style: .plain, target: self, action: #selector(showFilterActions))

        
        //        navigationItem.searchController = searchController
        
    
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

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        // SearchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "搜尋店家名稱、地址"
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true

        
        tableView.tableHeaderView = searchController.searchBar

        refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(getCafes), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }

        tableView.register(nibWithCellClass: CafeTableViewCell.self)
    }

    func setupSortButton() {
        SortImageView.image = UIImage(named: "navbar_icon_sort_default")?.withRenderingMode(.alwaysTemplate)
        SortImageView.tintColor = Theme.current.tint
        SortView.backgroundColor = Theme.current.accent
        SortView.layer.cornerRadius = 30
        SortView.layer.shadowColor = UIColor.black.cgColor
        SortView.layer.shadowOffset = CGSize(width: 0, height: 2)
        SortView.layer.shadowOpacity = 0.5
        SortView.layer.masksToBounds = false
    }
    
    
    fileprivate func applyTheme() {
        view.backgroundColor = Theme.current.tableViewCellBackgorund

        setupNavigationBar()

        searchController.searchBar.tintColor = Theme.current.tint
        searchController.searchBar.barTintColor = Theme.current.accent
        searchController.searchBar.searchTextField.textColor = Theme.current.tableViewCellDarkText
        searchController.searchBar.searchTextField.setPlaceHolderTextColor(Theme.current.tableViewCellSelectedBackground)
                
        refreshControl.tintColor = Theme.current.accent
        refreshControl.backgroundColor = Theme.current.tableViewBackground
        
        tableView.backgroundColor = Theme.current.tableViewBackground
        tableView.reloadData()
        
        SortImageView.tintColor = Theme.current.tint

        self.tabBarController?.tabBar.barTintColor = Theme.current.tabBar
        self.tabBarController?.tabBar.tintColor = Theme.current.tint
        self.tabBarController?.tabBar.unselectedItemTintColor = Theme.current.tabBarUnSelected
    }

    @objc func getCafes() {
        requestManager.getCafe(with: city.rawValue) { [weak self] (cafes) in
            guard let strongSelf = self else { return }
            strongSelf.cafes = cafes
            if #available(iOS 10.0, *) {
                strongSelf.tableView.refreshControl?.endRefreshing()
            } else {
                // Fallback on earlier versions
                strongSelf.refreshControl.endRefreshing()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                strongSelf.tableView.reloadData()
                strongSelf.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self?.applyTheme()
            })
        }
    }

    func filterContentForSearchText(searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty else {
            searchResult.removeAll()
            return
        }

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
            alertController.popoverPresentationController?.sourceView = self.SortView
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: self.SortView.frame.width, height: self.SortView.frame.height)
        }

        alertController.show()
    }

    func sortCafes(with type: CafeRatingType) {
        if searchController.isActive {
            switch type {
            case .wifi:
                searchResult.sort { (a, b) -> Bool in
                    return a.wifi > b.wifi
                }
                tableView.reloadData()
            case .seat:
                searchResult.sort { (a, b) -> Bool in
                    return a.seat > b.seat
                }
                tableView.reloadData()
            case .quiet:
                searchResult.sort { (a, b) -> Bool in
                    return a.quiet > b.quiet
                }
                tableView.reloadData()
            case .cheap:
                searchResult.sort { (a, b) -> Bool in
                    return a.cheap > b.cheap
                }
                tableView.reloadData()
            case .music:
                searchResult.sort { (a, b) -> Bool in
                    return a.music > b.music
                }
                tableView.reloadData()
            case .tasty:
                searchResult.sort { (a, b) -> Bool in
                    return a.tasty > b.tasty
                }
                tableView.reloadData()
            }
        } else {
            switch type {
            case .wifi:
                cafes.sort { (a, b) -> Bool in
                    return a.wifi > b.wifi
                }
                tableView.reloadData()
            case .seat:
                cafes.sort { (a, b) -> Bool in
                    return a.seat > b.seat
                }
                tableView.reloadData()
            case .quiet:
                cafes.sort { (a, b) -> Bool in
                    return a.quiet > b.quiet
                }
                tableView.reloadData()
            case .cheap:
                cafes.sort { (a, b) -> Bool in
                    return a.cheap > b.cheap
                }
                tableView.reloadData()
            case .music:
                cafes.sort { (a, b) -> Bool in
                    return a.music > b.music
                }
                tableView.reloadData()
            case .tasty:
                cafes.sort { (a, b) -> Bool in
                    return a.tasty > b.tasty
                }
                tableView.reloadData()
            }
        }
    }

}

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResult.count
        } else {
            return cafes.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CafeTableViewCell", for: indexPath) as! CafeTableViewCell
        cell.selectionStyle = .none

        cell.delegate = self

        cell.indexPath = indexPath

        if searchController.isActive {
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

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            let cafe = searchResult[indexPath.row]
            if let url = URL(string: cafe.url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
            }
        } else {
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

}

extension HomeViewController: CafeTableViewCellDelegate {

    func didClickCollectButton(_ sender: UIButton, at indexPath: IndexPath) {
        var cafe: Cafe
        if searchController.isActive {
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

extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText: searchText)
        tableView.reloadData()
    }

}

extension HomeViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.headerView.isHidden = true
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.headerView.isHidden = false
    }

}
