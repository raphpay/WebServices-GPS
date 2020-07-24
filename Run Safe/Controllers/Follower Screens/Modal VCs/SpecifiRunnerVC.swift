//
//  SpecifiRunnerVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 02/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import MapKit
import JGProgressHUD

class SpecifiRunnerVC: UIViewController {

    //MARK: - Objects
    var mapView = MKMapView()
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: - Properties
    var runner  : Runner!
    var position : CLLocationCoordinate2D!
    let regionInMeters = Double(10000)
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        setupUI()
        centerView(on: position)
        addPin(on: position)
    }
}

//MARK: - UserInterface

extension SpecifiRunnerVC {
    fileprivate func configureMap() {
        mapView = MKMapView()
        mapView.frame = view.bounds
        mapView.delegate = self
    }
    fileprivate func setupUI() {
        view.addSubview(mapView)
    }
}

//MARK: - Map View

extension SpecifiRunnerVC {
    fileprivate func centerView(on runnerPosition : CLLocationCoordinate2D?) {
        guard let position = runnerPosition else { return }
        
        let region = MKCoordinateRegion(center: position, latitudinalMeters: regionInMeters,
                                        longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    fileprivate func addPin(on runnerPosition : CLLocationCoordinate2D?) {
        guard let position = runnerPosition else { return }
        
        let pin = MKPointAnnotation()
        pin.coordinate = position
        if let runner = runner {
            let name = "\(runner.lastName) \(runner.firstName)"
            pin.title = name
        }
        
        mapView.addAnnotation(pin)
    }
}


//MARK: - MapView Delegate
extension SpecifiRunnerVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reusePin = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusePin) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusePin)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        pinView?.image = UIImage(named : AssetsImages.mapPin)
        
        return pinView
    }
}
