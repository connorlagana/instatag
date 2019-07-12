//
//  SignUpController.swift
//  instatag
//
//  Created by Connor Lagana on 7/9/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        setupUI()
    }
    
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "beach")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 170/255, green: 100/255, blue: 70/255, alpha: 0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.keyboardAppearance = .dark
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.layer.cornerRadius = 14
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
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
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
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
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let bttn = UIButton(type: .system)
        bttn.setTitle("Sign Up", for: .normal)
        bttn.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bttn.alpha = 0.5
        bttn.setTitleColor(.black, for: .normal)
        bttn.titleLabel?.font = .systemFont(ofSize: 14)
        bttn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        bttn.backgroundColor = .black
        bttn.setTitleColor(.white, for: .normal)
        bttn.layer.cornerRadius = 14
        bttn.translatesAutoresizingMaskIntoConstraints = false
        return bttn
    }()
    
    let profilePicture: UIButton = {
        let view = UIButton()
        view.imageView?.image = nil
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 14
        view.addTarget(self, action: #selector(handlePicture), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func handlePicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error: Error?) in
            
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            print("Successfully created user:", user?.user.uid ?? "")
            
            guard let image = self.profilePicture.imageView?.image else { return }
            
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err {
                    print("Failed to upload profile image:", err)
                    return
                }
                
                // Firebase 5 Update: Must now retrieve downloadURL
                storageRef.downloadURL(completion: { (downloadURL, err) in
                    if let err = err {
                        print("Failed to fetch downloadURL:", err)
                        return
                    }
                    
                    // Why the fuck doesnt this work
                    //                    SVProgressHUD.showSuccess(withStatus: "Click the login button to sign in")
                    
                    guard let profileImageUrl = downloadURL?.absoluteString else { return }
                    
                    print("Successfully uploaded profile image:", profileImageUrl)
                    
                    guard let uid = user?.user.uid else { return }
                    
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl]
                    let values = [uid: dictionaryValues]
                    
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if let err = err {
                            print("Failed to save user info into db:", err)
                            return
                        }
                        else {
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
                        print("Successfully saved user info to db")
                        
                        
                    })
                })
            })
            
        })
    }
    
    func setupUI() {
        navigationItem.title = "Sign Up"
        
        view.addSubview(backgroundImageView)
        view.addSubview(backView)
        
        let stackView = UIStackView(arrangedSubviews: [usernameTextField,emailTextField, passwordTextField, signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let padding = view.frame.height * 0.25
        
        backView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
        backView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        backView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 75).isActive = true
        backView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -75).isActive = true
        
        let stackPadding = view.frame.height * 0.1
        print("the height", stackPadding)
        
        stackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: stackPadding).isActive = true
        stackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -stackPadding).isActive = true
        stackView.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -10).isActive = true
        
        view.addSubview(profilePicture)
        
        profilePicture.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -12).isActive = true
        profilePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicture.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicture.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profilePicture.layer.cornerRadius = profilePicture.layer.cornerRadius
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTextInputChange() {
        let isEmailPasswordValid = emailTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0 &&
            usernameTextField.text?.count ?? 0 > 0
        
        if isEmailPasswordValid {
            signUpButton.isEnabled = true
            signUpButton.alpha = 1
        }
        else {
            signUpButton.alpha = 0.5
        }
    }
    
    
}
