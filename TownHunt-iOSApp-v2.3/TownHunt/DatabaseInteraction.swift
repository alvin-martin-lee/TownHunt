//
//  DatabaseInteraction.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the logic behind the interface between the app and the database API

import UIKit // UIKit constructs and manages the app's UI
import SystemConfiguration // Grants, the app, access a device’s network configuration settings.

// Class acts as interface between the app and the database API
class DatabaseInteraction: NSObject {
    
    // URL stem (online location) of the TownHunt api
    let mainSQLServerURLStem = "http://alvinlee.london/TownHunt/api"
    
    // Checks to see if the phone is connected to the internet, returns true if there is internet connectivity and false if there isn't
    func connectedToNetwork() -> Bool {
        
        // Creates the socket address pointer that access to will be tested
        var zeroTestAddress = sockaddr_in()
        zeroTestAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size) // Defines the size of the socket as the number of bytes allocated to the socket
        // Sets the type of addresses that the socket can communicate with, in this case IPv4 addresses (AF_INET) - the safest option
        zeroTestAddress.sin_family = sa_family_t(AF_INET)
        
        // Uses predefined 'Reachability' function to attempt to reach (connect) to the test socket
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroTestAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { // If no connection can be established then false is returned
            return false
        }
        
        // Stores information (info flags) about the test connection
        var connectTestflags: SCNetworkReachabilityFlags = []
        // Attempts to retrieve the flags information about the devices' connectivity
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &connectTestflags) {
            // If no flags can be retrieved then there is no internet connection and false is returned
            return false
        }
        
        // Retrieves the two internet connection flags
        let isReachable = connectTestflags.contains(.reachable) // Are web addresses reachable/connectable? flag
        let deviceNeedsConnection = connectTestflags.contains(.connectionRequired) // Does the device have an internet connection? flag
        
        // Returns the AND of the two internet connection flags.
        // If there is an internet connection and ip addresses are reachable then true is returned
        return (isReachable && !deviceNeedsConnection)
    }
    
    // Posts data to a specified TownHunt API to the online database and returns a dictionary containing the API's/Database's response
    func postToDatabase(apiName :String, postData: String, completion: @escaping (NSDictionary)->Void){
        // Prepares the URL location of the specific API file
        let apiURL = URL(string: mainSQLServerURLStem + "/" + apiName + "/")
        // Initialises the URL (HTTP) request
        var request = URLRequest(url: apiURL!)
        // HTTP request method is set to POST as the app will be POSTing the data
        request.httpMethod = "POST"
        // The data (POST parameters) to be POSTed is set as the URL request message body
        request.httpBody = postData.data(using: String.Encoding.utf8) // postData is encoded into UTF-8 which is used by the online API
        
        // A URLSession object is instantiated to handle the request.
        let task = URLSession.shared.dataTask(with: request) {
            // Completion handler defines - once the request is completed, the info retrieved from the API/Database is interpreted
            // Gets passed the data, response and error (All of which are optional)
            (data: Data?, response: URLResponse?, error: Error?) in
            
            // Checks for errors
            if error != nil{
                print("error=\(error)")
                return
            }
            // Prints the full URL response
            print("response = \(response)")
            
            // Attempts to convert the data received into a dictionary
            do {
                // Tries to serialise the data into a json dictionary
                let jsonDicationary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                // Completes/ends the task and returns the json dictionary
                completion(jsonDicationary!)
            } catch {
                print(error)
            }
        } // Since all tasks start in a suspended state by default, 'resume' starts the task
        task.resume()
    }

}
