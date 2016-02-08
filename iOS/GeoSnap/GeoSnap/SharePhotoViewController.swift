//
//  SharePhotoViewController.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

import UIKit

class SharePhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        imageView.image = image
        
//        saveImage(image)
    }
    
    @IBAction func share(sender: UIButton) {
    }
    
    
    @IBAction func cancelShare(sender: UIButton) {
    }
}
