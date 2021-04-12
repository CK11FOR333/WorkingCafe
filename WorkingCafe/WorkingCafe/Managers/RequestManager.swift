//
//  RequestManager.swift
//  KGI
//
//  Created by mrfour on 3/2/16.
//  Copyright © 2016 mrfour. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

/// The Singleton that manages all requests
let requestManager = RequestManager.sharedInstance

enum ServerEnvironment {
    case test
    case production
    
    var domainString: String {
        switch self {
        case .test:
            var keys: NSDictionary?
            if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
            }

            let testApiKeyDomain = keys?["ApiKeyDomainTest"] as? String ?? "https://raw.githubusercontent.com/CK11FOR333/WorkingCafe"
            log.debug("testApiKeyDomain: \(testApiKeyDomain)")

            return testApiKeyDomain

        case .production:
            var keys: NSDictionary?
            if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
            }

            let productionApiKeyDomain = keys?["ApiKeyDomainProduction"] as? String ?? "https://raw.githubusercontent.com/CK11FOR333/WorkingCafe"
            log.debug("productionApiKeyDomain: \(productionApiKeyDomain)")

            return productionApiKeyDomain
        }
    }
}

struct AppAPI {
    static func stripURL(_ url: String) -> String {
        return requestManager.serverEnviroment.domainString + url
    }
}

class RequestManager {
    
    static let sharedInstance = RequestManager(.production)
    
    // MARK: Request Configuraion
    
    var serverEnviroment: ServerEnvironment
    
    private init(_ environment: ServerEnvironment) {
        self.serverEnviroment = environment
    }
    
    // MARK: Variables
    
    var currentRequest: Request?

    // MARK: Private Methods
    
    func baseRequest(_ method: Alamofire.HTTPMethod, url: String, parameters: [String: Any]? = nil, needToken: Bool = true, callback: @escaping (_ result :JSON) -> ()) {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        SVProgressHUD.show()

        currentRequest = AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response -> Void in

                switch response.result {
                case .success(let value):

                    SVProgressHUD.dismiss(withDelay: 0.5)
                    
                    let json = JSON(value)
                    callback(json)
                    
                case .failure(let error):

                    SVProgressHUD.dismiss()


//                    let currentVC = appDelegate.findCurrentViewController()
//                    let alertVC = AlertViewController.instantiateFromStoryboard()
//                    alertVC.titleSting = ""
//                    alertVC.messageString = error.localizedDescription
//                    alertVC.confirmString = "確定"
//                    currentVC.present(alertVC, animated: true, completion: nil)
                    log.debug(error.localizedDescription)
                    appDelegate.presentAlertView("網路錯誤", message: nil)
                    return
                }
        }
    }

}

// MARK: - Public Methods

extension RequestManager {
    
    // MARK: Fuction
    
    func cancelRequest() {
        guard let currentRequest = currentRequest else { return }

        log.debug("Canceled current request!!")
        currentRequest.cancel()
    }
    
    // MARK: API

    /// 全台咖啡廳
    func getCafe(with name: String, success: @escaping (_ cafes: [Cafe]) -> Void) {
        baseRequest(.get, url: "https://cafenomad.tw/api/v1.2/cafes/\(name)") { (json) in
            let cafeArray = json.arrayValue
            log.info("cafeArray count is \(cafeArray.count)")

            var cafes: [Cafe] = []

            for key in cafeArray {
                let cafe = Cafe(id: key["id"].stringValue,
                                mrt: key["mrt"].stringValue,
                                url: key["url"].stringValue,
                                city: key["city"].stringValue,
                                name: key["name"].stringValue,
                                socket: key["socket"].stringValue,
                                address: key["address"].stringValue,
                                longitude: key["longitude"].stringValue,
                                latitude: key["latitude"].stringValue,
                                limited_time: key["limited_time"].stringValue,
                                standing_desk: key["standing_desk"].stringValue,
								open_time: key["open_time"].stringValue,
                                wifi: key["wifi"].intValue,
                                seat: key["seat"].intValue,
                                quiet: key["quiet"].intValue,
                                tasty: key["tasty"].intValue,
                                cheap: key["cheap"].intValue,
                                music: key["music"].intValue,
                                users: [])
                cafes.append(cafe)
            }

            success(cafes)
        }
    }

}
