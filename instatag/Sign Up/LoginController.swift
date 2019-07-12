//
//  LoginController.swift
//  instatag
//
//  Created by Connor Lagana on 7/9/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        setupUI()
    }
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "waterfall")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 120/255, green: 160/255, blue: 130/255, alpha: 0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.keyboardAppearance = .dark
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.layer.cornerRadius = 14
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.keyboardAppearance = .dark
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.layer.cornerRadius = 14
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginButton: UIButton = {
        let bttn = UIButton(type: .system)
        bttn.setTitle("Login", for: .normal)
        bttn.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bttn.setTitleColor(.black, for: .normal)
        bttn.titleLabel?.font = .systemFont(ofSize: 14)
        bttn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        bttn.backgroundColor = .black
        bttn.setTitleColor(.white, for: .normal)
        bttn.layer.cornerRadius = 14
        bttn.translatesAutoresizingMaskIntoConstraints = false
        return bttn
    }()
    
    let noAccountButton: UIButton = {
        let bttn = UIButton(type: .system)
        bttn.setTitle("Don't have an account? Sign Up!", for: .normal)
        bttn.backgroundColor = UIColor(white: 0, alpha: 0.5)
        //        let color = UIColor(white: 1, alpha: 0.5)
        //        bttn.setTitleColor(color, for: .normal)
        bttn.titleLabel?.font = .systemFont(ofSize: 14)
        bttn.addTarget(self, action: #selector(handleNoAccount), for: .touchUpInside)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        bttn.backgroundColor = .clear
        return bttn
    }()
    
    @objc func handleLogin() {
        print("handle login")
        
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error: Error?) in
            
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            print("Successfully created user:", user?.user.uid ?? "")
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupNav()
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    @objc func handleNoAccount() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    
    func setupUI() {
        navigationItem.title = "Login"
        
        view.addSubview(backgroundImageView)
        view.addSubview(backView)
        view.addSubview(noAccountButton)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let padding = view.frame.height * 0.29
        
        backView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
        backView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        backView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 75).isActive = true
        backView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -75).isActive = true
        
        noAccountButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -2).isActive = true
        noAccountButton.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 2).isActive = true
        noAccountButton.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: 2).isActive = true
        
        let stackPadding = view.frame.height * 0.08
        print("the height", stackPadding)
        
        stackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: stackPadding).isActive = true
        stackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -stackPadding).isActive = true
        stackView.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -10).isActive = true
        
    }
}
