//
//  PHeader.swift
//  instatag
//
//  Created by Connor Lagana on 7/10/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Firebase

class ProfHeader: UICollectionViewCell {
    
    var posts = [Post]()
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profilePicture.loadImage(urlString: profileImageUrl)
            
            usernameTitle.text = user?.username
            
            setupEditFollowButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 240/255, green: 160/255, blue: 90/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profilePicture: CustomImageView = {
        let view = CustomImageView()
        view.backgroundColor = .cyan
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let usernameTitle: UILabel = {
        let label = UILabel()
        label.text = "@ConnorLagana"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followButton: UIButton = {
        let bttn = UIButton(type: .system)
        bttn.backgroundColor = .black
        bttn.setTitle("Follow", for: .normal)
        bttn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        bttn.setTitleColor(.white, for: .normal)
        bttn.layer.cornerRadius = 14
        bttn.addTarget(self, action: #selector(followUser), for: .touchUpInside)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        return bttn
    }()
    
    func setupUI() {
        backgroundColor = UIColor.init(red: 240/255, green: 80/255, blue: 80/255, alpha: 1)
        
        addSubview(backView)
        addSubview(profilePicture)
        addSubview(usernameTitle)
        addSubview(followButton)
        
        backView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backView.heightAnchor.constraint(equalToConstant: frame.height/2).isActive = true
        
        let pictureWidth = (frame.width/3) - 12
        
        profilePicture.centerYAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        profilePicture.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: pictureWidth).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: pictureWidth).isActive = true
        
        usernameTitle.topAnchor.constraint(equalTo: topAnchor).isActive = true
        usernameTitle.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        usernameTitle.bottomAnchor.constraint(equalTo: profilePicture.topAnchor).isActive = true
        usernameTitle.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        followButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 10).isActive = true
        followButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        followButton.rightAnchor.constraint(equalTo: profilePicture.leftAnchor, constant: -10).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 90)
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            followButton.isHidden = true
        } else {
            
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    
                    self.followButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    self.setFollowStyle()
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following:", err)
            })
        }
    }
    
    @objc func followUser() {
        print("Execute edit profile / follow / unfollow logic...")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if followButton.titleLabel?.text == "Unfollow" {
            
            //unfollow
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                
                print("Successfully unfollowed user:", self.user?.username ?? "")
                
                self.setFollowStyle()
            })
            
        }
            
        else {
            //follow
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                
                print("Successfully followed user: ", self.user?.username ?? "")
                
                self.followButton.setTitle("Unfollow", for: .normal)
                self.followButton.backgroundColor = .black
                self.followButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    fileprivate func setFollowStyle() {
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.backgroundColor = .white
        self.followButton.setTitleColor(.black, for: .normal)
        self.followButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

