//
//  PinLocation.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
// This file defines the PinLocation class

import MapKit // MapKit constructs and manages the map and annotations
import UIKit // UIKit constructs and manages the app's UI

// PinLocation class is a child class of NSObject and MKAnnotations
// - It stores information about a pin from a pack
class PinLocation: NSObject, MKAnnotation{
    
    // Attributes about the pin
    let title: String?
    let hint: String
    let codeword: String
    let coordinate: CLLocationCoordinate2D
    let pointVal: Int
    var isFound = false
    
    // Attributes are set on instantiation
    init(title: String, hint:String, codeword: String, coordinate: CLLocationCoordinate2D, pointVal: Int){
        self.title = title
        self.hint = hint
        self.codeword = codeword
        self.coordinate = coordinate
        self.pointVal = pointVal
        super.init()
    }
    
    // The annotation subtitle is set as how many points the pin is worth
    var subtitle: String? {
        return String("\(pointVal) Points")
    }

    // Returns a dictionary containing all of the information about the pin
    func getDictOfPinInfo() -> [String : String] {
        let dictOfPinInfo = ["Title": self.title!, "Hint": self.hint, "Codeword": self.codeword, "CoordLatitude": String(self.coordinate.latitude), "CoordLongitude": String(self.coordinate.longitude), "PointValue": String(self.pointVal)]
        return dictOfPinInfo
    }
}
