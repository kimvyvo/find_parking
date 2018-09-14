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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var lots = [ParkingLot]()
    var parkingLots = [NSDictionary]()
    
    
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
        fetchAllItems()
        fetchFromApi()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named:"pin")
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }

    func pinOnMap(){
        print(parkingLots)
        for i in 0..<parkingLots.count{
            let spot = MKPointAnnotation()
            print("pinMaps - \(parkingLots[i]["address"]! as! String)")
            spot.title = parkingLots[i]["address"]! as! String
            spot.coordinate = CLLocationCoordinate2D(latitude: parkingLots[i]["latitude"]! as! CLLocationDegrees, longitude: parkingLots[i]["longitude"]! as! CLLocationDegrees)
            mapView.addAnnotation(spot)
        }
        
    }
    
    func fetchFromApi(){
        let url = URL(string: "http://54.219.174.244/locations")
        // create a URLSession to handle the request tasks
        let session = URLSession.shared
        // create a "data task" to make the request and run the completion handler
        let task = session.dataTask(with: url!, completionHandler: {
            // see: Swift closure expression syntax
            data, response, error in
            do {
                // try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let results = jsonResult["data"] {
                        let resultsArray = results as! NSArray
                        for item in resultsArray {
                            let i = item as! NSDictionary
                            self.parkingLots.append(i)
                        }
                        // now we can run NSArray methods like count and firstObject
//                        print(resultsArray.value(forKey: "latitude"))
//                        print(resultsArray.value(forKey: "longitude"))
                        //                        print(resultsArray.value(forKey: "name"))
                        //                        self.people = resultsArray.value(forKey: "name") as! [String]
                        //                        print(resultsArray.firstObject)
//                        print(self.parkingLots.value(forKey: "address"))
                       
                        DispatchQueue.main.async {
                            self.pinOnMap()
                        }
                    }
                }
            } catch {
                print(error)
            }
        })
        // execute the task and wait for the response before
        // running the completion handler. This is async!
        task.resume()
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
        let itemRequest:NSFetchRequest<ParkingLot> = ParkingLot.fetchRequest()
        do {
            let fetchedThings = try context.fetch(itemRequest)
            lots = fetchedThings
        } catch {
            print("fetching errors")
        }
    }
    
    @IBAction func unwindToViewController(_ segue: UIStoryboardSegue) {
        let src = segue.source as! FormViewController
        let newParkingLot = ParkingLot(context: context)
        newParkingLot.address = src.addressTextField.text
        newParkingLot.totalSpots = Int64(src.totalSpotsTextField.text!)!
        newParkingLot.rate = src.rateTextField.text
        newParkingLot.contact = src.contactTextField.text
        newParkingLot.details = src.detailsTextField.text
        newParkingLot.isPublic = src.isPublicSwitch.isOn
        
        lots.append(newParkingLot)
        saveContext()
    }

}

