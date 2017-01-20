//
//  HighscoreManager.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 11/3/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import Foundation
import GameKit

class HighscoreManager {
    let dictPrefix = "QuizTemplate"
    let dictPrefixCorrect = "QuizCorrect"
    let dictPrefixWrong = "QuizWrong"
    static let sharedInstance = HighscoreManager()
    
    // Get highscore array
    func getHighscoreArrayForActivity(_ activityName: String) -> [Int]{
        let dictName = dictPrefix + activityName
        if let temp = UserDefaults.standard.object(forKey: dictName) as? [Int] {
            return temp
        }
        else {
            return [0]
        }
    }
    
    // Updates score for activity
    func updateScore(_ activityName: String, levelNumber: Int, score: Int){
        let dictName = dictPrefix + activityName
        
        var tempScoresArray = [0]
        if let temp = UserDefaults.standard.object(forKey: dictName) as? [Int] {
            tempScoresArray = temp
        }
        
        if (levelNumber <= tempScoresArray.count){
            if (tempScoresArray[levelNumber-1] < score){
                tempScoresArray[levelNumber-1] = score
                print("Level \(levelNumber) score updated to \(score)")
            }
        }
        else{
            tempScoresArray.append(score)
            print("Level \(levelNumber) score created, the score is \(score)")
        }
        
        UserDefaults.standard.set(tempScoresArray, forKey: dictName)
   
        }
    
    // Updates percentage average for category
    func updateAverage(_ activityName: String, levelNumber: Int, correct: Int, wrong: Int){
        let dictNameCorrect = dictPrefixCorrect + activityName
        let dictNameWrong = dictPrefixWrong + activityName
        
        var correctArray = [0]
        if let correctA = UserDefaults.standard.object(forKey: dictNameCorrect) as? [Int] {
            correctArray = correctA
        }
        
        var wrongArray = [0]
        if let wrongA = UserDefaults.standard.object(forKey: dictNameWrong) as? [Int] {
            wrongArray = wrongA
        }
        
        if (levelNumber <= correctArray.count){
            correctArray[levelNumber-1] = correctArray[levelNumber-1] + correct
            
        }
        else{
            correctArray.append(correct)
        }
        
        if (levelNumber <= wrongArray.count){
            wrongArray[levelNumber-1] = wrongArray[levelNumber-1] + wrong
            
        }
        else{
            wrongArray.append(wrong)
        }
        
        UserDefaults.standard.set(correctArray, forKey: dictNameCorrect)
        UserDefaults.standard.set(wrongArray, forKey: dictNameWrong)
        
    }
    
    // Gets percent correct all time
    func getPercentForActivity(_ activityName: String) -> Int{
        let dictNameCorrect = dictPrefixCorrect + activityName
        let dictNameWrong = dictPrefixWrong + activityName
        
        var correctArray = [0]
        if let correctA = UserDefaults.standard.object(forKey: dictNameCorrect) as? [Int] {
            correctArray = correctA
        }
        
        var wrongArray = [0]
        if let wrongA = UserDefaults.standard.object(forKey: dictNameWrong) as? [Int] {
            wrongArray = wrongA
        }
        
        let totalAnswers = wrongArray[0] + correctArray[0]
        if (totalAnswers > 0){
            return Int(Float(correctArray[0]) / Float(totalAnswers) * 100.0)
        }
        else {
            return 0
        }
    }
    
    
    
}





