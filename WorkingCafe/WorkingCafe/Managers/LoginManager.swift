//
//  LoginManager.swift
//  0610
//
//  Created by Chris on 2019/8/1.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import SVProgressHUD
import AuthenticationServices
import CryptoKit


protocol LoginManagerDelegate: class {
    func signUpSuccess()
    func signUpFail(with errorString: String)

    func loginSuccess()
    func loginFail(with errorString: String)
    func loginCancel()

    func logoutSuccess()
    func logoutFail(with errorString: String)
}

let loginManager = LoginManager.shared

final class LoginManager: NSObject {

    weak var delegate: LoginManagerDelegate?

    static let shared = LoginManager()

    var authHandle: AuthStateDidChangeListenerHandle?

    var presentingViewController: UIViewController?

    var signInSilently = false

    var isLogin: Bool = false
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?


    var accountProvider: String {
        get { return userDefaults.value(forKey: "loginAccountProvider") as? String ?? ""}
        set { userDefaults.set(newValue as String? ?? "", forKey: "loginAccountProvider") }
    }

    var accountID: String {
        get { return userDefaults.value(forKey: "loginAccountID") as? String ?? ""}
        set { userDefaults.set(newValue as String? ?? "", forKey: "loginAccountID") }
    }

    var accountName: String {
        get { return userDefaults.value(forKey: "loginAccountName") as? String ?? ""}
        set { userDefaults.set(newValue as String? ?? "", forKey: "loginAccountName") }
    }

    var accountEmail: String {
        get { return userDefaults.value(forKey: "loginAccountEmail") as? String ?? ""}
        set { userDefaults.set(newValue as String? ?? "", forKey: "loginAccountEmail") }
    }

    var accountPhotoUrl: String {
        get { return userDefaults.value(forKey: "loginAccountPhotoUrl") as? String ?? ""}
        set { userDefaults.set(newValue as String? ?? "", forKey: "loginAccountPhotoUrl") }
    }

    override init() {
        super.init()
//        GIDSignIn.sharedInstance().uiDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(receiveToggleAuthUINotification(_:)), name: NSNotification.Name(rawValue: "AuthLogin"), object: nil)

        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            // ...
            if user != nil {
                strongSelf.isLogin = true
            } else {
                strongSelf.isLogin = false
            }
        }
    }

    deinit {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }

    func clearAccountValue() {
        accountProvider = ""
//        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
    }

    func forceLogout() {
        SVProgressHUD.show()

        clearAccountValue()

        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()

            SVProgressHUD.dismiss()
            log.info("Signing Out Succeed")

            self.delegate?.logoutSuccess()
        }
        catch let signOutError as NSError {
            SVProgressHUD.dismiss()
            log.debug("Error signing out: \(signOutError.localizedDescription)")

            self.delegate?.logoutFail(with: signOutError.localizedDescription)
        }
    }

    func loginWithGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = presentingViewController
        GIDSignIn.sharedInstance().signIn()
    }

    func loginWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = presentingViewController as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    
    func loginWithFacebook(with viewController: UIViewController) {
        //
    }

    func login(with email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }

            guard let error = error else {

                if let user = authResult?.user {

                    log.info("Auth Sign In Successfully")

                    // The user's ID, unique to the Firebase project.
                    // Do NOT use this value to authenticate with your backend server,
                    // if you have one. Use getTokenWithCompletion:completion: instead.
//                    strongSelf.accountID = user.uid
					
                    strongSelf.accountName = user.displayName ?? ""
                    strongSelf.accountEmail = user.email ?? ""
                    strongSelf.accountPhotoUrl = user.photoURL?.absoluteString ?? ""

//                    let collection = Firestore.firestore().collection("Users")
//
//                    let userDoc = User(providerID: user.providerID,
//                                       uid: user.uid,
//                                       displayName: user.displayName ?? "",
//                                       photoURLstr: user.photoURL?.absoluteString ?? "",
//                                       email: user.email ?? "",
//                                       phoneNumber: user.phoneNumber ?? "")
//
//                    collection.addDocument(data: userDoc.dictionary)


//                    // Writing data in a transaction
//                    let firestore = Firestore.firestore()
//                    firestore.runTransaction({ (transaction, errorPointer) -> Any? in
//
//                        let userDoc = User(providerID: user.providerID,
//                                           uid: user.uid,
//                                           displayName: user.displayName ?? "",
//                                           photoURLstr: user.photoURL?.absoluteString ?? "",
//                                           email: user.email ?? "",
//                                           phoneNumber: user.phoneNumber ?? "")
//
//                        transaction.updateData([:], forDocument: userDoc)
//
//                    }, completion: { (object, error) in
//                        if let error = error {
//                            log.error("Transaction error: \(error.localizedDescription)")
//                        }
//                    })

                    strongSelf.delegate?.loginSuccess()

                }

                return
            }

            log.error("Auth Sign In Error: \(error.localizedDescription)")
            strongSelf.delegate?.loginFail(with: error.localizedDescription)
        }
    }

    func signUp(with email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }

            guard let error = error else {
                log.info("Auth Sign Up Successfully")
                strongSelf.delegate?.signUpSuccess()
                return
            }

            log.error("Auth Sign Up Error: \(error.localizedDescription)")
            strongSelf.delegate?.signUpFail(with: error.localizedDescription)
        }
    }

    @objc fileprivate func receiveToggleAuthUINotification(_ notification: Notification) {
        if let userInfo = notification.userInfo, let credential = userInfo["credential"] as? AuthCredential {

            if signInSilently {
                signInSilently = false
            } else {
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        //
                        log.error("Auth Sign In Error: \(error.localizedDescription)")
                        self.delegate?.loginFail(with: error.localizedDescription)

                        return
                    }

                    // User is signed in
                    log.info("Auth Signing In Succeed")

                    self.delegate?.loginSuccess()
                }
            }

        } else if let userInfo = notification.userInfo, let errorDescription = userInfo["Error"] as? String {
            self.clearAccountValue()
            if errorDescription.hasPrefix("The user canceled") {
                self.delegate?.loginCancel()
            } else {
                self.delegate?.loginFail(with: errorDescription)
            }
        } else {
            self.clearAccountValue()
            self.delegate?.loginFail(with: "loginFail")
        }
    }


}

// MARK: - GIDSignIn UI Delegate
//
//extension LoginManager: GIDSignInUIDelegate {
//
//    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
//        log.info("")
//        //        SVProgressHUD.show()
//    }
//
//    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//        log.info("")
//        if let visibleViewController = appDelegate.window?.visibleViewController {
//            visibleViewController.present(viewController, animated: true, completion: {
//                log.info("present")
//            })
//        }
//    }
//
//    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//        log.info("")
//        if let visibleViewController = appDelegate.window?.visibleViewController {
//            visibleViewController.dismiss(animated: true, completion: {
//                log.info("dismiss")
//            })
//        }
//    }
//
//}

extension LoginManager {
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

@available(iOS 13.0, *)
extension LoginManager: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                log.error("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                log.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    log.error("Auth Sign In Error: \(error.localizedDescription)")
                    self.delegate?.loginFail(with: error.localizedDescription)
                    
                    return
                }
                // User is signed in to Firebase with Apple.
                log.info("Auth Signing In Succeed")
                
                self.delegate?.loginSuccess()
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch (error) {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
        
        log.error("didCompleteWithError: \(error.localizedDescription)")
    }

}
