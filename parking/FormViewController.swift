//
//  FormViewController.swift
//  parking
//
//  Created by Kim Vy Vo on 9/13/18.
//  Copyright © 2018 Kim Vy Vo. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var totalSpotsTextField: UITextField!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var isPublicSwitch: UISwitch!
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
