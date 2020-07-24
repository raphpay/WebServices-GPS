//
//  RacingMapVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 18/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MapKit
import CoreLocation

class RacingMapVC: UIViewController {
    
    //TODO : Show the user location and update it
    
    //MARK: - Objects
    var mapView : MKMapView!
    var locationManager = CLLocationManager()
    var userLocation    = CLLocation()
    var serverTimer     = Timer()
    
    //MARK: - Properties
    var currentUserLoc = CLLocation()
    var regionInMeters = Double(10000)
    let runningCol     = Firestore.firestore().collection("Running")
    let runnersCol     = Firestore.firestore().collection("Runner")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension RacingMapVC {
    fileprivate func setupUI() {
        configureMapView()
        checkLocationServices()
    }
    
    fileprivate func configureMapView() {
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        centerViewOnCurrentLocation(location: currentUserLoc.coordinate)
    }
    
    fileprivate func configureCoreLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
}


//MARK: - Core Location
extension RacingMapVC {
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            configureCoreLocation()
            checkLocationAuthorizations()
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

//MARK: - Map View

extension RacingMapVC {
    fileprivate func centerViewOnCurrentLocation(location : CLLocationCoordinate2D) {
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
    }
}


//MARK: - Core Location Delegate

extension RacingMapVC : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizations()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentUserLoc = location
        centerViewOnCurrentLocation(location: location.coordinate)
    }
}

