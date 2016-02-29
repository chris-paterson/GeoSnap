//
//  FullscreenPhoto.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 29/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit

class FullscreenPhotoViewController: UIViewController {

    @IBOutlet weak var fullscreenImage: UIImageView!
    
    var photo: UIImage = UIImage(named: "polaroid.pdf")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullscreenImage.image = photo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
