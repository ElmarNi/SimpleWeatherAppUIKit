//
//  ViewController.swift
//  Weather
//
//  Created by Elmar Ibrahimli on 27.04.23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var stackView = UIStackView();
    var labelForTemp = UILabel();
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        labelForTemp.font = .boldSystemFont(ofSize: 20)
        stackView.addSubview(labelForTemp)
        stackView.addSubview(imageView)
        view.addSubview(stackView)
        
        constraintsForStackView()
        constraintsForLabelView()
        constraintsForImageView()
        view.backgroundColor = UIColor(red: 191 / 255.0, green: 205 / 255.0, blue: 224 / 255.0, alpha: 1.0)
        
    }
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
            }
        }).resume()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    func constraintsForStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2).isActive = true
    }
    
    func constraintsForLabelView() {
        labelForTemp.translatesAutoresizingMaskIntoConstraints = false
        labelForTemp.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        labelForTemp.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive = true
    }
    
    func constraintsForImageView(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10).isActive = true
        imageView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.bottomAnchor.constraint(equalTo: labelForTemp.topAnchor, constant: -30).isActive = true
        imageView.contentMode = .scaleAspectFill
    }
    
    
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty && currentLocation == nil{
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
            
        }
    }
    
    func requestWeatherForLocation(){
        guard let currentLocation = currentLocation else { return }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let url = "https://api.weatherapi.com/v1/current.json?key=021d10c213074e2293c135552232704&q=\(lat),\(long)"
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else { return }
            var json: WeatherResponse?
            do{
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch{
                print(error)
                return
            }
            guard let result = json else { return }
            DispatchQueue.main.async {
                self.labelForTemp.text = "\(result.current.temp_c)°C"
                
                URLSession.shared.dataTask(with: URL(string: "https:\(result.current.condition.icon)")!, completionHandler: { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() { [weak self] in
                        self?.imageView.image = UIImage(data: data)
                    }
                }).resume()
            }
        }).resume()
    }
    
    struct WeatherResponse:Codable{
        let location: Location
        let current: Current

    }
    struct Location:Codable{
        let name: String
        let region: String
        let country: String
        let lat: Float
        let lon: Float
        let tz_id: String
        let localtime_epoch: Int
        let localtime: String
    }
    struct Current:Codable{
        let last_updated_epoch: Int
        let last_updated: String
        let temp_c: Float
        let temp_f: Float
        let is_day: Int
        let condition: Condition
        let wind_mph: Float
        let wind_kph: Float
        let wind_degree: Int
        let wind_dir: String
        let pressure_mb: Float
        let pressure_in: Float
        let precip_mm: Float
        let precip_in: Float
        let humidity: Int
        let cloud: Int
        let feelslike_c: Float
        let feelslike_f: Float
        let vis_km: Float
        let vis_miles: Float
        let uv: Float
        let gust_mph: Float
        let gust_kph: Float
    }
    struct Condition:Codable{
        let text: String
        let icon: String
        let code: Int
    }
}

