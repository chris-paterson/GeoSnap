//
//  ViewPhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit
import Parse

class ViewPhotoViewController: UIViewController {
    
    @IBOutlet weak var creatorUsername: UILabel!
    @IBOutlet weak var postComment: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!
    
    var photo: UIImage = UIImage(named: "polaroid.pdf")!
    var photoComment: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        creatorUsername.text = PFUser.currentUser()!.username
        postComment.text = photoComment
        postPhoto.image = photo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
