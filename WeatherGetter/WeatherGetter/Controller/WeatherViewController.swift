//
//  WeatherViewController.swift
//  WeatherGetter
//
//  Created by Guilherme Mello on 15/10/23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherTemperature: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var wallpaperImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var conditionLabel: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()
    }
    
    //MARK: - IBAction Methods
    @IBAction func getLocationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        textField.endEditing(true)
    }
}
    
//MARK: - Class Extension and UITextFieldDelagate Methods
extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Get user input
        if let city = textField.text {
            weatherManager.fetchWeather(for: city)
        }
        
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
 
//MARK: - Class Extension and WeatherManager Delegate Methods
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherIcon.image = UIImage(systemName: weather.conditionName)
            self.weatherTemperature.text = weather.temperatureString
            self.locationName.text = weather.cityName
            self.conditionLabel.text = weather.description
        }
    }
    
    func didFailWithError(_ weatherManager: WeatherManager, error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: - CLLocationManagerDelegate Methods
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

