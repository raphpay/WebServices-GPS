//
//  ViewRangerParser.swift
//  Run Safe
//
//  Created by Raphaël Payet on 12/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseDatabase

class ViewRangerParser : NSObject, XMLParserDelegate {
    
    private var locations = [CLLocationCoordinate2D]()
    
    private var currentElement      = ""
    private var currentParserType   = ""
    private var currentLongitude    = Double(0)
    private var currentLatitude     = Double(0)
    
    
    private var parserCompletionHandler : (([CLLocationCoordinate2D]) -> Void)?
    
    func parseItem(data : Data?, completion : (([CLLocationCoordinate2D]) -> Void)?) {
        self.parserCompletionHandler = completion
        
        if data != nil {
            let parser = XMLParser(data: data!)
            parser.delegate = self
            parser.parse()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if currentElement == "rtept",
            let latitudeString = attributeDict["lat"],
            let longitudeString = attributeDict["lon"],
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString){
            currentLatitude = latitude
            currentLongitude = longitude
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "rtept" {
            let locationPoint = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
            self.locations.append(locationPoint)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(locations)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parser error occurred : \(parseError.localizedDescription)")
    }
}
