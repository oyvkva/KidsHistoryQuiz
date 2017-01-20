//
//  LevelSelectViewController.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/3/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit

class LevelSelectViewController: UITableViewController {
    
    var products = [SKProduct]()
    var sm = SettingsManager.sharedInstance
    
    
    var tapSound: AVAudioPlayer!
    var vc = GameViewController()
    let basicCellIdentifier = "CategoryCell"
    
    var data = SettingsManager.sharedInstance.freeProblemSetsPlists
    var pListNames = SettingsManager.sharedInstance.freeProblemSetsPlists
    var appTaskList = SettingsManager.sharedInstance.appTaskList

    
    
    // MARK: - Setup
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(netHex:0x437ba2)
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        self.tableView.rowHeight = CGFloat(Int(UIScreen.main.bounds.size.height / 10.0))
        title = NSLocalizedString("Categories",comment: "Categories text")
        
 
        if (sm.sound) { tapSound = setupAudioPlayerWithFile(sm.tapSound as NSString, type: "wav") }
        
    }

    
    
    
    
    
    
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count + data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func basicCellAtIndexPath(_ indexPath:IndexPath) -> CategoryCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier) as! CategoryCell

        cell.icon.image = UIImage(named: sm.categoryIcons[indexPath.row])
        let score = HighscoreManager.sharedInstance.getHighscoreArrayForActivity(pListNames[indexPath.row])[0] as Int
        let highscoreString = NSLocalizedString("Highscore",comment: "Highscore text")
        cell.topsubtitleLabel.text = "\(highscoreString): \(score)"
        let percentage = HighscoreManager.sharedInstance.getPercentForActivity(pListNames[indexPath.row])
        let correctString = NSLocalizedString("Correct",comment: "Highscore text")
        cell.bottomsubtitleLabel.text = "\(correctString): \(percentage)%"
        if (indexPath.row >= data.count){
            setupProductCell(cell, indexPath:indexPath)
        }
        else {
            setupCategoryCell(cell, indexPath:indexPath)
        }
        
        return cell
    }
    
    
    func setupCategoryCell(_ cell:CategoryCell, indexPath:IndexPath) {
        cell.titleLabel.text = sm.freeCategoryNames[indexPath.row]
        cell.priceLabel.isHidden = true
        cell.backgroundColor = UIColor(netHex:sm.categoryColors[indexPath.row])
    }
    
    
    func setupProductCell(_ cell:CategoryCell, indexPath:IndexPath) {
        
        let product = products[indexPath.row - data.count]
        cell.titleLabel.text = product.localizedTitle
        cell.backgroundColor = UIColor(netHex:sm.categoryColors[indexPath.row])
        
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sm.sound) { tapSound.play() }
        if (indexPath.row >= data.count){
            // Paid products
        }
        else {
            // Free categories we can start right away
            startCategory(indexPath.row)
        }
    }
    
    // MARK: Logic
    
    
    func startCategory(_ categoryNumber: Int){
        
        var suffix = ""
        var gameControllerID = "GameViewController"
        if (sm.categoryLayouts[categoryNumber] == "rectangles"){
            gameControllerID = "GameViewControllerTwo"
            suffix = "_long"
        }
        
        
        vc = self.storyboard?.instantiateViewController(withIdentifier: gameControllerID)  as! GameViewController
        vc.pListToLoad = pListNames[categoryNumber]
        vc.appTaskId = appTaskList[categoryNumber]
        vc.suffix = suffix
        
        
        
        
        self.navigationController!.pushViewController(vc, animated: true)
    }

    
    
    
    // MARK: In-App Purchases Methods
    
    

    
    
    
    // Fetch the products from iTunes connect, redisplay the table on successful completion
    func reload() {
        products = []
        tableView.reloadData()
    }
    
 
    
 
    
    // MARK: Other
    
    override var prefersStatusBarHidden : Bool {
        return true
    }


}
