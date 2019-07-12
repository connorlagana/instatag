//
//  NextPhotoController.swift
//  instatag
//
//  Created by Connor Lagana on 7/10/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Firebase

class NextPhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupUI()
    }
    
    let backView: UIView = {
        let view = UIView()
        let color = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        view.backgroundColor = color
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let captionView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 12
        return tv
    }()
    
    
    
    fileprivate func setupUI() {
        
        view.addSubview(backView)
        view.addSubview(imageView)
        view.addSubview(captionView)
        
        backView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        backView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6).isActive = true
        backView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6).isActive = true
        backView.heightAnchor.constraint(equalToConstant: view.frame.height/2).isActive = true
        
        imageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 4).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        captionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        captionView.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 10).isActive = true
        captionView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10).isActive = true
        captionView.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -10).isActive = true
    }
    
    @objc func handleShare() {
        guard let caption = captionView.text, !caption.isEmpty else { return }
        guard let image = selectedImage else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to retrieve downloadURL:", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else { return }
                
                print("Successfully uploaded post image:", imageUrl)
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            })
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        guard let caption = captionView.text else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err)
                return
            }
            
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: NextPhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
