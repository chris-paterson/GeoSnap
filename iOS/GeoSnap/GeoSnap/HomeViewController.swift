//
//  FirstViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 01/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

//TODO: Reload collection view at index, not all of it
//TODO: Pull to refresh
//TODO: Change layout
//TODO: Add map display

import UIKit
import Parse

class HomeViewController: ViewControllerParent, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var postsAtLocation = [PFObject]()
    var imagesAtLocation = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrievePostsForLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func retrievePostsForLocation() {
        let coords = locationManager.location?.coordinate
        let userLocation = PFGeoPoint(latitude: coords!.latitude, longitude: coords!.longitude)
        
        let query = PFQuery(className: "Post")
        query.whereKey("location", nearGeoPoint: userLocation, withinMiles: 0.1)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (posts, error) in
            if (posts != nil) {
                self.postsAtLocation = posts!
                self.getImages()
            } else {
                // TODO: Alert users no images at current location
            }
            
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesAtLocation.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = self.imagesAtLocation[indexPath.row]
        
        return cell
    }

    
    func getImages() {
        for post in postsAtLocation {
            let userImageFile = post["photo"] as! PFFile
            
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.imagesAtLocation.append(UIImage(data:imageData)!)
                    } else {
                        self.imagesAtLocation.append(UIImage(named: "polaroid.pdf")!)
                    }
                }
                
                self.imageCollectionView.reloadData()
            }
        }
        
    }


}

