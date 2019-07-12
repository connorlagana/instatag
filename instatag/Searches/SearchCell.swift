//
//  SearchCell.swift
//  instatag
//
//  Created by Connor Lagana on 7/10/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .gray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
    }
    
    func setupUI() {
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 3).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 3).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: frame.height - 6).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
//        addSubview(separatorView)
//        separatorView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
