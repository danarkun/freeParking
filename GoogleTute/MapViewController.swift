//
//  ViewController.swift
//  GoogleTute
//
//  Created by Daniel Arkun on 2/02/2016.
//  Copyright © 2016 Daniel Arkun. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation? = nil // Create internal value to store location from didUpdateLocation to use in func showDirection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.cameraWithLatitude(-34.9290,
            longitude:138.6010, zoom:10)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        mapView.mapType = kGMSTypeNormal
        print("Calling addMarker")
        addMarker()
        // showingDirection(location)
        mapView.delegate = self
    }
    
    func addMarker() {
        let instanceOne = ParseViewController()
        let firstRow = instanceOne.returnParse()
        for (var i = 0; i < 114; i++) { // firstRow is entire tuple, iterate through and add markers. Need to find how to get length(firstRow)
            let element = firstRow[i]
            let position = CLLocationCoordinate2DMake((element.lat as NSString).doubleValue,(element.long as NSString).doubleValue)
            let marker = GMSMarker(position: position)
            // marker.title = "Free Park" // marker.title = element.timeZone
            marker.title = element.timeZone
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = mapView
        }
    }
    
    /* let instanceOne = ParseViewController() // Create ParseViewController instance to operate on
    let Coord = instanceOne.returnParse()
    // Create for loop to obtain coordinates for seperate markers then add said makers
    print("firstCoord")
    print((Coord.lat as NSString).doubleValue, (Coord.long as NSString).doubleValue)    // Check for right coords
    let position = CLLocationCoordinate2DMake((Coord.lat as NSString).doubleValue,(Coord.long as NSString).doubleValue) // Convert and pass in lat and long as double values
    let marker = GMSMarker(position: position)
    marker.title = "Free Park"
    marker.appearAnimation = kGMSMarkerAnimationPop
    marker.map = mapView
    } */
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.yellowColor()
        polyLine.map = mapView
        
    }
    
    /* @IBAction func showDirection(sender: AnyObject) {
        let userLoc = lastLocation
        let locValue: CLLocationCoordinate2D = (userLoc?.coordinate)!
        let userLat = locValue.latitude
        let userLong = locValue.longitude
        let instanceOne = ParseViewController() // Create ParseViewController instance to operate on
        let Coord = instanceOne.returnParse()
        // Create for-loop here to iterate through tuple and lenght(coords) markers
         let latitude = (Coord.lat as NSString)
        let longitude = (Coord.long as NSString)
        var urlString = "http://maps.google.com/maps?"
        urlString += "saddr= \(userLat), \(userLong)"
        urlString += "&daddr= \(latitude as String), \(longitude as String)" // Find how to get directions to closest park
        print(urlString)
        
        if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        {
            UIApplication.sharedApplication().openURL(url)
        }
    } */
    
    // Have a IBAction next button which takes you to next closest free park
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastLocation = location // Store user location in lastLocation variable to be used in func showDirection()
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
    }
}
