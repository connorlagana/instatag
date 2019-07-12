//
//  Util.swift
//  instatag
//
//  Created by Connor Lagana on 7/9/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    // () parameters -> () output that it expects
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        print("Fetching User with UID: ", uid)
        
        //Get current user
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: uid, dictionary: userDictionary)
            //            let user = User(dictionary: userDictionary)
            
            //Find out current user and fetch posts
            
            //            self.fetchPostsWithUser(user: user)
            
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
        
    }
}
