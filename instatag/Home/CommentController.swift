//
//  CommentController.swift
//  instatag
//
//  Created by Connor Lagana on 7/9/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Firebase

class CommentController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = .white
        
        //vertical dragging is allowed even if the content is smaller than the bounds of the scroll view
        collectionView?.alwaysBounceVertical = true
        
        //TODO: Make it so that the bottom comment can be the last comment... if that makes any sense
        
        //The keyboard follows the dragging touch offscreen, and can be pulled upward again to cancel the dismiss.
        collectionView?.keyboardDismissMode = .interactive
        
        //No idea what the fuck these things do
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        //Just registering the custom cell to be reused (multiple comments) :p
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
        setupUI()
    }
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 10
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let submitButton: UIButton = {
        let bttn = UIButton(type: .system)
        bttn.setTitle("Submit", for: .normal)
        bttn.backgroundColor = .black
        bttn.setTitleColor(.white, for: .normal)
        bttn.layer.cornerRadius = 10
        bttn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        return bttn
    }()
    
    @objc func handleSubmit() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        print("post id:", self.post?.id ?? "")
        
        print("Inserting comment:", commentTextField.text ?? "")
        
        let postId = self.post?.id ?? ""
        
        //Basically what's happening is you create a dictionary that updates the values of the previous added child
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String : Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print("Failed to insert comment:", err)
                return
            }
            
            self.commentTextField.text = ""
            
            print("Successfully inserted comment.")
        }
    }
    
    func setupUI() {
        backView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        backView.addSubview(commentTextField)
        backView.addSubview(submitButton)
        
        submitButton.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -60).isActive = true
        submitButton.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -6).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        commentTextField.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10).isActive = true
        commentTextField.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 6).isActive = true
        commentTextField.rightAnchor.constraint(equalTo: submitButton.leftAnchor, constant: -6).isActive = true
        commentTextField.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -60).isActive = true
    }
    
    
    
    var comments = [Comment]()
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            //You can't use currentUser because you're fetching comments from other users
            //therefore, you fetch the uid associated with the comment which is declared in values in handleSubmit
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
            
        }) { (err) in
            print("Failed to observe comments")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //how many comments should there be?
        return comments.count
    }
    
    //Declare how big the comment cell should be
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        //dynamic sizing so that the cell will only be as tall as it needs to be
        let dummyCell = CommentCell(frame: frame)
        
        //index path is the number comment like 0, 1, 2 etc.
        dummyCell.comment = comments[indexPath.item]
        
        //makes it so that if a comment is like 1 line it will still be big enough to fit the original size of our intended cell (minimum basically)
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        
        //Returns the optimal size of the view based on its current constraints.
        
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        //height of profile picture + padding on top + padding on bottom
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //Gaps between each comment
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //this is really the only backend shit going on so make sure to understand this
    
    override var inputAccessoryView: UIView? {
        get {
            return backView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
