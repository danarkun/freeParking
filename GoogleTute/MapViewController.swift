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
import SwiftCSV
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
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
    
    func addMarker() {  // Find out how to call in viewDidLoad, marker shows if implementaion is copied into DidLoad
        let instanceOne = ParseViewController() // Create ParseViewController instance to operate on
        let Coord = instanceOne.returnParse()
        print("firstCoord")
        print((Coord.lat as NSString).doubleValue, (Coord.long as NSString).doubleValue)    // Check for right coords
        let position = CLLocationCoordinate2DMake((Coord.lat as NSString).doubleValue,(Coord.long as NSString).doubleValue) // Convert and pass in lat and long as double values
        let marker = GMSMarker(position: position)
        marker.title = "Free Park"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
    }
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.yellowColor()
        polyLine.map = mapView
        
    }
    
    @IBAction func showDirection(sender: AnyObject) {
        print("Running showDirection")
        let instanceOne = ParseViewController() // Create ParseViewController instance to operate on
        print("Created ParseView instance")
        let Coord = instanceOne.returnParse()
        print("firstCoord")
        // Create for-loop here to iterate through tuple and lenght(coords) markers
        let latitude = (Coord.lat as NSString)
        let longitude = (Coord.long as NSString)
        var urlString = "http://maps.google.com/maps?"
        urlString += "saddr= -34.9290, 138.6010"
        urlString += "&daddr= \(latitude as String), \(longitude as String)"
        print(urlString)
        
        if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    func showingDirection(userLat: Double, userLong: Double) {
        print("Running showDirection")
        let instanceOne = ParseViewController() // Create ParseViewController instance to operate on
        print("Created ParseView instance")
        let Coord = instanceOne.returnParse()
        print("firstCoord")
        // Create for-loop here to iterate through tuple and lenght(coords) markers
        let latitude = (Coord.lat as NSString)
        let longitude = (Coord.long as NSString)
        var urlString = "http://maps.google.com/maps?"
        urlString += "saddr= \(userLat), \(userLong)"
        urlString += "&daddr= \(latitude as String), \(longitude as String)"
        print(urlString)
        
        if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
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
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            var locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
            print("Coordinates = \(locValue.latitude), \(locValue.longitude)")
            locationManager.stopUpdatingLocation()
            showingDirection(locValue.latitude, userLong: locValue.longitude)
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
    }
}


