//
//  FirstViewController.swift
//  Geo Snap
//
//  Created by Christopher Paterson on 01/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Add map display - Does it add a lot to the user experience or is it just aesthetic?
// TODO: Currently updating collection view on main thread for flickr (else all things show up at once) which blocks clicking.
// TODO: Refreshing still kind of messed up.
// TODO: THUMBNAILS

import UIKit
import Parse
import Foundation

enum PostSource: String {
    case GeoSnap = "Geo Snap"
    case Flickr = "Flickr"
}

class HomeViewController: ViewControllerParent, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct Post {
        var postInformation: PFObject
        var photo: UIImage
    }

    @IBOutlet var imageCollectionView: UICollectionView!
    
    var spinner = UIActivityIndicatorView()
    
    var refreshControl: UIRefreshControl!
    var geoSnapPostsAtLocation = [Post]()
    var flickrPostsAtLocation = [Post]()
    
    var shouldGetNewPosts = true
    var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        imageCollectionView!.addSubview(refreshControl)
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        super.displaySpinner(spinner)
    }
    
    
    override func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if shouldGetNewPosts {
            retrievePostsForLocation()
        }
        
        shouldGetNewPosts = false
    }
    
    
    func refresh(sender:AnyObject) {
        // Empty arrays so we do not get duplicates
        isRefreshing = true
        
        geoSnapPostsAtLocation.removeAll()
        flickrPostsAtLocation.removeAll()
        
        retrievePostsForLocation()
        refreshControl?.endRefreshing()
        isRefreshing = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func retrievePostsForLocation() {
        if let coords = locationManager.location?.coordinate {
            let userLocation = PFGeoPoint(latitude: coords.latitude, longitude: coords.longitude)
            
            let query = PFQuery(className: "Post")
            query.whereKey("location", nearGeoPoint: userLocation, withinMiles: 0.05)
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock { (posts, error) in
                if (posts != nil) {
                    var index = 0
                    for returnedPost in posts! {
                        let newPost = Post(postInformation: returnedPost, photo: UIImage(named: "polaroid.pdf")!)
                        self.geoSnapPostsAtLocation.append(newPost)
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
        
        getFlickrData()
        super.stopSpinner(spinner)
    }
    
    
    func getImageForPost(index: Int) {
        var post = geoSnapPostsAtLocation[index]
        if let userImageFile = post.postInformation["thumbnail"] as? PFFile {
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        post.photo = UIImage(data:imageData)!
                    } else {
                        post.photo = UIImage(named: "polaroid.pdf")!
                    }
                    
                    self.geoSnapPostsAtLocation[index] = post
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return geoSnapPostsAtLocation.count
        case 1:
            return flickrPostsAtLocation.count
        default:
            return 0
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        if let post = getCorrectPost(indexPath) {
            cell.imageView.image = post.photo
        }
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("viewPost", sender: self)
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView: PostsCollectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! PostsCollectionHeaderView
        
        switch indexPath.section {
        case 0:
            headerView.header.text = PostSource.GeoSnap.rawValue
        case 1:
            headerView.header.text = PostSource.Flickr.rawValue
        default:
            headerView.header.text = ""
        }
        
        return headerView
    }
    
    func getCorrectPost(indexPath: NSIndexPath) -> Post? {
        var post: Post?
        if indexPath.section == 0 {
            if geoSnapPostsAtLocation.count > 0 {
                post = geoSnapPostsAtLocation[indexPath.row]
            }
        } else {
            if flickrPostsAtLocation.count > 0 {
                post = flickrPostsAtLocation[indexPath.row]
            }
        }
        
        return post
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "viewPost" {
            let viewPhotoViewController = (segue.destinationViewController as! ViewPhotoViewController)
            let indexPaths = self.imageCollectionView.indexPathsForSelectedItems()!
            let indexPath = indexPaths.first! as NSIndexPath
            
            var post: Post?
            
            switch indexPath.section {
            case 0:
                post = self.geoSnapPostsAtLocation[indexPath.row]
                viewPhotoViewController.postSource = PostSource.GeoSnap
                viewPhotoViewController.postId = post!.postInformation.objectId!
                viewPhotoViewController.photo = post!.photo
            case 1:
                post = self.flickrPostsAtLocation[indexPath.row]
                viewPhotoViewController.postId = post!.postInformation["objectId"] as! String
                viewPhotoViewController.postSource = PostSource.Flickr
                viewPhotoViewController.photo = post!.photo
            default: // Should never happen
                print("Error: No post found")
            }
        }
    }
    
    
    func getFlickrData() {
        let coords = locationManager.location?.coordinate
        
        // https://www.flickr.com/services/api/flickr.photos.search.html
        let baseURL = "https://api.flickr.com/services/rest/?&method=flickr.photos.search"
        let apiString = "&api_key=ad451e2f60097f08356235f79adbbe36"
        let format = "&format=json&nojsoncallback=1"
        let lat = "&lat=\(coords!.latitude)"
        let lon = "&lon=\(coords!.longitude)"
        let radius = "&radius=\(0.05)"
        let sort = "&sort=date-posted-desc"
        let extras = "&extras=date_taken,url_l"
        
        let requestURL = NSURL(string: baseURL + apiString + format + radius + lat + lon + sort + extras)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(requestURL) { (data, response, error) in
            if let urlContent = data {
                self.processFlickrData(urlContent)
            }
        }
        
        task.resume()
    }
    
    
    func processFlickrData(data: NSData) {
        /*
             {
                 datetaken = "2015-05-30 07:14:18";
                 datetakengranularity = 0;
                 datetakenunknown = 0;
                 farm = 9;
                 "height_l" = 683;
                 id = 18091064190;
                 isfamily = 0;
                 isfriend = 0;
                 ispublic = 1;
                 owner = "93509856@N05";
                 secret = 0bc2732254;
                 server = 8839;
                 title = DSC08942;
                 "url_l" = "https://farm9.staticflickr.com/8839/18091064190_0bc2732254_b.jpg";
                 "width_l" = 1024;
             },
         */
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            let photos = jsonResult.valueForKey("photos")
            let photo = photos?.valueForKey("photo")
            
            var flickrPhotosForLocation = photo as AnyObject! as! NSArray
            
            // Filter out nil urls as they are useless to us.
            flickrPhotosForLocation = flickrPhotosForLocation.filter() { $0.valueForKey!("url_l") !== nil }
            
            flickrPostsAtLocation.removeAll()
            // Add entries to array to preserve desc date order
            for photoEntry in flickrPhotosForLocation {
                if !isRefreshing {
                    let postInformation = PFObject(className: "postInformation")
                    postInformation["date"] = photoEntry.valueForKey("datetaken")
                    postInformation["objectId"] = photoEntry.valueForKey("id")
                    postInformation["url"] = photoEntry.valueForKey("url_l")
                    
                    let placeholderPhoto = UIImage(named: "polaroid.pdf")!
                    
                    let index = flickrPostsAtLocation.count
                    let post = Post(postInformation: postInformation, photo: placeholderPhoto)
                    flickrPostsAtLocation.append(post)
                    
                    getFlickrImageForPost(index)
                } else {
                    break
                }
            }
        } catch {
            print("Unable to serialize JSON.")
        }
    }
    
    
    func getFlickrImageForPost(index: Int) {
        if !isRefreshing {
            let urlString = flickrPostsAtLocation[index].postInformation["url"] as! String
            let url = NSURL(string: urlString)
            let data = NSData(contentsOfURL: url!)
            
            let photo = UIImage(data: data!)!
            if index < flickrPostsAtLocation.count {
                flickrPostsAtLocation[index].photo = photo
            }
            
            // This way loads in the images as soon as they come in instead of all at once.
            dispatch_async(dispatch_get_main_queue(), {
                self.imageCollectionView.reloadData()
            })
        }
    }
}

