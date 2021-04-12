//
//  AppDelegate.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/7/19.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit
import SwiftyBeaver
import Firebase
import FirebaseAuth
import GoogleSignIn

let log = SwiftyBeaver.self

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupSwiftyBeaver()
        setupFirebase()
        setupGoogleSignIn()
        applyTheme()
        return true
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
}

extension AppDelegate {
    func logUser() {
		Crashlytics.crashlytics().setUserID("123456789")
    }

    func setupSwiftyBeaver() {
        // add log destinations. at least one is needed!
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()  // log to default swiftybeaver.log file
        let cloud = SBPlatformDestination(appID: "MmnRZ7", appSecret: "noarUzP7agwkSuqiesbcy0auonjynMOt", encryptionKey: "hjgKwmrp8cywcdulqoyH72jniqc8elfm") // to cloud

        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        // or use this for JSON output: console.format = "$J"

        // add the destinations to SwiftyBeaver
        log.addDestination(console)
        log.addDestination(file)
        log.addDestination(cloud)
    }

    func setupFirebase() {
        FirebaseApp.configure()
    }

    func applyTheme() {
        if UserDefaults.standard.object(forKey: "kIsDarkTheme") == nil {
            UserDefaults.standard.set(false, forKey: "kIsDarkTheme")
            Theme.current = LightTheme()
        } else {
            Theme.current = UserDefaults.standard.bool(forKey: "kIsDarkTheme") ? DarkTheme() : LightTheme()
        }
    }

}


extension AppDelegate {

    func presentAlertView(_ title: String?, message: String?, completion: (() -> Void)? = nil) {
        let visibleViewController = window?.visibleViewController
        visibleViewController?.presentAlertView(title, message: message, completion: completion)
    }

}

// MARK: - Google Sign In

extension AppDelegate: GIDSignInDelegate {

    func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        if loginManager.isLogin && loginManager.accountProvider == "google" {
            loginManager.signInSilently = true
            GIDSignIn.sharedInstance().restorePreviousSignIn()
        }
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // ...
        if let error = error {
            log.error("Google Sign In Error: \(error.localizedDescription)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AuthLogin"), object: nil, userInfo: ["Error": "\(error.localizedDescription)"])
            return
        }

        guard let authentication = user.authentication else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AuthLogin"), object: nil, userInfo: ["Error": "authentication error"])
            return
        }

        loginManager.accountProvider = "google"

        log.info("Google Sign in Succeed")
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AuthLogin"), object: nil, userInfo: ["credential": credential])
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        if let error = error {
            log.error("Signing Out Error: \(error.localizedDescription)")
            return
        }

        //
        log.info("Google Signing Out Succeed")
    }

}
