//
//  KapabelTaskManager.swift
//  KapabelSDK
//
//  Created by Øyvind Kvanes on 18/01/2017.
//  Copyright © 2017 Kvanes AS. All rights reserved.
//

import UIKit
import Alamofire

class KapabelTaskManager: NSObject {
    
    static let instance = KapabelTaskManager()
    
    var busy = false
    
    fileprivate var taskID = 0
    fileprivate var currentTask = KapabelTask(appTaskID: 0, sessionID: 0, token: "", userName: "")
    

    
    // MARK: Starting/stopping tasks
    
    // Starts a Kapabel task
    func startTask(appTaskID: Int){
        currentTask = KapabelTask(appTaskID: appTaskID, sessionID: SESSIONID, token: USERTOKEN, userName: USERNAME)
        
        logMs("Trying to start task for session \(SESSIONID) and appTask \(appTaskID)")
        
        let parameters = ["session_id": SESSIONID, "token": USERTOKEN] as [String : Any]
        let url = BaseURL + "register/" + String(appTaskID)
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers())
            .responseString { response in
                if let httpError = response.result.error {
                    errorWith(code: httpError._code)
                } else { //no errors
                    let statusCode = (response.response?.statusCode)!
                    if (statusCode == 200){
                        var dict = convertStringToDictionary(response.result.value!)
                        if (dict?["task_id"] != nil){
                            self.taskID = dict?["task_id"] as! Int
                            logMs("Started task \(self.taskID) in session \(SESSIONID)")
                        }  else if (dict?["error_code"] as? Int == 9){
                            logMs("Session belongs to other user, starting new session.")
                            Kapabel.instance.startSession(appTaskID)
                        }
                        else if let error = dict?["error_code"]{
                            errorWith(code: error as! Int)
                        }
                    } else {
                        errorWith(code: statusCode)
                    }
                }
        }
    }
    
    // Ends a Kapabel task
    func endTask(score: Double){
        currentTask.closeWith(result: score)
        let url = BaseURL + "register/" + String(taskID) + "/complete"
        let parameters = ["taskscore": score, "session_id": SESSIONID, "token": USERTOKEN] as [String : Any]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers())
            .responseString { response in
                
                if let httpError = response.result.error {
                    errorWith(code: httpError._code)
                    // WE ARE IN OFFLINE MODE
                    self.addTaskToTasksArray(task: self.currentTask)
                } else { //no errors
                    let statusCode = (response.response?.statusCode)!
                    if (statusCode == 200){
                        var dict = convertStringToDictionary(response.result.value!)
                        if let error = dict?["error_code"] as? Int{
                            if (error == 0){
                                logMs("Score submitted:\(score), TaskID:\(self.taskID)")
                            }
                            else {
                                errorWith(code: error)
                            }
                        }
                    } else {
                        errorWith(code: statusCode)
                    }
                }
        }
    }
    
    

    
    
    // MARK: Offline tasks
    
    // Submits all offline tasks
    func submitAllSavedTasks(){
        let tasksLeft = getTasksArrayCount()
        if tasksLeft > 1 {
            displaySubmitToast(tasksLeft: tasksLeft)
        }
        DispatchQueue.global(qos: .background).async {
            self.submitOfflineTask(tasksLeft: tasksLeft)
        }
    }
    
    // Submits one offline task
    func submitOfflineTask(tasksLeft: Int){
        busy = true
        let task = popLastTaskFromArray()
        let currentTasksLeft = tasksLeft - 1
        if task.appTaskID > 0 {
            
            if task.userName == USERNAME {
                task.token = USERTOKEN
            }
            
            submitTask(score: task.result, startTime: task.startTime, endTime: task.endTime, appTaskID: task.appTaskID, sessionID: task.sessionID, userToken: task.token, completionHandler: {
                (errorCode) in
                
                if (errorCode == 0){
                    logMs("Submitted task for \(task.userName), \(currentTasksLeft) tasks left")
                    self.submitOfflineTask(tasksLeft: currentTasksLeft)
                    if currentTasksLeft == 0 {
                        displaySubmitDoneToast()
                    }
                }
                else if (errorCode == -1009){
                    logMs("We are still offline")
                }
                else {
                    logMs("Error with old task for \(task.userName), moving on, \(currentTasksLeft) tasks left")
                    self.submitOfflineTask(tasksLeft: currentTasksLeft)
                    if currentTasksLeft == 0 {
                        displaySubmitDoneToast()
                    }
                }
            })
        }
        else {
            busy = false
        }
    }
    
    // Submits an offline task
    func submitTask(score: Double, startTime: Double, endTime: Double, appTaskID: Int, sessionID: Int, userToken: String, completionHandler: @escaping (Int) -> Void){
        
        logMs("Trying to submit task for session \(sessionID) and appTask \(appTaskID)")
        
        let parameters = ["taskscore": score, "created_at": startTime, "endtime": endTime, "session_id": sessionID, "token": userToken] as [String : Any]
        let url = BaseURL + "register/" + String(appTaskID) + "/submit"
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers())
            .responseString { response in
                DispatchQueue.main.async(execute: {
                    var errorCode = 100
                    if let httpError = response.result.error {
                        errorCode = httpError._code
                        errorWith(code: errorCode)
                    } else { //no errors
                        let statusCode = (response.response?.statusCode)!
                        if (statusCode == 200){
                            var dict = convertStringToDictionary(response.result.value!)
                            if let submittedTask = dict?["task_id"] as? Int{
                                errorCode = dict?["error_code"] as! Int
                                logMs("Submitted task \(submittedTask) in session \(sessionID) with result \(score)")
                            }
                            else if let error = dict?["error_code"] as? Int{
                                errorCode = error
                                errorWith(code: errorCode)
                            }
                        } else {
                            errorWith(code: statusCode)
                        }
                    }
                    completionHandler(errorCode)
                })
                
        }
    }

    

    
    // MARK: Saving and loading from UserDefaults
    
    // Gets the saved tasks from UserDefaults
    func getTasksArray() -> NSArray{
        
        if let temp = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: AppTaskListKey) as? NSArray {
            if temp.count > 0 {
                return temp
            }
            else {
                return [0]
            }
            
        }
        else {
            return [0]
        }
    }
    
    // Gets the saved tasks from UserDefaults
    func getTasksArrayCount() -> Int{
        if let temp = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: AppTaskListKey) as? NSArray {
            return temp.count
        }
        else {
            return 0
        }
    }
    
    // RemovesAllLocalTasks
    func clearTasksArray(){
        var accountsArray: [Dictionary<String,String>] = []
        if let temp = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: AppTaskListKey) as? Array<Any> {
            accountsArray = temp as! [Dictionary<String, String>]
        }
        accountsArray.removeAll()
        UserDefaults.init(suiteName: KAPGROUPNAME)!.set(accountsArray, forKey: AppTaskListKey)
    }
    
    // Adds new task to UserDefaults
    func addTaskToTasksArray(task: KapabelTask){
        if !task.added {
            var taskArray: [Dictionary<String,String>] = []
            if let temp = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: AppTaskListKey) as? Array<Any> {
                taskArray = temp as! [Dictionary<String, String>]
            }
            taskArray.append(task.data())
            UserDefaults.init(suiteName: KAPGROUPNAME)!.set(taskArray, forKey: AppTaskListKey)
            task.added = true
            logMs("Added task for \(task.userName) to offline Tasks")
        }
        else {
            logMs("Task already added")
        }
        
    }
    
    // Gets the last task from Array and removes it
    func popLastTaskFromArray() -> KapabelTask{
        
        if var temp = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: AppTaskListKey) as? Array<Any> {
            if temp.count > 0 {
                let lastTask = temp.removeLast()
                UserDefaults.init(suiteName: KAPGROUPNAME)!.set(temp, forKey: AppTaskListKey)
                return KapabelTask(data: lastTask as! [String: AnyObject])
            }
        }
        return KapabelTask(appTaskID: 0, sessionID: 0, token: "", userName: "")
    }
    
}
