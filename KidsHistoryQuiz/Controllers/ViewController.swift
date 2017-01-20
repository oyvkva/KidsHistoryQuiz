//
//  ViewController.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/3/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import KapabelSDK



class ViewController: UIViewController {
    
    @IBOutlet weak var kapabelButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var sm = SettingsManager.sharedInstance
    var tapSound: AVAudioPlayer!
    var gcAuthenticated = false
    
    // MARK: Setup
    override func viewDidLoad() {
 
        if (sm.sound) { tapSound = setupAudioPlayerWithFile(sm.tapSound as NSString, type: "wav") }
        
        
        playButton.setTitle(NSLocalizedString("Start",comment: "Play button"), for: UIControlState())
        kapabelButton.setTitle(NSLocalizedString("Kapabel",comment: "Kapabel button"), for: UIControlState())
        
        playButton.titleLabel?.adjustsFontSizeToFitWidth = true
        kapabelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
    }
    
    // MARK: Logic
    @IBAction func tapPlayButton(){
        if (sm.sound) { tapSound.play() }
    }

    
    
    @IBAction func loginToKapabel(){
        if (sm.sound) { tapSound.play() }
        Kapabel.instance.logInWithKapabel(sender: self)
    }

    
    @IBAction func soundOnOff(_ sender: UIButton) {
        
        if (sm.sound){
            sm.sound = false
            if let image = UIImage(named:"soundOFF.png") {
                sender.setImage(image, for:UIControlState())
            }
            
        }
        else {
            sm.sound = true
            tapSound.play()
            if let image = UIImage(named:"soundON.png") {
                sender.setImage(image, for:UIControlState())
            }
            
        }
    }
    
    //MARK: Other
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func EGCAuthentified(_ authentified:Bool) {
        gcAuthenticated = authentified
    }
   
}
// MARK: Color
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
