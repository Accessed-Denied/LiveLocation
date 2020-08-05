//
//  ViewController.swift
//  LiveLocation
//
//  Created by Rohit Saini on 04/08/20.
//  Copyright © 2020 AccessDenied. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    private var locationManager:CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        // Do any additional setup after loading the view.
    }
    
    func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.showsBackgroundLocationIndicator = true
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
    }
    
}
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            let slackUrl = URL(string: Slack.slackUrl)!
            let httpUtility = HttpUtility()
            do {
                let messageBody = try JSONEncoder().encode(Message(text: "\(location)"))
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

