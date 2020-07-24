//
//  SpecificRaceVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 03/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import JGProgressHUD

class SpecificRaceVC: UIViewController {

    //MARK: - Objects
    var mapView : MKMapView!
    
    var locations           = [CLLocationCoordinate2D]()
    var pins                = [MKPointAnnotation]()
    let viewRangerParser    = ViewRangerParser()
    let stravaParser        = StravaParser()
    
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: - Properties
    var raceName    : String!
    var racePlace   : String!
    let eventsRef = Database.database().reference().child("events")
    var xmlData : Data!
    
    let regionInMeters = Double(10000)
    
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        setupUI()
        
        hud.textLabel.text = "Chargement"
        hud.show(in: self.view)
        
        if let race = raceName {
            getXMLData(for: race)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

//MARK: - User Interface
extension SpecificRaceVC {
    fileprivate func configureMap() {
        mapView = MKMapView()
        mapView.frame = view.bounds
        mapView.delegate = self
    }
    fileprivate func setupUI() {
        view.addSubview(mapView)
    }
}

//MARK: - Actions
extension SpecificRaceVC {
    @objc func backToRacesVC(_ sender : UIBarButtonItem) {
        SpecificRaceVC().dismiss(animated: true)
    }
}

//MARK: - Map View
extension SpecificRaceVC {
    fileprivate func centerViewOnStart() {
        if !self.locations.isEmpty,
            let firstPin = self.locations.first,
            let lastPin = self.locations.last {
            
            let startLatitude  = firstPin.latitude
            let startLongitude = firstPin.longitude
            let startCenter = CLLocationCoordinate2D(latitude: startLatitude,
                                                     longitude: startLongitude)
            let region = MKCoordinateRegion(center: startCenter,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
            
            let raceStartEnd = [firstPin, lastPin]
            addPins(at: raceStartEnd)
        }
        createPolyline()
    }
    fileprivate func addPins(at locations : [CLLocationCoordinate2D]) {
        for location in locations {
            let pin = MKPointAnnotation()
            pin.coordinate = location
            mapView.addAnnotation(pin)
        }
    }
    fileprivate func createPolyline() {
        let myPolyline = MKPolyline(coordinates: locations, count: locations.count)
        mapView.addOverlay(myPolyline)
    }
}
//MARK: - Map View Delegate
extension SpecificRaceVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.pinTintColor = .link
        } else {
            
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        }
        
        return MKOverlayRenderer()
    }
}


//MARK: - Firebase

extension SpecificRaceVC {
    fileprivate func getXMLData(for race : String) {
        eventsRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let events = childSnapshot.value as? [String : Any],
                    let name = events["name"] as? String,
                    name == race,
                    let xmlString = events["xml"] as? String,
                    let xmlData = xmlString.data(using: .utf8) {
                    self.xmlData = xmlData
                }
            }
            if let data = self.xmlData {
                self.stravaParser.parseItem(data: data) { (locations) in
                    //TODO  : Manage errors
                    self.locations = locations
                    self.centerViewOnStart()
                    self.hud.dismiss()
                }
            } else {
                self.presentSimpleAlert(title: "Oups !", message: "Il y a eu un soucis avec cette course, veuillez réessayer plus tard.")
                self.hud.dismiss()
            }
        }
    }
    
}
