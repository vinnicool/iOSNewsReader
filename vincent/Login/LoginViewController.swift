//
//  ViewController.swift
//  vincent
//
//  Created by Vincent on 10/23/18.
//  Copyright © 2018 drok. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var continueText: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    public static let authtokenKey = "authtoken";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewTexts()
        setupFormProperties()
        checkIfStillLoggedIn()
    }
    
    func setViewTexts() {
        title = NSLocalizedString("title_login", comment: "")
        
        usernameField.placeholder = NSLocalizedString("placeholder_username", comment: "")
        passwordField.placeholder = NSLocalizedString("placeholder_password", comment: "")
        
        continueText.text = NSLocalizedString("explanation_continueNoLogin", comment: "")
        
        loginButton.setTitle(NSLocalizedString("action_login", comment: ""), for: .normal)
        
        registerButton.setTitle(NSLocalizedString("action_register", comment: ""), for: .normal)
        continueButton.setTitle(NSLocalizedString("action_continueNoLogin", comment: ""), for: .normal)
    }
    
    func setupFormProperties() {
        usernameField.autocorrectionType = .no
        
        passwordField.isSecureTextEntry = true
        passwordField.autocorrectionType = .no
    }
    
   
    @IBAction func action_login(_ sender: Any) {
        attemptLogin()
    }
    
    
    @IBAction func action_register(_ sender: Any) {
        attemptRegister()
    }
    
    
    @IBAction func action_noLogin(_ sender: Any) {
        continueWithoutLogin()
    }
    
    func validateForm() -> Bool {
        guard usernameField.text?.count ?? 0 >= 4 else { return false }
        guard passwordField.text?.count ?? 0 >= 4 else { return false }
        
        return true
    }
    
    func attemptLogin(){
        guard validateForm() else { return }
        
        let user = User(username: usernameField.text ?? "", password: passwordField.text ?? "")
        NewsreaderApiManager.login(user: user).responseData(completionHandler: { (response) in
            guard let jsonData = response.data else { return }
            guard response.error == nil else { self.view.makeToast(NSLocalizedString("unknown_error", comment: "")); return }
            let decoder = JSONDecoder()
            let httptoken = try? decoder.decode(HttpAuthToken.self, from: jsonData)
            
            if let httptoken = httptoken {
                AppDelegate.authToken = httptoken.authToken
                KeychainWrapper.standard.set(httptoken.authToken, forKey: LoginViewController.authtokenKey)
                self.clearForm()
                self.navigateToNews()
            }
            else {
                self.invalidLogin()
            }
        })
    }
    
    private func clearForm() {
        usernameField.text = ""
        passwordField.text = ""
    }
    
    func invalidLogin(){
        self.view?.makeToast(NSLocalizedString("error_validationError", comment: ""))
    }
    
    func attemptRegister(){
        guard validateForm() else { return }
        
        let user = User(username: usernameField.text ?? "", password: passwordField.text ?? "")
        NewsreaderApiManager.register(user: user).responseData(completionHandler: { (response) in
            guard response.error == nil else { self.view.makeToast(NSLocalizedString("unknown_error", comment: "")); return }
            if let data = response.data {
                let decoder = JSONDecoder()
                
                let customResponse = try? decoder.decode(CustomHttpResponse.self, from: data)
                
                if customResponse?.success == true {
                    self.view?.makeToast(NSLocalizedString("message_registered", comment: ""))
                }
                else {
                    self.invalidLogin()
                }
            }
        })
    }
    
    func continueWithoutLogin(){
        navigateToNews()
    }
    
    func checkIfStillLoggedIn() {
        if KeychainWrapper.standard.hasValue(forKey: LoginViewController.authtokenKey) {
            if let token = KeychainWrapper.standard.string(forKey: LoginViewController.authtokenKey) {
                AppDelegate.authToken = token
                navigateToNews()
            }
        }
    }
    
    func navigateToNews(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsTableVc = storyboard.instantiateViewController(withIdentifier: "NewsOverviewTableViewController")
        self.navigationController?.pushViewController(newsTableVc, animated: true)
    }
}

