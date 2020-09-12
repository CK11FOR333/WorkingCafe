//
//  MapViewController.swift
//  0610
//
//  Created by Chris on 2019/7/2.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    /// 預設台北
    var city = TaiwanCity.taipei

    var cafes: [Cafe] = []

    var geoCoder = CLGeocoder()

    var annotations: [MKPointAnnotation] = []

    var locationManager = CLLocationManager()

    /// 地圖預設顯示的範圍大小 (數字越小越精確)
    let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    
    @IBAction func clickFilterButton(_ sender: UIButton) {
        showFilterActions()
    }


    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!

    @IBAction func clickLocationButton(_ sender: UIButton) {
        // 設置委任對象
        locationManager.delegate = self
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        // 取得自身定位位置的精確度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest


        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // 取得定位服務授權
            locationManager.requestWhenInUseAuthorization()

            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
            // 使用者已經拒絕定位自身位置權限
        else if CLLocationManager.authorizationStatus() == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController.init(title: "定位權限已關閉", message: "允許此App使用定位服務 請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            alertController.addAction(title: "確定", style: .default, isEnabled: true) { (action) in
                //
            }
            alertController.show()
        }
            // 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupMapView()
        setupLocationButton()
        getCafes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 停止定位自身位置
        locationManager.stopUpdatingLocation()
    }

    func setupNavigationBar() {
        navigationItem.title = MyViewControllerType.viewController1.rawValue
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_icon_filter_default"), style: .plain, target: self, action: #selector(showFilterActions))


        navigationController?.navigationBar.barStyle = UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? .default : .black

        navigationController?.navigationBar.backgroundColor = Theme.current.navigationBar
        navigationController?.navigationBar.barTintColor = Theme.current.navigationBar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = Theme.current.tint
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.current.tint]
        navigationController?.navigationBar.shadowImage = UIImage()
        
        headerView.backgroundColor = Theme.current.navigationBar
        
        locationLabel.text = city.description
        locationLabel.textColor = Theme.current.tint

        filterImageView.image = UIImage(named: "navbar_icon_filter_default")?.withRenderingMode(.alwaysTemplate)
        filterImageView.tintColor = Theme.current.tint
    }

    func setupMapView() {
//        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
    }

    func setupLocationButton() {
        locationImageView.image = UIImage(named: "google_location_con")?.withRenderingMode(.alwaysTemplate)
        locationImageView.tintColor = Theme.current.tint
        locationView.backgroundColor = Theme.current.cornerButton
        locationView.layer.cornerRadius = 30
        locationView.layer.shadowColor = UIColor.black.cgColor
        locationView.layer.shadowOffset = CGSize(width: 0, height: 2)
        locationView.layer.shadowOpacity = 0.5
        locationView.layer.masksToBounds = false
    }

    fileprivate func applyTheme() {
        view.backgroundColor = Theme.current.tableViewBackground

        setupNavigationBar()

        self.tabBarController?.tabBar.barTintColor = Theme.current.tabBar
        self.tabBarController?.tabBar.tintColor = Theme.current.tint
        if #available(iOS 10.0, *) {
            self.tabBarController?.tabBar.unselectedItemTintColor = Theme.current.tabBarUnSelected
        } else {
            // Fallback on earlier versions
        }

        locationImageView.tintColor = Theme.current.tint
        locationLabel.text = city.description
        
        if #available(iOS 13.0, *) {
             overrideUserInterfaceStyle =  UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? .dark : .light
        }
    }
    
    func getCafes() {
        requestManager.getCafe(with: city.rawValue) { [weak self] (cafes) in
            guard let strongSelf = self else { return }
            strongSelf.cafes = cafes
            strongSelf.showCafes()
        }
    }

    func showCafes() {
        DispatchQueue.global().async {
            let tempAnno: [MKPointAnnotation] = self.annotations
            self.annotations.removeAll()

            for cafe in self.cafes {
                let location = CLLocation(latitude: Double(cafe.latitude)!, longitude: Double(cafe.longitude)!)
                let annotation = MKPointAnnotation()
                annotation.title = cafe.name
                annotation.subtitle = cafe.address
                annotation.coordinate = location.coordinate
                self.annotations.append(annotation)
            }

            DispatchQueue.main.async {
                self.mapView.removeAnnotations(tempAnno)
                self.mapView.showAnnotations(self.annotations, animated: true)
                //        if annotations.count > 0 {
                //            mapView.selectAnnotation(annotations.last!, animated: true)
                //        }
            }
        }
    }

    @objc func showFilterActions() {
        let alertController = UIAlertController.init(title: "選擇城市", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(title: TaiwanCity.keelung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.keelung
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.taipei.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taipei
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.taoyuan.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taoyuan
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.hsinchu.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.hsinchu
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.miaoli.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.miaoli
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.taichung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taichung
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.changhua.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.changhua
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.nantou.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.nantou
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.yunlin.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.yunlin
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.chiayi.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.chiayi
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.tainan.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.tainan
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.kaohsiung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.kaohsiung
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.pingtung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.pingtung
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.taitung.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.taitung
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.hualien.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.hualien
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.yilan.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.yilan
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.penghu.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.penghu
            self.getCafes()
            self.applyTheme()
        }
        alertController.addAction(title: TaiwanCity.lienchiang.description, style: .default, isEnabled: true) { (action) in
            self.city = TaiwanCity.lienchiang
            self.getCafes()
            self.applyTheme()
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


}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        // 印出目前所在位置座標
        let currentLocation = locations[0] as CLLocation
        log.info("Current Location latitude: \(currentLocation.coordinate.latitude), longitude: \(currentLocation.coordinate.longitude)")

        // 設置地圖顯示的範圍與中心點座標
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: currentLocationSpan)
        mapView.setRegion(currentRegion, animated: true)
    }
    
}
