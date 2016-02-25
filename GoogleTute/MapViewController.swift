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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var sortedMarkerGlobal: [(lat: String, long: String)] = []
    var nextParkCount: Int = 1 // Used to iterate over sortedMarkers with nextPark IBAction button
    
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
    
    func closestMarker(userLat: Double, userLong: Double)-> [(lat: String, long: String)] { // Loops through and sorts all markers
        // from closest to furthest from user's current location
        
        /*
        var lengthRow = firstRow.count
        
        while (sortedMarkers.count != lengthRow) { // There are markers that haven't been added to sortedMarkers
        // Haversine formula
        // add nearest marker to sortedMarkers
        // Remove recently added marker from ParseViewControler() type tuple
        // Recurse until all markers are in sortedMarkers
        }
        */
        
        let markerToTest = ParseViewController()
        let firstRow = markerToTest.returnParse()
        let lat2 = degreesToRadians(userLat) // Nearest lat in radians
        let long2 = degreesToRadians(userLong) // Nearest long in radians
        
        let R = (6371).doubleValue // Radius of earth in km
        
        var closestLat: Double? = nil // Used to store the latitude of the closest marker
        var closestLong: Double? = nil // Used to store the longitude of the closest marker
        
        //
        var indexToDelete: Int = 0 // Used to delete the marker which has been added to sortedMarkers tuple
        let lengthRow = firstRow.count
        var latLongs: (String, String)
        var sortedMarkers: [(lat: String, long: String)] = []
        
        var dynamicRow = firstRow // Tuple that has markers deleted from it
        
        while (sortedMarkers.count != lengthRow) { // Store markers from closest to furtherst distance from user
                    var shortestDistance = 100.00E100
            for (var i = 0; i < dynamicRow.count; i++) {
                    let testMarker = dynamicRow[i]
                    let testLat = (testMarker.lat as NSString)
                    let testLong = (testMarker.long as NSString)
                    let doubleLat = Double(testLat as String)
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
                        indexToDelete = i// Keep updating index of closest marker to later be removed
                    }
                }
            latLongs = (String(closestLat!), String(closestLong!)) // Each time for loop will find closest marker ~ NOT WORKING ~
            sortedMarkers.append(latLongs)
            dynamicRow.removeAtIndex(indexToDelete) // Remove marker that has just been added
        }
        sortedMarkerGlobal = sortedMarkers
        return sortedMarkers
        
        //
        
        
        /* for (var i = 0; i < firstRow.count; i++) {
        
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
        print(doubleLat)
        closestLong = (doubleLong)
        print(doubleLong)
        shortestDistance = d
        }
        print("Closest distance: \(d)")
        
        }
        return (closestLat!, closestLong!) */
    }
    
    
    @IBAction func showDirection(sender: AnyObject) {
        let userLoc = lastLocation
        let locValue: CLLocationCoordinate2D = (userLoc?.coordinate)!
        let userLat = locValue.latitude
        let userLong = locValue.longitude
        let closestCoordsTuple = MapViewController()
        print("Passing in userLoc (lastLocation)")
        let closestCoords = closestCoordsTuple.closestMarker(userLat, userLong: userLong)[0] // First element in sortedMarkers
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
    
    @IBAction func nextPark(sender: AnyObject) { // Find next closest park ~ NEED to just be able to use sortedMarkerTuple instead
        // callign closestMarker() again (takes too long)
        print("nextPark")
        let userLoc = lastLocation
        let locValue: CLLocationCoordinate2D = (userLoc?.coordinate)!
        let userLat = locValue.latitude
        let userLong = locValue.longitude
        print("Passing in userLoc (lastLocation)")
        print("Second tuple count: ")
        print(sortedMarkerGlobal.count)
        let closestCoords = sortedMarkerGlobal[nextParkCount] // First element in sortedMarkers
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
        
        nextParkCount++
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
