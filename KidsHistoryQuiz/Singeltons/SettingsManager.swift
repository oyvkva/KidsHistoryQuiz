//
//  SettingsManager.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/3/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import Foundation
import AVFoundation

class SettingsManager {
    
    // MARK: Layout
    // Change layouts for catagories, squares and rectangles supported
    let categoryLayouts = ["rectangles", "squares", "rectangles", "squares", "rectangles"]
    let appTaskList = [100,101,102,103,104]
    
    // MARK: Categories
    // To change color paste a new hex color and put 0x in front
    let categoryColors = [0x61ba5d,0xaece5d,0xef9247,0xea3944,0xef9247,0x61ba5d,0xaece5d,0xef9247]
    
    // To change category icons, chose whatever name your icon has
    let categoryIcons = ["geography_icon", "celebrities_icon", "figures_icon","history_icon", "economy_icon"]
    
    // To change names of free categories (For paid you change name in iTunes connect in-App purchases)
    let freeCategoryNames = ["Location photos", "Historical Figures", "War history", "General History", "Economics"]
    
    // MARK: Sounds Configuration
    var sound = true // Enable sound or not
    let tapSound = "iPad_tap"
    let winningSound = "winning1"
    let errorSound = "error"
    let correctSound = "correct"
    
    // MARK: Gameplay Configuration
    let totalGameTime = 60.0 // Length of a game round in seconds
    let minusTimeWhenWrong = 2.0 // Time reduction in seconds when choosing wrong answer
    let plussTimeWhenCorrect = 1.0 // Time added in seconds when choosing correct answer
    let minusScoreWhenWrong = 3 // Points reducting when choosing wrong answer
    let plussScoreWhenCorrect = 5 // Points added when choosing correct answer
    

    // MARK: pList names, also used as leaderboardIDs
    let freeProblemSetsPlists = ["Category2", "Category5", "Category6", "Category7", "Category8"] // Free pList names
    
    
    static let sharedInstance = SettingsManager()
}

func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
    
    let path = Bundle.main.path(forResource: file as String, ofType: type as String)
    let url = URL(fileURLWithPath: path!)
    var audioPlayer:AVAudioPlayer?
    
    do {
        try audioPlayer = AVAudioPlayer(contentsOf: url)
    } catch {
        print("NO AUDIO PLAYER")
    }
    
    return audioPlayer!
}

