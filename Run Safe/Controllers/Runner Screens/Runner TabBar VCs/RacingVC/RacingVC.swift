//
//  RacingVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 17/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import TinyConstraints

class RacingVC: UIViewController {
    
    //MARK: Objects
    var timeLabel                       = UILabel()
    var hoursLabel                      = RSRacingLabel(text: "00")
    var dotsLabel                       = RSRacingLabel(text: ":")
    var minutesLabel                    = RSRacingLabel(text: "00")
    var secondDotsLabel                 = RSRacingLabel(text: ":")
    var secondsLabel                    = RSRacingLabel(text: "00")
    var firstSeparator                  = UIView()
    
    var distanceLabel                   = UILabel()
    var distanceNumberLabel             = RSRacingLabel(text : "0.0")
    var kilometerLabel                  = UILabel()
    var secondSeparator                 = UIView()
    
    var speedLabel                      = UILabel()
    var speedNumberLabel                = RSRacingLabel(text : "0.0")
    var secondKilometerLabel            = UILabel()
    var thirdSeparator                  = UIView()
    
    let startStopButton                 = UIButton()
    let finishButton                    = UIButton()
    
    //MARK: Arrays
    lazy var subviewsNoTamic    = [timeLabel, distanceLabel, kilometerLabel, speedLabel,secondKilometerLabel]
    lazy var subviewsTamic      = [timeLabel, distanceLabel, distanceNumberLabel ,kilometerLabel , speedLabel, speedNumberLabel,
                                   secondKilometerLabel]
    lazy var separator          = [firstSeparator, secondSeparator, thirdSeparator]
    lazy var separators = [firstSeparator, secondSeparator, thirdSeparator]
    lazy var buttons    = [startStopButton, finishButton]
    
    
    //MARK: Properties
    let padding = CGFloat(20)
    let spacing = CGFloat(10)
    
    var time                = Int(0)
    var userLocation        = CLLocation()
    var startLocation       : CLLocation!
    var lastLocation        : CLLocation!
    var traveledDistance    : Double = 0
    var currentSpeed        : Double = 0
    
    let runningCol          = Firestore.firestore().collection("Running")
    let runnersCol          = Firestore.firestore().collection("Runner")
    let runnerRef           = Database.database().reference().child("runners")
    
    var timer           = Timer()
    var serverTimer     = Timer()
    let locationManager = CLLocationManager()
    
    var isUserRunning   = false
    

    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCoreLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Course"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if isUserRunning {
            serverTimer.invalidate()
            serverTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerDidSendInfo), userInfo: nil, repeats: true)
        }
    }
}


//MARK: Actions
extension RacingVC {
    @objc func playStopRace() {
        startStopButton.isSelected.toggle()
        
        if startStopButton.isSelected {
            startStopButton.setImage(UIImage(named : ButtonIcons.stop), for: .normal)
            //TODO: Send info to the server
            configureCoreLocation()
            checkLocationServices()
            startTimer()
            isUserRunning = true
        } else {
            startStopButton.setImage(UIImage(named : ButtonIcons.play), for: .normal)
            pauseTimer()
            locationManager.stopUpdatingLocation()
        }
    }
    @objc func finishRace() {
        pauseTimer()
        locationManager.stopUpdatingLocation()
        let alert = UIAlertController(title: "Terminer", message: "Êtes-vous sûr de vouloir arrêter la course ?", preferredStyle: .alert)
        
        let yesAction   = UIAlertAction(title: "Confirmer", style: .default) { (_) in
            //TODO: Send last knonw location to the server
            if let user = Auth.auth().currentUser {
                //Database
                let currentUserRef = self.runnerRef.child(user.uid)
                
                let value = [
                    "lastLatitude" : self.lastLocation.coordinate.latitude,
                    "lastLongitude" : self.lastLocation.coordinate.longitude
                ] as [String : Any]
                currentUserRef.childByAutoId().setValue(value)
                
                self.showFinishedRace()
                
                self.time               = 0
                self.traveledDistance   = 0
                self.currentSpeed       = 0
                
                self.updateTimerUI()
                self.updateDistanceUI()
                
                
            }
        }
        let noAction    = UIAlertAction(title: "Annuler", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true)
    }
    @objc func positionButtonTapped() {
        locationManager.stopUpdatingLocation()
        let map = RacingMapVC()
        map.currentUserLoc = self.userLocation
        self.navigationController?.pushViewController(map, animated: true)
    }
}


//MARK: - Timer
extension RacingVC {
    fileprivate func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1, target: self, selector: #selector(timerDidEnd), userInfo: nil, repeats: true)
        serverTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerDidSendInfo), userInfo: nil, repeats: true)
    }
    fileprivate func pauseTimer() {
        timer.invalidate()
        serverTimer.invalidate()
    }
    fileprivate func updateTimerUI() {
        var hours   = Int(0)
        var minutes = Int(0)
        var seconds = Int(0)
        
        hours   = time / (60*60)
        minutes = (time / 60)%60
        seconds = time % 60
        
        if hours < 10 {
            hoursLabel.text     = "0\(String(hours))"
        } else {
            hoursLabel.text     = String(hours)
        }
        if minutes < 10 {
            minutesLabel.text   = "0\(String(minutes))"
        } else {
            minutesLabel.text   = String(minutes)
        }
        if seconds < 10 {
            secondsLabel.text   = "0\(String(seconds))"
        } else {
            secondsLabel.text   = String(seconds)
        }
    
    }
    @objc func timerDidEnd() {
        time += 1
        updateTimerUI()
    }
    
    @objc func timerDidSendInfo() {
        print("timer did send")
        sendUser(location: lastLocation)
    }
}


//MARK: - Core Location

extension RacingVC {
    fileprivate func configureCoreLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            configureCoreLocation()
            checkLocationAuthorizations()
            locationManager.startUpdatingLocation()
        } else {
            self.presentSimpleAlert(title: "Oups !", message: "Veuillez autoriser l'app à accéder à votre localisation.")
        }
    }
    func checkLocationAuthorizations() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined         :
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse   : break
        case .authorizedAlways      : break
        default: break
        }
    }
}

//MARK: - Core Location Delegate

extension RacingVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizations()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += Double(lastLocation.distance(from: location))
            currentSpeed = lastLocation.speed
        }
        
        lastLocation = locations.last
        
        if UIApplication.shared.applicationState == .active {
            updateDistanceUI()
            updateTimerUI()
            sendUser(location: lastLocation)
        } else {
            print("app is not active, last loc = \(lastLocation.coordinate)")
            sendUser(location: lastLocation)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
}


//MARK: - Firebase

extension RacingVC {
    func sendUser(location : CLLocation) {
        if let user = Auth.auth().currentUser {
            let data = [
                "lastLatitude"  : self.lastLocation.coordinate.latitude,
                "lastLongitude" : self.lastLocation.coordinate.longitude,
                "uid"           : user.uid
            ] as [String : Any]
            runningCol.document(user.uid).setData(data) { (_error) in
                guard _error == nil else {
                    print("error setting data : \(_error!.localizedDescription)")
                    return
                }
            }
            
            runnersCol.document(user.uid).setData(data, merge: true) { (_error) in
                guard _error == nil else {
                    print("error setting data : \(_error!.localizedDescription)")
                    return
                }
            }
        } else {
            print("no user")
        }
    }
}


//MARK: - Helper Methods

extension RacingVC {
    fileprivate func updateDistanceUI() {
        DispatchQueue.main.async {
            let meters                      = self.traveledDistance.rounded()
            let metersMeasurement           = Measurement(value: meters, unit: UnitLength.meters)
            let kilometers                  = metersMeasurement.converted(to: UnitLength.kilometers)
            let kilometersValue             = (kilometers.value * 100).rounded() / 100
            
            self.distanceNumberLabel.text   = String(kilometersValue)
            
            let metersSpeed                 = self.currentSpeed.rounded()
            let metersSpeedMeasurement      = Measurement(value: metersSpeed, unit: UnitSpeed.metersPerSecond)
            let kilometersSpeed             = metersSpeedMeasurement.converted(to: UnitSpeed.kilometersPerHour)
            let kilometersSpeedValue        = (kilometersSpeed.value * 100).rounded() / 100
                
            self.speedNumberLabel.text      = String(kilometersSpeedValue)
        }
    }
    
    
    
    fileprivate func showFinishedRace() {
        let finish = FinishedRaceVC()
        finish.time = self.time
        finish.distance = self.traveledDistance
        //TODO: Pass the infos to the next vc
        navigationController?.pushViewController(finish, animated: true)
    }
}
