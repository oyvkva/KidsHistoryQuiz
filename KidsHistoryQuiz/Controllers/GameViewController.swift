//
//  GameViewController.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/3/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import UIKit
import AVFoundation
import KapabelSDK

class GameViewController: UIViewController, EndGameControllerDelegate {
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var extraTimelabel: UILabel!
    @IBOutlet weak var lessTimelabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressTimer: UIProgressView!
    
    var sm = SettingsManager.sharedInstance
    var tapSound: AVAudioPlayer!
    var errorSound: AVAudioPlayer!
    var correctSound: AVAudioPlayer!
    var timer = Timer()
    var answerButtons: [UIButton] = [UIButton]()
    var score: Int = 0
    var round: Int = 0
    var correct: Int = 0
    var wrong: Int = 0
    var totalTime: Double = SettingsManager.sharedInstance.totalGameTime
    var timeLeft: Double = SettingsManager.sharedInstance.totalGameTime
    let minusTimeWhenWrong = SettingsManager.sharedInstance.minusTimeWhenWrong
    let plussTimeWhenCorrect = SettingsManager.sharedInstance.plussTimeWhenCorrect
    let minusScoreWhenWrong = SettingsManager.sharedInstance.minusScoreWhenWrong
    let plussScoreWhenCorrect = SettingsManager.sharedInstance.plussScoreWhenCorrect
    var attemptsAtCurrentQuestion = 0
    var buttonValues = [0,0,0,0,0]
    var currentQuestion = ""
    var presentPopupView = false
    
    var pListToLoad = ""
    var appTaskId = 100
    var suffix = ""
    var popupVc = EndGamePopupViewController()
    
    var problemSet = ProblemSet(pListName: SettingsManager.sharedInstance.freeProblemSetsPlists[0])
    
    // MARK: Setup
    
    override func viewWillAppear(_ animated: Bool) {
        
        correct = 0
        wrong = 0
        presentPopupView = true
        answerButtons = [buttonOne, buttonTwo, buttonThree, buttonFour]
        popupVc = self.storyboard?.instantiateViewController(withIdentifier: "EndGamePopupViewController")  as! EndGamePopupViewController
        progressTimer.isHidden = false

        
        extraTimelabel.text = NSLocalizedString("Correct, pluss one second!",comment: "Correct title")
        lessTimelabel.text = NSLocalizedString("Wrong, minus two seconds!",comment: "Wrong title")
        startMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTimer.transform = progressTimer.transform.scaledBy(x: 1, y: 6)
        
        buttonOne.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonTwo.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonThree.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonFour.titleLabel?.adjustsFontSizeToFitWidth = true
        
        startButton.setTitle(NSLocalizedString("Start",comment: "Start title"), for: UIControlState())
        
        if (sm.sound) {
            tapSound = setupAudioPlayerWithFile(sm.tapSound as NSString, type: "wav")
            errorSound = setupAudioPlayerWithFile(sm.errorSound as NSString, type: "wav")
            correctSound = setupAudioPlayerWithFile(sm.correctSound as NSString, type: "wav")
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentPopupView = false
        timer.invalidate()
        progressTimer.isHidden = true
    }
    
    
    
    // MARK: Startup
    // Starts a new game, one game has many rounds
    func startNewGame() {
        buttonSwitch(true)
        extraTimelabel.isHidden = true
        lessTimelabel.isHidden = true
        timeLeft = totalTime
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(GameViewController.update), userInfo: nil, repeats: true)
        score = 0;
        round = 0;
        progressTimer.progress = 1.0;

        problemSet = ProblemSet(pListName: pListToLoad)
            startNewRound()
        }
    
    
    func buttonSwitch(_ startVisible: Bool){
        startButton.isHidden = startVisible
        buttonOne.isHidden = !startVisible
        buttonTwo.isHidden = !startVisible
        buttonThree.isHidden = !startVisible
        buttonFour.isHidden = !startVisible
        imageView.isHidden = !startVisible
    }
    

    
    
    
    // Starts a new round
    func startNewRound() {
        Kapabel.instance.startTask(appTaskId)
        
        round += 1
        attemptsAtCurrentQuestion = 0
        updateLabels()
        setUpNewQuestion()

    }
    
    func startMode() {
        score = 0
        updateLabels()
        buttonSwitch(false)
        progressTimer.progress = 1.0;
        extraTimelabel.isHidden = true
        lessTimelabel.isHidden = true
        questionLabel.text = NSLocalizedString("Get ready for Quiz!",comment: "Start question")
        
    }
    
    // MARK: Logic
    func updateLabels() {
        scoreLabel.text = "" + String(score)
        checkThatNotAllButtonsAreRed()
        }
    
    
    func checkThatNotAllButtonsAreRed() {
        var i = 0
        for button in answerButtons{
            if (button.isUserInteractionEnabled == false){
                i += 1
            }
        }
        
        // If someone taps like crazy all button can turn red
        // If it does we will set all buttons back to normal again
        var j = 0
        if (i == 4) {
            for button in answerButtons{
                button.setTitle(String(problemSet.alternatives[j]), for: UIControlState())
                button.setBackgroundImage(UIImage(named: "btn_blue\(suffix)"), for: UIControlState())
                button.isUserInteractionEnabled = true
                j += 1
                }
            
        }
    }
    

    // Sets up new question in the View
    func setUpNewQuestion(){
        
        questionLabel.text = problemSet.randomQuestion()
        if (problemSet.image != ""){
            imageView.image = UIImage(named: problemSet.image)
            imageView.isHidden = false
        }
        else {
            imageView.isHidden = true
        }
        
        var i = 0;

        for button in answerButtons{
            button.setTitle(String(problemSet.alternatives[i]), for: UIControlState())
            button.setBackgroundImage(UIImage(named: "btn_blue\(suffix)"), for: UIControlState())
            button.isUserInteractionEnabled = true
            i += 1
        }
        
        delay(0.15) {
            for button in self.answerButtons{
            button.isHidden = false
            }
        }
  }
    
    
    
    // Checks if tapped answer is correct
    // Modified to work with Strings
    func checkAnswer(_ button: UIButton) {
        if let text = button.titleLabel?.text {
        
            let a = text
 
            if (a == problemSet.correct){
                if (sm.sound) { correctSound.play() }
            if (timeLeft < totalTime) {
                    timeLeft = timeLeft + plussTimeWhenCorrect
                
                    extraTimelabel.isHidden = false
                delay(0.5){
                        self.extraTimelabel.isHidden = true
                }
                
            }
            button.setBackgroundImage(UIImage(named: "btn_green\(suffix)"), for: UIControlState())
            score = score + plussScoreWhenCorrect
            correct += 1
            var currentTaskScore = (4.0 - Double(attemptsAtCurrentQuestion)) / 4.0
                if (currentTaskScore < 0.0){
                    currentTaskScore = 0.0
                }
            Kapabel.instance.endTask(currentTaskScore)
            startNewRound()
    
            }
            else {
                if (sm.sound) { errorSound.play() }
            attemptsAtCurrentQuestion += 1
            button.setBackgroundImage(UIImage(named: "btn_red\(suffix)"), for: UIControlState())
            button.isUserInteractionEnabled = false
                
                if (timeLeft > minusTimeWhenWrong) {
                    timeLeft = timeLeft - minusTimeWhenWrong
                    lessTimelabel.isHidden = false
                    delay(0.5){
                        self.lessTimelabel.isHidden = true
                    }
                    
                }
                if (score>minusScoreWhenWrong){
                    wrong += 1
                    score = score - minusScoreWhenWrong
                }
            updateLabels()
            }
    
        }
    }
    
    // Updates progress timer
    func update() {
        timeLeft = timeLeft - 0.05
        if(timeLeft > 0.0)
        {
            progressTimer.progress = float_t((timeLeft / totalTime))
        }
        else{
            timer.invalidate()
            if (presentPopupView){
                presentPopup()
            }
            
            
        }
        
    }
    
    // Displayed when time runs out
    func presentPopup(){
        popupVc.modalPresentationStyle = UIModalPresentationStyle.formSheet
        popupVc.delegate = self
        popupVc.currentScore = score
        popupVc.correct = correct
        popupVc.wrong = wrong
        popupVc.currentActivity = pListToLoad
        self.present(popupVc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func startButtonTapped() {
        if (sm.sound) { tapSound.play() }
        startNewGame()
    }
    
    
    // MARK: Other
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    

    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    

    
}





