//
//  FirstViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 01/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Reload collection view at index, not all of it
// TODO: GetInBackground does not guarantee return order. Need to order images manually.
// TODO: Placeholder image while loading
// TODO: Add map display

import UIKit
import Parse

struct Post {
    var postInformation = PFObject()
    var photo = UIImage()
}

class HomeViewController: ViewControllerParent, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var imageCollectionView: UICollectionView!
    
    var refreshControl: UIRefreshControl!
    var postsAtLocation = [Post]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:",   forControlEvents: UIControlEvents.ValueChanged)
        imageCollectionView!.addSubview(refreshControl)
        
        retrievePostsForLocation()
    }
    
    func refresh(sender:AnyObject) {
        // Empty arrays so we do not get duplicates
        postsAtLocation = [Post]()
        
        retrievePostsForLocation()
        
        refreshControl?.endRefreshing()
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
                var index = 0
                for returnedPost in posts! {
                    let newPost = Post(postInformation: returnedPost, photo: UIImage(named: "polaroid.pdf")!)
                    
                    self.postsAtLocation.append(newPost)
                    self.getImageForPost(index)
                    index+=1
                }
            } else {
                self.displayAlert("No photos for location.", message: "There are currently no photos for the current location. Why not be the first to share one?")
            }
            
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsAtLocation.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.image = self.postsAtLocation[indexPath.row].photo
        
        return cell
    }


    
    func getImageForPost(index: Int) {
        var post = postsAtLocation[index]
        let userImageFile = post.postInformation["photo"] as! PFFile
        
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    post.photo = UIImage(data:imageData)!
                } else {
                    post.photo = UIImage(named: "polaroid.pdf")!
                }
                
                self.postsAtLocation[index] = post
                self.imageCollectionView.reloadData()
            }
        }
        
    }
}

