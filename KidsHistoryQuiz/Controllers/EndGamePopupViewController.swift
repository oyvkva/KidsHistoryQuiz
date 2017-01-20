//
//  EndGamePopupViewController.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/3/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import UIKit
import AVFoundation
import Social


class EndGamePopupViewController: UIViewController {
    
    var delegate: EndGameControllerDelegate?
    var sm = SettingsManager.sharedInstance
    var currentScore = 0
    var correct = 0
    var wrong = 0
    var poeng = String()
    var highscoreText = String()
    var newHighscoreText = String()
    var currentActivity = String()
    var tapSound: AVAudioPlayer!
    var winningSound: AVAudioPlayer!
    var highscore = Int()
    @IBOutlet weak var myScoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (sm.sound) {
            tapSound = setupAudioPlayerWithFile(sm.tapSound as NSString, type: "wav")
            winningSound = setupAudioPlayerWithFile(sm.winningSound as NSString, type:  "wav")
        }
  
        retryButton.setTitle(NSLocalizedString("Retry",comment: "Button text"), for:UIControlState())
        poeng = NSLocalizedString("points!",comment: "Points text")
        newHighscoreText = NSLocalizedString("New highscore",comment: "Text")
        highscoreText = NSLocalizedString("Highscore",comment: "Text")
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (sm.sound) { winningSound.play() }
        
        highscore = HighscoreManager.sharedInstance.getHighscoreArrayForActivity(currentActivity)[0] as Int
        
        myScoreLabel.text = "\(currentScore) \(poeng)"
        
        if (currentScore > highscore){
            highscoreLabel.text = "\(newHighscoreText): \(currentScore)"
            HighscoreManager.sharedInstance.updateScore(currentActivity, levelNumber: 1, score: currentScore)
        }
        else {
            highscoreLabel.text = "\(highscoreText): \(highscore)"
        }
        
        HighscoreManager.sharedInstance.updateAverage(currentActivity, levelNumber: 1, correct: correct, wrong: wrong)
    }
    


    
    // MARK: Logic
    @IBAction func startNewGame(_ sender: UIButton!) {
        if (sm.sound) { tapSound.play() }
        self.dismiss(animated: false, completion: {
            self.delegate?.startMode()
        })
    }
    

    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    

    
    
}

// MARK: EndGameControllerDelegate
// We use the protocol to be able to send messages back to the GameViewController
// Or other classes conforming to the EndGameControllerDelegate
protocol EndGameControllerDelegate {
    func startMode()
}
