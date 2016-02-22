//
//  FirstViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 01/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Add map display - Does it add a lot to the user experience or is it just aesthetic?
// TODO: Find out why it sometimes shows an extra default image

import UIKit
import Parse

class HomeViewController: ViewControllerParent, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct Post {
        var postInformation: PFObject
        var photo: UIImage
    }

    @IBOutlet var imageCollectionView: UICollectionView!
    
    var spinner = UIActivityIndicatorView()
    
    var refreshControl: UIRefreshControl!
    var postsAtLocation = [Post]()
    
    var shouldGetNewPosts = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:",   forControlEvents: UIControlEvents.ValueChanged)
        imageCollectionView!.addSubview(refreshControl)
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        super.displaySpinner(spinner)
    }
    
    
    override func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if shouldGetNewPosts {
            print("Getting posts for location")
            retrievePostsForLocation()
            GetFlickrData()
        }
        shouldGetNewPosts = false
    }
    
    
    func refresh(sender:AnyObject) {
        // Empty arrays so we do not get duplicates
        postsAtLocation.removeAll()
        retrievePostsForLocation()
        refreshControl?.endRefreshing()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func retrievePostsForLocation() {
        if let coords = locationManager.location?.coordinate {
            let userLocation = PFGeoPoint(latitude: coords.latitude, longitude: coords.longitude)
            
            let query = PFQuery(className: "Post")
            query.whereKey("location", nearGeoPoint: userLocation, withinMiles: 0.1)
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock { (posts, error) in
                if (posts != nil) {
                    var index = 0
                    for returnedPost in posts! {
                        let newPost = Post(postInformation: returnedPost, photo: UIImage(named: "polaroid.pdf")!)
                        
                        self.postsAtLocation.append(newPost)
                        self.imageCollectionView.reloadData()
                        self.getImageForPost(index)
                        index+=1
                    }
                } else {
                    self.displayAlert("No photos for location.", message: "There are currently no photos for the current location. Why not be the first to share one?")
                }
            }
        } else {
            displayAlert("Could not find location", message: "Refresh by pulling down to try again.")
        }
        
        super.stopSpinner(spinner)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsAtLocation.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.image = self.postsAtLocation[indexPath.row].photo
        
        return cell
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("viewPost", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "viewPost" {
            let indexPaths = self.imageCollectionView.indexPathsForSelectedItems()!
            let indexPath = indexPaths.first! as NSIndexPath
            
            let post = self.postsAtLocation[indexPath.row]
            
            let viewPhotoViewController = (segue.destinationViewController as! ViewPhotoViewController)
            viewPhotoViewController.postId = post.postInformation.objectId!
        }
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
    
    func GetFlickrData() {
        let coords = locationManager.location?.coordinate
        
        // https://www.flickr.com/services/api/flickr.photos.search.html
        let baseURL = "https://api.flickr.com/services/rest/?&method=flickr.photos.search"
        let apiString = "&api_key=ad451e2f60097f08356235f79adbbe36"
        let format = "&format=json&nojsoncallback=1"
        let lat = "&lat=\(coords!.latitude)"
        let lon = "&lon=\(coords!.longitude)"
        let radius = "&radius=\(0.1)"
        let sort = "&sort=date-posted-desc"
        let extras = "&extras=date_taken,url_l"
        
        let requestURL = NSURL(string: baseURL + apiString + format + radius + lat + lon + sort + extras)!
        let session = NSURLSession.sharedSession()
        print(requestURL)
        
        let task = session.dataTaskWithURL(requestURL) { (data, response, error) in
            if let urlContent = data {
                self.parseJSON(urlContent)
            }
        }
        
        task.resume()
    }
    
    func parseJSON(json: NSData) {
        /*
         id: "18091064190",
         owner: "93509856@N05",
         secret: "0bc2732254",
         server: "8839",
         farm: 9,
         title: "DSC08942",
         ispublic: 1,
         isfriend: 0,
         isfamily: 0,
         datetaken: "2015-05-30 07:14:18",
         datetakengranularity: "0",
         datetakenunknown: "0",
         url_l: "https://farm9.staticflickr.com/8839/18091064190_0bc2732254_b.jpg",
         height_l: "683",
         width_l: "1024"
         */
        
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.MutableContainers)
//            print(jsonResult["id"])
            
            guard let photo = jsonResult["id"] as String where
                print(photo["id"])
            else {
                print("error")
            }
            
        } catch {
            print("Unable to serialize JSON.")
        }
        
        
    }
}

