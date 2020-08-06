//
//  ViewController.swift
//  LiveLocation
//
//  Created by Rohit Saini on 04/08/20.
//  Copyright © 2020 AccessDenied. All rights reserved.
//

import UIKit
import CoreLocation
import SainiUtils

class ViewController: UIViewController {
    
    private var locationManager:CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        // Do any additional setup after loading the view.
    }
    
    func getUserLocation() {
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isLocationSaved)
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.showsBackgroundLocationIndicator = true
        locationManager?.startUpdatingLocation()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        
    }
    
}
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Getting latest location Regular
        if let location = locations.last{
            guard let isLocationSaved = UserDefaults.standard.value(forKey: UserDefaultsKeys.isLocationSaved) as? Bool else{
                return
            }
            //If Initial location is not saved
            if isLocationSaved == false{
                let location = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                UserDefaults.standard.set(encodable: location, forKey: "userLocation")
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isLocationSaved)
                UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.locationSavedDate)
            }
            //if initial location is already saved we don't need to save it again
            else{
                if let SavedLocation = UserDefaults.standard.get(Location.self, forKey: UserDefaultsKeys.userLocation){
                    log.success("\(SavedLocation.toJSON())")/
                    print(location)
                    if let savedDate = UserDefaults.standard.value(forKey: UserDefaultsKeys.locationSavedDate) as? Date{
                        let currentDate = Date()
                        let minGap = currentDate.sainiMinFrom(savedDate)
                        //Checking 15 min Gap
                        log.success("Gap##### : \(minGap)")/
                        if minGap >= 1{
                            //Calcuate Distance Range and Call Checkin Service
                            let currentCoordinate = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                            let savedCoordinate = CLLocation(latitude: SavedLocation.latitude, longitude: SavedLocation.longitude)
                            let distanceInMeters = currentCoordinate.distance(from: savedCoordinate)
                            log.success("Distance = \(distanceInMeters)")/
                            //Check for 100m radius
                            if distanceInMeters <= 100{
                                //Call API Service
                                log.success("\(distanceInMeters)")/
                            }
                            else{
                                log.success("\(distanceInMeters)")/
                            }
                           
                        }
                    }
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let slackUrl = URL(string: Slack.slackUrl)!
        let httpUtility = HttpUtility()
        do {
            let messageBody = try JSONEncoder().encode(Message(text: "\(error)"))
            httpUtility.postApiData(requestUrl: slackUrl, requestBody: messageBody, resultType: MessageResponse.self) { (response) in
                //todo handle reponse
                print(response)
            }
        }
        catch let error {
            print(error)
        }
    }
}



extension Date{
    
    //MARK:- sainiHoursFrom
    public func sainiMinFrom(_ date: Date) -> Double {
        return Double(Calendar.current.dateComponents([.minute], from: date, to: self).minute!)
    }
}
