//
//  Sound.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//

import AVFoundation // AVFoundation contains the sound management interface
import UIKit // UIKit constructs and manages the app's UI

// Equips the app with an audio player
var audioPlayer = AVAudioPlayer()

// Class which holds and plays a sound file
class Sound{
    
    // Method which plays a specified sound file from the sound resource files
    func playSound(_ soundName: String){
        // Retrieves the sound file
        let soundFile = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        do{ // Attempts to load the sound file into the sound player
            audioPlayer = try AVAudioPlayer(contentsOf: soundFile)
            // Plays the sound
            audioPlayer.play()
        } catch{ // If sound couldn't be loaded then an error is printed
            print("Error getting the audio file")
        }
    }
}
