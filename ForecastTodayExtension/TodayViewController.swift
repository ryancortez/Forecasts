//
//  TodayViewController.swift
//  ForecastTodayExtension
//
//  Created by Ryan Cortez on 8/3/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var temperatureValueText: String?
    var weatherSummaryText: String?
    var windSpeedText: String?
    var humidityText: String?
    var visibilityText: String?

    
    // MARK: - Outlets
    @IBOutlet weak var tempertureValue: UILabel!
    @IBOutlet weak var windspeed: UILabel!
    @IBOutlet weak var visibility: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var weatherSummary: UILabel!
    
    // MARK: - Inital Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeatherFromPersistentStorage()
        updateTodayView()
    }
    
    func fetchWeatherFromPersistentStorage() {
        enum Keys: String {
            case currentWeather = "currently"
            case temperature = "temperature"
            case windspeed = "windSpeed"
            case visibilty = "visibility"
            case humidity = "humidity"
            case weatherSummary = "summary"
            case appGroupContainer = "group.ryancortez.Forecasts"
        }
        
        let userDefaults = NSUserDefaults(suiteName: Keys.appGroupContainer.rawValue)
        
        weatherSummaryText = userDefaults?.valueForKey(Keys.weatherSummary.rawValue) as? String
        temperatureValueText = userDefaults?.valueForKey(Keys.temperature.rawValue) as? String
        windSpeedText = userDefaults?.valueForKey(Keys.windspeed.rawValue) as? String
        humidityText = userDefaults?.valueForKey(Keys.humidity.rawValue) as? String
        visibilityText = userDefaults?.valueForKey(Keys.visibilty.rawValue) as? String
    }
    
    func updateTodayView() {
        
        tempertureValue.text = temperatureValueText
        weatherSummary.text = weatherSummaryText
        windspeed.text = windSpeedText
        humidity.text = humidityText
        visibility.text = visibilityText
    }
    
    
    // Remove left margin from the Today Widget
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets{
        return UIEdgeInsetsZero
    }
    
    // Perform any setup necessary in order to update the view
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        fetchWeatherFromPersistentStorage()
        updateTodayView()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    @IBAction func anyPartOfTheTodayWidgetPressed(sender: AnyObject) {
        
        guard let url = NSURL(string: "Forecasts://") else {
            print("Did not find a valid URL")
            return
        }
        self.extensionContext?.openURL(url, completionHandler: nil)
    }
    
}
