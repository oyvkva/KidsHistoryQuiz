//
//  ProblemSet.swift
//  MatteKamp
//
//  Created by Oyvind on 11/4/15.
//  Copyright © 2015 KvanesAS. All rights reserved.
//

import Foundation

// Math ProblemSet loaded from pList with 5 alternatives, 1 being correct
class ProblemSet: NSObject{
    var pListName : String!
    var dict: NSDictionary!
    var alternatives = ["","","",""]
    var image = ""
    var correct = String()
    
    init(pListName: String) {
        super.init()
        self.pListName = pListName
        let path = Bundle.main.path(forResource: pListName, ofType: "plist")
        dict = NSDictionary(contentsOfFile: path!)!
        
    }

    
    // Loads a new random question
    // This version of the method uses Strings
    func randomQuestion() -> String{
        
        let x = UInt32(dict.count)
        let questionIndex = arc4random_uniform(x) + 1
        
        let questionDict:AnyObject = dict.object(forKey: String(questionIndex))! as AnyObject
        var question = "Question"
        let questionKey = NSLocalizedString("Question",comment: "QuestionKey")
        question = (questionDict.object(forKey: questionKey) as? String)!
        image = ""
        let imageKey = NSLocalizedString("Image",comment: "ImageKey")
        if let imageName = (questionDict.object(forKey: imageKey) as? String) {
            image = imageName
        }
        question = (questionDict.object(forKey: questionKey) as? String)!
        
        correct = (questionDict.object(forKey: "Correct") as? String)!
        alternatives[0] = correct;
        
        for index in 1...3 {
            let KeyNow = "Wrong" + String(index)
            alternatives[index] = (questionDict.object(forKey: KeyNow) as? String)!
        }
        alternatives = alternatives.shuffle()
        
        return question
    }
    
    // Checking if there are any wrong answers in the pList
    // This is only for math quizzes
    //func correctPList() -> Bool{
    
    
}

// MARK: Extensions to shuffle arrays

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count.toIntMax() - 1 {
            let j = Int(arc4random_uniform(UInt32(count.toIntMax() - i))) + i
            guard i != j else { continue }
            swap(&self[Int(i)], &self[Int(j)])
        }
    }
}
