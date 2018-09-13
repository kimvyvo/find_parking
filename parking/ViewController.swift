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
    
    let lots = [ParkingLot]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext

    override func viewDidLoad() {
        super.viewDidLoad()
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

