//
//  DevScreenViewController.swift
//  TownHunt
//
//  Created by iD Student on 8/2/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit
import MapKit

class DevScreenViewController: UIViewController {

    @IBOutlet weak var TestLabel: UILabel!
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    
    let filePath = NSHomeDirectory() + "/Documents/" + "MITPack.txt"
    var values: [NSArray] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteFile(_ sender: AnyObject) {
        let text = ""
        do{
            try text.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        }catch{
            
        }
    }

    @IBAction func addMITSamplePins(_ sender: AnyObject) {
        for pin in packPins{
            let writeLine = "\(pin.title!),\(pin.hint),\(pin.codeword),\(pin.coordinate.latitude),\(pin.coordinate.longitude),\(pin.pointVal)"
            writeToFile(writeLine)
        }
    }
    
    @IBAction func downloadPinsFromServer(_ sender: AnyObject) {
        let url = URL(string: "http://alvinlee.london/getPins.php")
        let data = try? Data(contentsOf: url!)
        do {let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        if let dictionary = object as? [String: AnyObject] {
            readJSONObject(object: dictionary)}
        }catch{
            print("Error reading JSON file")
        }
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let downPins = object[""] as? [[String: AnyObject]] else { return }
        
        for downPin in downPins {
            let title = downPin["Title"] as? String
            let hint = downPin["Hint"] as? String
            let codeword = downPin["Codeword"] as? String
            let cLong = downPin["CoordLongitude"] as? String
            let cLat = downPin["CoordLatitude"] as? String
            let pointVal = downPin["PointValue"] as? String
            let writeLine = "\(title!),\(hint!),\(codeword!),\(cLong!),\(cLat)!,\(pointVal!)"
            print(writeLine)
        }
    }
    

    func writeToFile(_ content: String) {
        let contentToAppend = content+"\n"
        //Check if file exists
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            //Append to file
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
        } else {
            //Create new file
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }
    
    @IBAction func printsWhatsInFile(_ sender: AnyObject) {
        var stringFromFile: String
        do{
            stringFromFile = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            let packPinLocArrays = stringFromFile.characters.split(separator: "\n").map(String.init)
            print(packPinLocArrays)
            if packPinLocArrays.isEmpty == false{
                for pinArray in packPinLocArrays{
                    print(pinArray)
                    let pinDetails = pinArray.characters.split(separator: ",").map(String.init)
                }
            }
        } catch let error as NSError{
            print(error.description)
        }
    }
    @IBAction func gameTimeTo10s(_ sender: Any) {
        
    }
    
    func deletePack(filePath: String) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: filePath)
            return true
        } catch {
            print("Could not clear temp folder: \(error)")
            return false
        }
    }
    
    @IBAction func deleteAllPacksOnPhone(_ sender: Any) {
        let defaults = UserDefaults.standard
        var packsOnPhone = defaults.dictionary(forKey: "dictOfPacksOnPhone")
        for key in Array(packsOnPhone!.keys){
            if self.deletePack(filePath: "\(packsOnPhone![key]!)"){
                packsOnPhone?.removeValue(forKey: packsOnPhone![key] as! String)
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
