//
//  LoginViewController.swift
//  0610
//
//  Created by Chris on 2019/7/30.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import SVProgressHUD
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var logInButton: UIButton!

    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var googleButton: GIDSignInButton!

    @IBOutlet weak var googleButtonView: UIView!
    
    @IBOutlet weak var signInWithAppleButtonView: UIView!
    
    @IBAction func clickAppleButton(_ sender: UIButton) {
        loginManager.delegate = self
        loginManager.presentingViewController = self
        loginManager.loginWithApple()
    }

    @IBAction func clickGoogleButton(_ sender: UIButton) {
        loginManager.delegate = self
        loginManager.presentingViewController = self
        loginManager.loginWithGoogle()
    }

    @IBAction func clickSignUpButton(_ sender: UIButton) {
        if emailTextField.text == "" {
            showEmailAndPasswordError()
        } else {
            loginManager.delegate = self
            loginManager.presentingViewController = self
            loginManager.signUp(with: emailTextField.text!, password: passwordTextField.text!)
        }
    }

    @IBAction func clickSignInButton(_ sender: UIButton) {
        if emailTextField.text == "" {
            showEmailAndPasswordError()
        } else {
            loginManager.delegate = self
            loginManager.presentingViewController = self
            loginManager.login(with: emailTextField.text!, password: passwordTextField.text!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareButtons()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTheme()
    }


    func prepareButtons() {
        logInButton.cornerRadius = 20
//        logInButton.clipsToBounds = true
        googleButtonView.cornerRadius = 20
//        googleButton.clipsToBounds = true
        
        signInWithAppleButtonView.cornerRadius = 20
        
//        let authorizationAppleIDButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton()
//        authorizationAppleIDButton.addTarget(self, action: #selector(clickAppleButton), for: UIControl.Event.touchUpInside)
//
//        authorizationAppleIDButton.frame = self.signInWithAppleButtonView.bounds
//        self.signInWithAppleButtonView.addSubview(authorizationAppleIDButton)

    }
    
//    @objc @available(iOS 13, *)
//    func clickAppleButton() {
//        loginManager.delegate = self
//        loginManager.presentingViewController = self
//        loginManager.loginWithApple()
//    }

    func showEmailAndPasswordError() {
        let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)

        present(alertController, animated: true, completion: nil)
    }

    func applyTheme() {
        emailTextField.backgroundColor = Theme.current.tableViewCellBackgorund
        passwordTextField.backgroundColor = Theme.current.tableViewCellBackgorund
        
        emailTextField.setPlaceHolderTextColor(Theme.current.tableViewCellSelectedBackground)
        passwordTextField.setPlaceHolderTextColor(Theme.current.tableViewCellSelectedBackground)
        
        emailTextField.textColor = Theme.current.tableViewCellLightText
        passwordTextField.textColor = Theme.current.tableViewCellLightText
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
}

extension LoginViewController: LoginManagerDelegate {

    func signUpSuccess() {
        let alertController = UIAlertController(title: "註冊成功", message: nil, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "確定", style: .default, handler: { (action) in
            self.navigationController?.popViewController()
        })
        alertController.addAction(defaultAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func signUpFail(with errorString: String) {
        let alertController = UIAlertController(title: "註冊失敗", message: errorString, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func loginSuccess() {
        let alertController = UIAlertController(title: "登入成功", message: nil, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "確定", style: .default, handler: { (action) in
            self.navigationController?.popViewController()
        })
        alertController.addAction(defaultAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func loginFail(with errorString: String) {
        let alertController = UIAlertController(title: "登入失敗", message: errorString, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func loginCancel() {
        //
    }

    func logoutSuccess() {
        //
    }

    func logoutFail(with errorString: String) {
        //
    }

}
