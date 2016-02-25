//
//  ViewController.swift
//  GoogleTute
//
//  Created by Daniel Arkun on 2/02/2016.
//  Copyright © 2016 Daniel Arkun. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

var sortedMarkerGlobal: [(lat: String, long: String, timeZone: String)] = []
var indexToDelete: Int = 0 // Used to delete the marker which has been added to sortedMarkers tuple

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation? = nil // Create internal value to store location from didUpdateLocation to use in func showDirection()
    var isAnimating: Bool = false
    var dropDownViewIsDisplayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Drop down menu
        var height: CGFloat  = self.dropDownView.frame.size.height
        CGFloat(width) = 100
        */
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.cameraWithLatitude(-34.9290,
            longitude:138.6010, zoom:10)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        mapView.mapType = kGMSTypeNormal
        print("Calling addMarker")
        addMarker()
        mapView.delegate = self
    }
    
    func addMarker() {
        let instanceOne = ParseViewController()
        let firstRow = instanceOne.returnParse()
        print(firstRow.count)
        for (var i = 0; i < firstRow.count; i++) { // firstRow is entire tuple, iterate through and add markers. Need to find how to get length(firstRow)
            let element = firstRow[i]
            let position = CLLocationCoordinate2DMake((element.lat as NSString).doubleValue,(element.long as NSString).doubleValue)
            let marker = GMSMarker(position: position)
            marker.title = element.timeZone
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = mapView
        }
    }
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.yellowColor()
        polyLine.map = mapView
        
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.00 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.00 * M_PI }
    
    func closestMarker(userLat: Double, userLong: Double)-> (lat: Double, long: Double) { // Finds the closest marker to the user's location
        indexToDelete = 0 // Ensure that the correct marker is deleted via its index
        let markerToTest = ParseViewController()
        let firstRow = markerToTest.returnParse()
        let lat2 = degreesToRadians(userLat) // Nearest lat in radians
        let long2 = degreesToRadians(userLong) // Nearest long in radians
        let R = (6371).doubleValue // Radius of earth in km
        
        var closestLat: Double? = nil // Used to store the latitude of the closest marker
        var closestLong: Double? = nil // Used to store the longitude of the closest marker
        var dynamicRow = firstRow // Used to reset sortedMarkerGlobal to the original tuple
        var shortestDistance = 100.00E100
        
        for (var i = 0; i < firstRow.count; i++) {
            
            let testMarker = firstRow[i]
            let testLat = (testMarker.lat as NSString)
            let doubleLat = Double(testLat as String)
            let testLong = (testMarker.long as NSString)
            let doubleLong = Double(testLong as String)
            let lat1 = degreesToRadians(doubleLat!)
            let long1 = degreesToRadians(doubleLong!)
            
            let dLat = lat2 - lat1
            let dLong = long2 - long1
            
            let a = ((sin((dLat)/2)) * (sin((dLat)/2))) + (cos(lat1)*cos(lat2)*((sin((dLong)/2)) * (sin((dLong)/2))))
            let b = sqrt(a)
            let d = (2*R) * (asin(b)) // Haversine formula
            
            if (d < shortestDistance) {
                closestLat = (doubleLat)
                closestLong = (doubleLong)
                shortestDistance = d
                indexToDelete = i
            }
        }
        dynamicRow.removeAtIndex(indexToDelete)
        sortedMarkerGlobal = dynamicRow // Only used on initial find marker
        return (closestLat!, closestLong!)
    }
    
    func closestMarkerIndexed(userLat: Double, userLong: Double)-> (lat: Double, long: Double) { // Determines closest marker from modified
        // tuple (sortedMarkerGlobal). Everytime this is called, the most recent closest marker is removed from the tuple
        // to be able to find the next closest (so it doesn't keep returning the same marker)
        
        let lat2 = degreesToRadians(userLat) // Nearest lat in radians
        let long2 = degreesToRadians(userLong) // Nearest long in radians
        let R = (6371).doubleValue // Radius of earth in km

        var closestLat: Double? = nil // Used to store the latitude of the closest marker
        var closestLong: Double? = nil // Used to store the longitude of the closest marker
        var indexToDelete: Int = 0 // Used to delete the marker which has been added to sortedMarkers tuple
        var shortestDistance = 100.00E100
        var i = 0
        
        for (i = 0; i < sortedMarkerGlobal.count; i++) {
            
            let testMarker = sortedMarkerGlobal[i]
            let testLat = (testMarker.lat as NSString)
            let doubleLat = Double(testLat as String)
            let testLong = (testMarker.long as NSString)
            let doubleLong = Double(testLong as String)
            let lat1 = degreesToRadians(doubleLat!)
            let long1 = degreesToRadians(doubleLong!)
            
            let dLat = lat2 - lat1
            let dLong = long2 - long1
            
            let a = ((sin((dLat)/2)) * (sin((dLat)/2))) + (cos(lat1)*cos(lat2)*((sin((dLong)/2)) * (sin((dLong)/2))))
            let b = sqrt(a)
            let d = (2*R) * (asin(b)) // Haversine formula
            
            if (d < shortestDistance) {
                closestLat = (doubleLat)
                closestLong = (doubleLong)
                shortestDistance = d
                indexToDelete = i
            }
            
        }
        sortedMarkerGlobal.removeAtIndex(indexToDelete)
        return (closestLat!, closestLong!)
    }
    
    @IBAction func showDirection(sender: UIButton?) {
        print("showDirection called")
        let userLoc = lastLocation
        let locValue: CLLocationCoordinate2D = (userLoc?.coordinate)!
        let userLat = locValue.latitude
        let userLong = locValue.longitude
        let closestCoordsTuple = MapViewController()
        let closestCoords = closestCoordsTuple.closestMarker(userLat, userLong: userLong) // First element in sortedMarkers
        let closestLatitude = closestCoords.0 // Set this to latitude returned from closestCoords
        let closestLongitude = closestCoords.1 // Set this to longitude returned from closestCoords
        var urlString = "http://maps.google.com/maps?"
        urlString += "saddr= \(userLat), \(userLong)" // Change user lat and long to returned values from shortestDistance
        urlString += "&daddr= \(closestLatitude), \(closestLongitude)" // Find how to get directions to closest park
        print(urlString)
        
        if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func nextPark(sender: AnyObject) {
        print("nextPark")
        if (sortedMarkerGlobal.count == 0) { // Incase sortedMarkerGlobal hasn't been instantiated from initial showDirection()
            showDirection(nil)
        }
        else {
        let userLoc = lastLocation
        let locValue: CLLocationCoordinate2D = (userLoc?.coordinate)!
        let userLat = locValue.latitude
        let userLong = locValue.longitude
        print("sortedMarkerGlobal in nextPark: ")
        print(sortedMarkerGlobal.count)
        let closestCoordsTuple = MapViewController()
        let closestCoords = closestCoordsTuple.closestMarkerIndexed(userLat, userLong: userLong) // First element in sortedMarkerIndexed
        print("Finished calling closestMarker")
        let closestLatitude = closestCoords.0 // Set this to latitude returned from closestCoords
        let closestLongitude = closestCoords.1 // Set this to longitude returned from closestCoords
        var urlString = "http://maps.google.com/maps?"
        urlString += "saddr= \(userLat), \(userLong)" // Change user lat and long to returned values from shortestDistance
        urlString += "&daddr= \(closestLatitude), \(closestLongitude)" // Find how to get directions to closest park
        print(urlString)
        
        if let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        {
            UIApplication.sharedApplication().openURL(url)
            }
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
