//
//  ForecastsTests.swift
//  ForecastsTests
//
//  Created by Ryan Cortez on 8/2/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import XCTest
@testable import Forecasts

class ForecastsTests: XCTestCase {
    
    var storyboard: UIStoryboard!
    var weatherForecastViewController: WeatherForecastViewController!
    
    override func setUp() {
        super.setUp()
        let mainStoryboardName = "Main"
        self.storyboard = UIStoryboard(name: mainStoryboardName, bundle: NSBundle.mainBundle())
        let weatherForecastViewControllerReuseIdentifier = "WeatherForecastViewController"
        guard let controller = self.storyboard.instantiateViewControllerWithIdentifier(weatherForecastViewControllerReuseIdentifier) as?WeatherForecastViewController else {
        print("Could not convert UIViewController to WeatherForecastViewController")
        return
        }
        self.weatherForecastViewController = controller
    }
    
    override func tearDown() {
        super.tearDown()
    }
   
    func testIfUserLocationWasCaptured() {
        XCTAssertNotNil(weatherForecastViewController.currentLocation)
    }
    
}
