//
//  WeatherForecastViewController.swift
//  Forecasts
//
//  Created by Ryan Cortez on 8/2/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherForecastViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Global Variables
    
    var currentLocation: CLLocation?
    var weatherForecastData: Dictionary<String,AnyObject>?
    var locationManager = CLLocationManager()
    
    // MARK: - Enumerations
    
    enum Keys: String {
        case currentWeather = "currently"
        case temperature = "temperature"
        case windspeed = "windSpeed"
        case visibilty = "visibility"
        case humidity = "humidity"
        case weatherSummary = "summary"
        case appGroupContainer = "group.ryancortez.Forecasts"
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var temperatureTitle: UILabel!
    @IBOutlet weak var temperatureValue: UILabel!
    @IBOutlet weak var windspeed: UILabel!
    @IBOutlet weak var visibilty: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var weatherSummary: UILabel!
    
    // MARK: - Load Inital View
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserHasLocationServicesTurnedOnIfNotFirstLaunch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationServicesAuthorization()
        fetchCurrentLocation()
    }
    
    // MARK: Ensure Location Access
    
    func checkIfUserHasLocationServicesTurnedOnIfNotFirstLaunch() {
        if (isFirstLaunch() == false) {
            checkLocationServicesAuthorizationStatus()
        }
    }
    
    func isFirstLaunch() -> Bool {
        let launchedPreviously = NSUserDefaults.standardUserDefaults().boolForKey("launchedPreviously")
        if launchedPreviously {
            return false
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedPreviously")
            return true
        }
    }
    
    func checkLocationServicesAuthorizationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                // Location Services are not enabled
                displayDisabledLocationServicesViewController()
                break
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                // Location Services are enabled
                break
            }
        } else {
            // Location Services are not enabled
            displayDisabledLocationServicesViewController()
        }
    }
    
    func displayDisabledLocationServicesViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("DisabledLocationServicesViewController")
        self.presentViewController(vc, animated: true, completion: nil)
    }

    // MARK: Fetch Current Location
    
    func requestLocationServicesAuthorization() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    // When the user's location is updated save the location in a global variable
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            print("Did not find a CLLocation in CLLocationManger"); return
        }
        currentLocation = location
        
        if (currentLocation != nil) {
            locationManager.stopUpdatingLocation()
            fetchWeatherData(withLocation: currentLocation!)
        }
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Update UI
    
    func updateUI() {
        guard let data = weatherForecastData else {
            print("There is currently no saved weather forecast"); return
        }
        guard let currentWeatherData = data[Keys.currentWeather.rawValue] as? Dictionary<String,AnyObject> else {
            print("Did not find current weather data using key: \(Keys.currentWeather.rawValue)"); return
        }
        
        let weatherSummaryText = currentWeatherData[Keys.weatherSummary.rawValue] as? String
        let temperatureValueText = NSString(format: "%.1f", currentWeatherData[Keys.temperature.rawValue] as! Float) as String
        let windSpeedText = NSString(format: "Windspeed\n%.1f", currentWeatherData[Keys.windspeed.rawValue] as! Float) as String
        let humidityText = NSString(format: "Humidity\n%.1f", currentWeatherData[Keys.humidity.rawValue] as! Float) as String
        let visibiltyText = NSString(format: "Visibility\n%.0f", currentWeatherData[Keys.visibilty.rawValue] as! Float) as String
        
        weatherSummary.text = weatherSummaryText
        temperatureValue.text = temperatureValueText
        windspeed.text = windSpeedText
        humidity.text = humidityText
        visibilty.text = visibiltyText
    
        saveToPersistentStorage()
    }
    
    func saveToPersistentStorage() {
        let userDefaults = NSUserDefaults(suiteName: Keys.appGroupContainer.rawValue)
        userDefaults?.setObject(weatherSummary.text, forKey: Keys.weatherSummary.rawValue)
        userDefaults?.setObject(temperatureValue.text, forKey: Keys.temperature.rawValue)
        userDefaults?.setObject(windspeed.text, forKey: Keys.windspeed.rawValue)
        userDefaults?.setObject(humidity.text, forKey: Keys.humidity.rawValue)
        userDefaults?.setObject(visibilty.text, forKey: Keys.visibilty.rawValue)
        userDefaults?.synchronize()
    }
    
    // MARK: - Get Weather Forecast Data
    
    func fetchWeatherData(withLocation location: CLLocation) {
        let urlAsString = "https://api.forecast.io/forecast/ee590865b8cf07d544c96463ae5d47c5/\(location.coordinate.latitude),\(location.coordinate.longitude)"
        guard let url = NSURL(string: urlAsString) else {
            print("No url was created, \(urlAsString) was not a properly formatted URL"); return
        }
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url) { (data :NSData?, response :NSURLResponse?, error :NSError?) in
            
            guard let jsonData = data else {
                print("No data was found at URL: \(urlAsString)"); return
            }
            
            do {
                guard let dictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String,AnyObject> else {
                    print("Could not convert serialized JSON into Dictionary"); return
                }
                self.weatherForecastData = dictionary
            } catch {
                print("Unable to get Weather information from the JSON taken at the URL \(urlAsString)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                // Update UI
                self.updateUI()
            })
            }.resume()
    }
}

