//
//  LocalStorageHandler.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file acts as an interface between the local device storage and the application

import UIKit // UIKit constructs and manages the app's UI

// Class grants access to specified file
class LocalStorageHandler {
    
    // Instantiates a default file manager object
    private let fileManager = FileManager.default
    
    // Attributes storing information about the file
    private let directory: FileManager.SearchPathDirectory
    private let directoryPath: String
    private let subDirectory: String
    private let pathToSubDir: String
    private let fileName: String
    private let fullPathToFile: String
    
    // File and sub directory existence flags
    private let doesFileExist: Bool
    private var doesSubDirectoryExist: ObjCBool = false
    
    // Stores the local storage response
    private var response = [String:String]()
    
    // Initialises class attributes
    init(fileName: String, subDirectory: String, directory: FileManager.SearchPathDirectory){
        self.fileName = fileName
        self.subDirectory = "/\(subDirectory)"
        self.directory = directory
        // Gets directory path specific to the device
        self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
        self.pathToSubDir = directoryPath + self.subDirectory
        self.fullPathToFile = "\(self.pathToSubDir)/\(self.fileName).json"
        // Updates file/subdirectory flags
        self.doesFileExist = self.fileManager.fileExists(atPath: fullPathToFile) // Checks if the file exists
        self.fileManager.fileExists(atPath: pathToSubDir, isDirectory: &doesSubDirectoryExist) // Checks if sub directory exists
        
        // Calls a function that creates the subdirectory if needed
        createDirectory()

    }
    
    // Method which creates a directory if directory doesn't exist
    private func createDirectory(){
        // Checks if subdirectory doesn't exists
        if !(doesSubDirectoryExist.boolValue){
            do{ // Attempts to create the subdirectory
                try self.fileManager.createDirectory(atPath: pathToSubDir, withIntermediateDirectories: false, attributes: nil)
            } catch { // If not an error is raised
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Method which returns a bool indicating whether a file exists
    public func getDoesFileExist() -> Bool{
        return doesFileExist
    }
    
    // [-------------------------- JSON Conversion & Retrieval----------------------------------]
    
    // Method which converts JSON objects into JSON strings
    public func jsonToString(jsonData: Any) -> String{
        // Checks if jsonData passed is a valid JSON object
        if JSONSerialization.isValidJSONObject(jsonData) {
            do{
                // Tries to serialise the JSON object
                let data = try JSONSerialization.data(withJSONObject: jsonData)
                // Attempts to convert the JSON object into a string
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch { // Prints error
                print("Couldn't Convert JSON object into string")
            }
        }
        // If the JSON object is not converted, a null string is returned
        return ""
    }
    
    // Reads JSON Files and retrieves the JSON data as a dictionary
    public func retrieveJSONData() -> NSDictionary{
        // Checks that the file exists
        if doesFileExist{
            do{ // Attempts to retrieve data from the file
                let fileData = try NSData(contentsOfFile: fullPathToFile, options: NSData.ReadingOptions.mappedIfSafe)
                // Attempts to serialise the JSON object (convert the JSON data into a Swift-readable dictionary)
                let jsonDicationary = try JSONSerialization.jsonObject(with: fileData as Data, options: .allowFragments) as! NSDictionary
                return jsonDicationary
            } catch{ // If the JSON file couldn't be retrieved or serialised then an error is returned
                self.response["Error"] = "true"
                self.response["Message"] = "Couldn't retrieve JSON file contents"
                return self.response as NSDictionary
            }
        } else { // If the JSON file doesn't exist then an error is returned
            self.response["Error"] = "true"
            self.response["Message"] = "File doesn't exist"
            return self.response as NSDictionary
        }
    }
    
    // [-------------------------Saving Packs & JSON Files----------------------------------]
    
    // Method which saves JSON files to the full path. If the file is successfully saved 'true' is returned
    public func saveJSONFile(dataToWrite: Any) -> Bool {
        // Initialises convertedJSONToSave as an empty data object
        var convertedJSONToSave: Data?
        
        // Attempts to convert given dictionary into JSON file
        do{
            convertedJSONToSave = try JSONSerialization.data(withJSONObject: dataToWrite, options: .prettyPrinted)
        } catch{ // If the JSON file couldn't be serialised then false is returned
            print("Couldn't serialise JSON file")
            return false
        }
        
        // Attempts to write JSON File to storage
        if fileManager.createFile(atPath: fullPathToFile, contents: convertedJSONToSave, attributes: nil){
            print("File Saved")
            return true
        } else { // Error has occurred and false is returned
            print("File could not be saved")
            return false
        }
    }
    
    // Method for saving the edited version of a pack, returns the pack details dictionary
    public func saveEditedPack(packData: [String: Any]) -> [String:AnyObject] {
        // Initialises data to write array
        var dataToWrite = packData
        // Retrieves the original pack
        let originalPackData = retrieveJSONData()
        
        // Compares the original pack to the one that was passed
        if !(originalPackData.isEqual(to: packData)){
            print("Packs Are not the same")
            // If a change has been detected the version number is incremented by one
            let currentVersionNum = Int(packData["Version"]! as! String)!
            dataToWrite["Version"] = String(currentVersionNum + 1)
            
            // Attempts to save the pack
            if saveJSONFile(dataToWrite: dataToWrite){
                // If saving the file was successful then the pack data is passed back and the error flag is set to false
                return ["error": false as AnyObject, "data": dataToWrite as AnyObject]
            } else{ // If the file couldn't be saved then the error flag is set to true and an error message is passed back
                print("Couldn't save edited pack")
                return ["error": true as AnyObject, "message": "Couldn't save edited pack" as AnyObject]
            }
        } // If no changes to the file was made then an error message is returned
        print("Packs are the same")
        return ["error": true as AnyObject, "message": "No changes to the pack were made" as AnyObject]
        
    }
    
    // Method that adds the new pack to the device - the pack is saved as a json file and the linked lists are updated to reflect the new pack addition
    public func addNewPackToPhone(packData: NSDictionary) -> Bool {
        // Saves data as a JSON file in the location specified by the 'fullPathToFile'
        if saveJSONFile(dataToWrite: packData as NSDictionary){
            // Retrieves the pack details needed to update the linked lists
            let packName = packData["PackName"]! as! String
            let creatorID = packData["CreatorID"]! as! String
            let packLocation = packData["Location"]! as! String
            
            let defaults = UserDefaults.standard
            
            // Checks if listOfLocalUserIDs exists
            if var listOfUserIDs = defaults.array(forKey: "listOfLocalUserIDs") {
                // Converts the list of local user IDs array into an array of strings
                listOfUserIDs = listOfUserIDs as! [String]
                
                // Checks if creator user ID of the pack is part of the listOfLocalUserIDs array
                if !(listOfUserIDs.contains(where: {$0 as! String == creatorID})) {
                    // If new creator user ID not found, the new ID is appended to the listOfLocalUserIDs
                    listOfUserIDs.append(creatorID)
                    defaults.set(listOfUserIDs, forKey: "listOfLocalUserIDs")
                }
                
                // Array containing all of a specific user's created packs is instantiated
                let creatorDictKey = "UserID-\(creatorID)-Packs"
                var creatorLocalPackDict = [String:String]()
                
                // Checks if specific user ID dictionary exists. If exists, the dictionary is retrieved
                if let dictionary = defaults.dictionary(forKey: creatorDictKey){
                    creatorLocalPackDict = dictionary as! [String : String]
                }
                
                // Pack identifier/display name (name-location key) is appended to the dictionary along with the corresponding filename
                let packKey = "\(packName) - \(packLocation)"
                creatorLocalPackDict[packKey] = self.fileName
                defaults.set(creatorLocalPackDict, forKey: creatorDictKey)
                
                // Commits the pack linked list information to the local userdefaults database
                defaults.synchronize()
                return true
            } else{ // If the local list of creator IDs couldn't be retrieved then an error is printed and 'false' is returned
                print("Error loading array of local creator IDs")
                return false
            }
        } else{ // If the file couldn't be saved then an error is printed and 'false' is returned
            print("Error saving JSON file")
            return false
        }
    }
    
    //[-------------------Pack Deletion-------------------------]
    
    // Method which deletes a pack (file) and updates the pack linked lists to reflect the file deletion
    public func deleteFile(packName: String, packLocation:String, creatorID: String) -> Bool{
        do { // Attempts to delete the file
            try fileManager.removeItem(atPath: self.fullPathToFile)
            
            // Generates the name of the array containing all of a specific user's created packs
            let creatorDictKey = "UserID-\(creatorID)-Packs"
            let defaults = UserDefaults.standard
            // Retrieves the creator's local packs dictionary
            var creatorLocalPackDict = defaults.dictionary(forKey: creatorDictKey) as! [String : String]
            
            // Pack identifier/display name (name-location key) is removed from the dictionary along with the corresponding filename
            let packKey = "\(packName) - \(packLocation)"
            creatorLocalPackDict.removeValue(forKey: packKey)
            
            // Checks if there are any local packs, made by the creator user ID passed, remaining
            if creatorLocalPackDict.isEmpty{
                // If no more packs made by that creator exists on the device then the creator dictionary is deleted
                defaults.removeObject(forKey: creatorDictKey)
                // The list of local user IDs is updated with the creator being removed
                var listOfUserIDs = defaults.array(forKey: "listOfLocalUserIDs") as! [String]
                if let index = listOfUserIDs.index(of:creatorID) {
                    listOfUserIDs.remove(at: index)
                } // Saves the new list of user IDs
                defaults.set(listOfUserIDs, forKey: "listOfLocalUserIDs")
                
                do{ // Attempts to delete the creator's subdirectory
                    try fileManager.removeItem(atPath: self.pathToSubDir)
                } catch{ // Error is printed and false is returned if the sub directory can't be deleted
                    print("Couldn't delete user subdirectory")
                    return false
                }
            } else { // If there are still packs made by the creator on the device, the new creator's pack list is saved
                defaults.set(creatorLocalPackDict, forKey: creatorDictKey)
            }
            // Commits the pack linked list information to the local userdefaults database
            defaults.synchronize()
            return true
        } catch { // Error is printed and false is returned if the file can't be deleted
            print("Couldn't delete file")
            return false
        }
    }

}

