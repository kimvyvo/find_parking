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

class ViewController: UIViewController {
    
    var lots = [ParkingLot]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchAllItems() {
        let itemRequest:NSFetchRequest<ParkingLot> = ParkingLot.fetchRequest()
        do {
            let fetchedThings = try context.fetch(itemRequest)
            lots = fetchedThings
            print("lots from fetch: ", lots)
        } catch {
            print("fetch errors")
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
        print("lots from unwind: ", lots)
    }

}

