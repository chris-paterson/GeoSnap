//
//  ViewControllerParent.swift
//  GeoSnap
//
//  Created by Christopher Paterson on 08/02/2016.
//  Copyright © 2016 Christopher Paterson. All rights reserved.
//

// TODO: Permission checks (Location and camera)
// TODO: Offline checks - Ensure good messages when offline and that everything works.


import UIKit
import CoreLocation

class ViewControllerParent: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locationManager.stopUpdatingLocation()
//        print("updating location")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("Error with location: " + error.localizedDescription)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displaySpinner(spinner: UIActivityIndicatorView) {
        spinner.center = self.view.center
        spinner.activityIndicatorViewStyle = .Gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func stopSpinner(spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
    }
    
    func humanReadableDate(createdAt: NSDate) -> (String, String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd'/'MM'/'yyyy'"
        let date = dateFormatter.stringFromDate(createdAt)
        
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.stringFromDate(createdAt)
        
        return (date, time)
    }
}