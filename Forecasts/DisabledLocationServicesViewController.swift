//
//  DisabledLocationServicesViewController.swift
//  Forecasts
//
//  Created by Ryan Cortez on 8/2/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit

class DisabledLocationServicesViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var enableLocationServicesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableLocationServicesButton.titleLabel?.textAlignment = .Center
    }
    
    // MARK: - Actions
    
    @IBAction func enableLocationServicesButtonPressed(sender: AnyObject) {
        let url:NSURL! = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
