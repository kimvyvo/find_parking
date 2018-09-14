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
    
    @IBOutlet weak var map: MKMapView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext
    
    
    let regionRadius: CLLocationDistance = 1000
    
    var locationManager: CLLocationManager!
    
    let manager = CLLocationManager()
    
    
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
        mapView.delegate = self
        
        determineMyCurrentLocation()
        fetchAllItems()
        fetchFromApi()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            // good
        } else if annotation is MKUserLocation {
            let pin = map.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            let pinImage = UIImage(named: "mycar")
            let size = CGSize(width: 70, height: 70)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            pin.image = resizedImage
            return pin
        } else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        let pinImage = UIImage(named: "pin")
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.image = resizedImage
            annotationView!.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("tapped...")
        print(view.annotation?.subtitle)
        UIApplication.shared.openURL(NSURL(string: "tel://0000000000") as! URL) 
    }
    
    func pinOnMap(){
        print(parkingLots)
        for i in 0..<parkingLots.count{
            let spot = MKPointAnnotation()
            // print("pinMaps - \(parkingLots[i]["address"]! as! String)")
            spot.title = parkingLots[i]["address"]! as? String
            var isPublic: String = "N/A"
            if parkingLots[i]["isPublic"]! as! Int == 1 {
                isPublic = "Yes"
            } else {
                isPublic = "No"
            }
            spot.subtitle = "Spots: \(parkingLots[i]["num_spots"]!), Contact: \(parkingLots[i]["contact"]!), Rate: $\(parkingLots[i]["rate"]!)/hr"
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
//        let userLocation: CLLocation = locations[0] as CLLocation
//
//        // Call stopUpdatingLocation() to stop listening for location updates,
//        // other wise this function will be called every time when user location changes.
//
//        // manager.stopUpdatingLocation()
//
////        print("user latitude = \(userLocation.coordinate.latitude)")
////        print("user longitude = \(userLocation.coordinate.longitude)")
//        let initialLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
//        centerMapOnLocation(location: initialLocation)
        
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        
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
       
        var geocoder = CLGeocoder()
        var lat = CLLocationDegrees()
        var lon = CLLocationDegrees()
        geocoder.geocodeAddressString(src.addressTextField.text!) {
            placemarks, error in
            let placemark = placemarks?.first
            
            lat = (placemark?.location?.coordinate.latitude)!
            lon = (placemark?.location?.coordinate.longitude)!
            //            print("Lat: \(lat), Lon: \(lon)")
            let initialLocation = CLLocation(latitude: lat, longitude: lon)
            self.centerMapOnLocation(location: initialLocation)
            // Ask for Authorisation from the User.
            // print("first... Lat: \(lat), Lon: \(lon)")
            newParkingLot.address = src.addressTextField.text
            newParkingLot.totalSpots = Int64(src.totalSpotsTextField.text!)!
            newParkingLot.rate = src.rateTextField.text
            newParkingLot.contact = src.contactTextField.text
            newParkingLot.details = src.detailsTextField.text
            newParkingLot.isPublic = src.isPublicSwitch.isOn
            
            let parameters = ["address": newParkingLot.address, "num_spots": newParkingLot.totalSpots, "rate": newParkingLot.rate, "contact":newParkingLot.contact, "details": newParkingLot.details, "isPublic": newParkingLot.isPublic, "latitude":lat, "longitude": lon] as [String : Any]
            
            //create the url with URL
            let url = URL(string: "http://54.219.174.244/locations")! //change the url
            
            //create the session object
            let session = URLSession.shared
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                        // handle json...
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                self.fetchFromApi()
            })
            task.resume()
            
            
            
            self.lots.append(newParkingLot)
        }
        
        saveContext()
    }

}

