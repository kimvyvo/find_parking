//
//  ViewController.swift
//  parking
//
//  Created by Kim Vy Vo on 9/13/18.
//  Copyright © 2018 Kim Vy Vo. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let lots = [ParkingLot]()
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext
    
    
    let regionRadius: CLLocationDistance = 1000
    
    var locationManager: CLLocationManager!
    
    
    @IBOutlet weak var mapView: MKMapView!
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var geocoder = CLGeocoder()
//        geocoder.geocodeAddressString("36895 Newark blvd, newark, ca 94560") {
//            placemarks, error in
//            var lat: CLLocationDegrees
//            var lon: CLLocationDegrees
//            let placemark = placemarks?.first
//            lat = (placemark?.location?.coordinate.latitude)!
//            lon = (placemark?.location?.coordinate.longitude)!
//            print("Lat: \(lat), Lon: \(lon)")
//            let initialLocation = CLLocation(latitude: lat, longitude: lon)
//            self.centerMapOnLocation(location: initialLocation)
        // Ask for Authorisation from the User.
        
//        }
        print("view did load")
        determineMyCurrentLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
//        print("user latitude = \(userLocation.coordinate.latitude)")
//        print("user longitude = \(userLocation.coordinate.longitude)")
        let initialLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        centerMapOnLocation(location: initialLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchAllItems() {
        // yeah
    }
    
    @IBAction func unwindToViewController(_ segue: UIStoryboardSegue) {
        let src = segue.source as! FormViewController
//        if sender.tag == 0 {
//            // cancel button pressed
//        } else if sender.tag == 1 {
//            // add button pressed
//        }
    }

}

