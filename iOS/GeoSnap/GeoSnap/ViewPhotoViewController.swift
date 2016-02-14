//
//  ViewPhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Click image to make larger.

import UIKit
import Parse

class ViewPhotoViewController: UIViewController {
    
    @IBOutlet weak var creatorUsername: UILabel!
    @IBOutlet weak var postComment: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!

    var objectId: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(objectId)
//        populateFromPost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func populateFromPost() {
//        creatorUsername.text = post.postInformation["userId"] as? String
//        postComment.text = post.postInformation["comment"] as? String
//        postPhoto.image = post.photo
//    }
}
