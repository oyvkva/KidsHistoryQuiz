//
//  KapabelUser.swift
//  Kapabel SDK
//
//  Created by Oyvind on 11/9/15.
//  Copyright © 2015 KvanesAS. All rights reserved.
//

import Foundation

open class KapabelUser: NSObject{
    var token : String!
    var fullName: String!
    var klasse: String!
    var email: String!
    var parentEmail: String!
    var imageName: String!
    var imageNumber: Int!
    var tasksDone: Int!
    var experience: Int!
    var errorCode: Int!
    
    fileprivate let MaxLevel = 25
    fileprivate let MaxProfiles = 50
    fileprivate let ExpLevelArray =       [
        0       ,//	1
        300     ,//	2
        900     ,//	3
        1900	,//	4
        3400	,//	5
        5500	,//	6
        8300	,//	7
        11900	,//	8
        16400	,//	9
        21900	,//	10
        28500	,//	11
        36300	,//	12
        45400	,//	13
        55900	,//	14
        67900	,//	15
        81500	,//	16
        96800	,//	17
        113900	,//	18
        132900	,//	19
        153900	,//	20
        177000	,//	21
        202300	,//	22
        229900	,//	23
        259900	,//	24
        500000	,//	25
    ]

    
    init(logInDict: NSDictionary) {
        super.init()
        if let val = logInDict["email"] {
            self.email = val as! String
        }
        
        if let val = logInDict["parent_email"] {
            self.parentEmail = val as! String
        }
        
        if let val = logInDict["klasse"] {
            self.klasse = val as! String
        }
        
        if let val = logInDict["token"] {
            self.token = val as! String
        }
        
        if let val = logInDict["tasks_done"] {
            self.tasksDone = val as! Int
        }
        
        if let val = logInDict["experience"] as? Int{
            self.experience = val
        } else {
            self.experience = 0
        }

        if let val = logInDict["name"] {
            self.fullName = val as! String
        }
        else {
            self.fullName = "No Name"
        }
        
        

        
        if let val = logInDict["imageid"] {
            if ((1 ... 50) ~= (val as! Int)){
                self.imageNumber = val as! Int
            }
            else {
                self.imageNumber = 1
            }
        }
        else {
            self.imageNumber = 1
        }
        
        self.imageName = imgWithBorder(id: self.imageNumber, lvl: KapLevel(experience: self.experience))
    }
    
    func KapLevel(experience: Int) -> Int{
        var theLevel = 0
        for limit in ExpLevelArray {
            if limit <= experience {
                theLevel += 1
            }
            else {
                break
            }
        }
        return theLevel
    }
    
    func imgWithBorder(id: Int, lvl: Int) -> String{
        if (0...MaxProfiles ~= id && 0...MaxLevel ~= lvl) {
            let border = lvl / 5 + 1
            return "kid\(id)_\(border).png"
        }
        else {
            return "kid1_1.png"
        }
    }
    
}
