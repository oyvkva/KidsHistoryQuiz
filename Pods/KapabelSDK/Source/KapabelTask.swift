//
//  KapabelTask.swift
//  KapabelSDK
//
//  Created by Øyvind Kvanes on 18/01/2017.
//  Copyright © 2017 Kvanes AS. All rights reserved.
//

import Foundation

open class KapabelTask: NSObject{
    

    
    var token = ""
    var userName = ""
    var appTaskID = 0
    var sessionID = 0
    var result = 0.0
    var startTime = 0.0
    var endTime = 0.0
    var closed = false
    var added = false
    
    
    init(appTaskID: Int, sessionID: Int, token: String, userName: String) {
        super.init()
        self.appTaskID = appTaskID
        self.sessionID = sessionID
        self.token = token
        self.userName = userName
        self.startTime = NSDate().timeIntervalSince1970
    }
    
  
    init(data: [String: AnyObject]) {
        if let t = data["token"] as? String {
            token = t
        }
        if let u = data["userName"] as? String {
            userName = u
        }
        if let a = data["appTaskID"] as? String {
            appTaskID = Int(a)!
        }
        if let s = data["sessionID"] as? String {
            sessionID = Int(s)!
        }
        if let r = data["result"] as? String {
            result = Double(r)!
        }
        if let st = data["startTime"] as? String {
            startTime = Double(st)!
        }
        if let e = data["endTime"] as? String {
            endTime = Double(e)!
        }
    }
    
    func closeWith(result: Double){
        if !closed {
            self.result = result
            self.endTime = NSDate().timeIntervalSince1970
            self.closed = true
        } else {
            print("KapabelTask: Task already closed")
        }
    }
    
    func data() -> Dictionary<String, String> {
        
        let t = self.token
        let u = self.userName
        let a = String(self.appTaskID)
        let s = String(self.sessionID)
        let r = String(self.result)
        let st = String(self.startTime)
        let e = String(self.endTime)
        
        
        return ["token":t, "userName":u, "appTaskID":a, "sessionID":s, "result":r, "startTime":st, "endTime":e]
    }
    
    
    
    
    
}
