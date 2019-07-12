//
//  HomeCell.swift
//  instatag
//
//  Created by Connor Lagana on 7/9/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit

protocol HomeCellDelegate {
    func didTapComment(post: Post)
}

class HomeCell: UICollectionViewCell {
    
    var delegate: HomeCellDelegate?

    var post: Post? {
        didSet {
            guard let postImageUrl = post?.imageUrl else { return }
            
            uploadedImageView.loadImage(urlString: postImageUrl)
            
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            
            profImageView.loadImage(urlString: profileImageUrl)
            
            captionView.text = post?.caption
            
            usernameLabel.text = post?.user.username
            
//            setupAttributedCaption()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    let profImageView: CustomImageView = {
        let iv =  CustomImageView()
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let uploadedImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 10)
        lbl.text = "George_Washington"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let captionView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.allowsEditingTextAttributes = false
        tv.text = "We the People of the United States, in Order to form a more perfect Union, establish Justice, insure domestic Tranquility, provide for the common defence, promote the general Welfare, and secure the Blessings of Liberty to ourselves and our Posterity, do ordain and establish this Constitution for the United States of America."
        tv.font = .systemFont(ofSize: 14)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 14
        tv.isScrollEnabled = false
        return tv
    }()
    
    lazy var commentButton: UIButton = {
        let bttn = UIButton(type: .system)
        bttn.layer.cornerRadius = 8
        bttn.setTitle("Comment", for: .normal)
        bttn.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let color = UIColor(white: 1, alpha: 0.5)
        bttn.setTitleColor(color, for: .normal)
        bttn.titleLabel?.font = .systemFont(ofSize: 12)
        bttn.addTarget(self, action: #selector(goToComments), for: .touchUpInside)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        return bttn
    }()
    
    @objc func goToComments() {
        print("Trying to show comments...")
        guard let post = post else { return }
        
        delegate?.didTapComment(post: post)
    }
    
    func setupCell() {
        backgroundColor = .clear
        
        addSubview(uploadedImageView)
        addSubview(profImageView)
        addSubview(captionView)
        addSubview(commentButton)
        addSubview(usernameLabel)
        
        uploadedImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        uploadedImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadedImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        uploadedImageView.heightAnchor.constraint(equalToConstant: frame.width).isActive = true
        
        profImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        profImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
        profImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: profImageView.bottomAnchor, constant: 4).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profImageView.leftAnchor).isActive = true
//        usernameLabel.rightAnchor.constraint(equalTo: profImageView.rightAnchor).isActive = true
        
        captionView.topAnchor.constraint(equalTo: uploadedImageView.bottomAnchor, constant: 4).isActive = true
        captionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        captionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        captionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        commentButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
        commentButton.bottomAnchor.constraint(equalTo: uploadedImageView.bottomAnchor, constant: -6).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
