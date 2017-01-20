//
//  KapabelAPIManager.swift
//  Kapabel SDK
//
//  Created by Oyvind on 10/24/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//

import UIKit
import Alamofire

// All that is needed is to send start and end results with a token you get from the Kapabel App
// through deep linking.
open class Kapabel: NSObject {
    
    open static let instance = Kapabel()
  
    // Private variables
    fileprivate var GateCorrect = 0
    



    
    // MARK: Public methods used by Apps
    
    // Log in with Kapabel:
    // This opens the Kapabel App and let users log in.
    // They tap "OK" in the Kapabel App to accept the log in,
    // then they will be taken back to this app.
    // If KAPGATE is true it will show a parental gate before going to the AppStore.
    // This is needed for Made fo Kids apps.
    open func logInWithKapabel(sender: UIViewController){
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let spaceCount = appName.characters.filter{$0 == " "}.count
        if (spaceCount == 0){
            let url = URL(string: "kapabelio://\(urlScheme())/\(appName)")
            if(!UIApplication.shared.openURL(url!)){
                goToAppStore(sender:sender)
            }
        }
        else {
            print("Spaces in app-names does not work with Kapabel:")
            print(appName)
        }

    }
    
    
    // Save info from Kapabel:
    // This registers the information the Kapabel App sends back.
    // This information will then be saved to NSUserDefaults.
    // Next time you start this app, this information will be loaded
    // from NSUserDefaults so users don't need to log in again.
    open func saveInfo(userInfo: String){
  
        let queryArray = userInfo.components(separatedBy: "/")
        if queryArray.count == 4 {
            let newUserToken = queryArray[2]
 
            saveUserToken(newUserToken)
            savesessionID(sessionID: 0)
            UserDefaults.standard.synchronize()
            
            Kapabel.instance.checkStatus(completionHandler: {
                (responseUser, errorCode) in
            })
        }
        else {
            displayErrorToast()
        }
    }
    
    // Update
    // This pings Kapabel to get new information about he user with the registered token.
    // This is needed to update changed names, experience and other status.
    open func update(id: Int, token: String, appGroup: String){
        KAPAPPID = id
        APITOKEN = token
        KAPGROUPNAME = appGroup
        USERTOKEN = getSavedUserToken()
        SESSIONID = getSavedsessionID()
        USERNAME = getSavedUserName()
        
        Kapabel.instance.checkStatus(completionHandler: {
            (responseUser, errorCode) in
            
            if (errorCode == 0){
                USERNAME = responseUser.email
                displayWelcomeToastFor(name: responseUser.fullName)
                self.saveUserName(USERNAME)
                
                if !KapabelTaskManager.instance.busy {
                    KapabelTaskManager.instance.submitAllSavedTasks()
                }
            }
            else if (errorCode == -1009){
                displayOfflineModeToastFor(user: USERNAME)
            }
            else {
                displayLoggedOutToast()
            }
        })
    }
    
    
    // Start a task:
    // Use the AppTask IDs you have registered in the developer portal.
    // A new session will start every time the app is used.
    open func startTask(_ appTaskID: Int){
        if SESSIONID == 0 {
            startSession(appTaskID)
        } else {
            KapabelTaskManager.instance.startTask(appTaskID: appTaskID)
        }
    }
    
    // Send in result:
    // This sends in the result for the latest app started in the app.
    // You can only have one app task open at one time.
    open func endTask(_ score: Double){
        if 0.0...1.0 ~= score {
            KapabelTaskManager.instance.endTask(score: score)
        } else {
            logMs("Only scores between 0.0 and 1.0 are accepted, you sent: \(score)")
        }
    }
    
    // MARK: Change of settings
    open func parentalGate(_ on: Bool){
        KAPGATE = on
    }
    
    open func showToasts(_ on: Bool){
        KAPTOAST = on
    }
    
    open func showLog(_ on: Bool){
        KAPLOG = on
    }
    
    
    // MARK: Private methods used by Kapabel
    
    // Go to AppStore
    fileprivate func goToAppStore(sender: UIViewController){
        if KAPGATE {
            
            GateCorrect = Int(arc4random_uniform(UInt32(20)))
            let numberOne = Int(arc4random_uniform(UInt32(GateCorrect)))
            let numberTwo = GateCorrect - numberOne
            let question = "\"\(numberOne) + \(numberTwo) = ?\""
            
            let answerString = "Answer".kapLocalized
            let andTapString = "and tap the correct button.".kapLocalized
            
            let alert = UIAlertController(title: "\("Ask your parents".kapLocalized).", message: "\(answerString) \(question) \(andTapString)", preferredStyle: UIAlertControllerStyle.alert)
            
            var field = UITextField()
            
            func addTextField(_ textField: UITextField!){
                field = textField
            }
            
            alert.addTextField(configurationHandler: addTextField)
            alert.addAction(UIAlertAction(title: "Child".kapLocalized, style: UIAlertActionStyle.destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Adult".kapLocalized, style: UIAlertActionStyle.default, handler: { action in
                self.checkGateAnswer(field, sender: sender)
            }))
            alert.addAction(UIAlertAction(title: "Cancel".kapLocalized, style: UIAlertActionStyle.cancel, handler: nil))
            
            sender.present(alert, animated: true, completion: nil)
            
        }
        else {
            UIApplication.shared.openURL(AppStoreURL!)
        }
    }
    
    // Check parental gate before opening Kapabel
    fileprivate func checkGateAnswer(_ field: UITextField, sender: UIViewController){
        if let text = field.text , !text.isEmpty
        {
            if (Int(text) == GateCorrect){
                UIApplication.shared.openURL(AppStoreURL!)
            }
            else {
                goToAppStore(sender: sender)
            }
        }
        else {
            goToAppStore(sender: sender)
        }
    }
    
    // A session is started each time we log in via Kapabel
    func startSession(_ appTaskID: Int){

        let url = BaseURL + "session"
        let parameters = ["app_id": KAPAPPID, "token": USERTOKEN] as [String : Any]
        logMs("Trying start session with appID \(KAPAPPID)")
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers())
            .responseString { response in
                if let httpError = response.result.error {
                    errorWith(code: httpError._code)
                } else { //no errors
                    let statusCode = (response.response?.statusCode)!
                    if (statusCode == 200){
                        var dict = convertStringToDictionary(response.result.value!)
                        if (dict?["session_id"] != nil){
                            SESSIONID = dict?["session_id"] as! Int
                            logMs("Started session with id: \(SESSIONID)")
                            self.savesessionID(sessionID: SESSIONID)
                            KapabelTaskManager.instance.startTask(appTaskID: appTaskID)
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
    
        
    
    
    // This gets the User information from Kapabel
    fileprivate func checkStatus(completionHandler: @escaping (KapabelUser, Int) -> Void){
        
        let url = BaseURL + "status"
        let parameters = ["token": USERTOKEN]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers())
            .responseString { response in
                DispatchQueue.main.async(execute: {
                    var responseUser = KapabelUser(logInDict: ["token":"0"])
                    var errorCode = 100
                    if let httpError = response.result.error {
                        errorCode = httpError._code
                        errorWith(code: errorCode)
                    } else { //no errors
                        let statusCode = (response.response?.statusCode)!
                        if (statusCode == 200){
                            var dict = convertStringToDictionary(response.result.value!)
                            if let error = dict?["error_code"]{
                                errorCode = error as! Int
                            }
                            if errorCode == 0 {
                                responseUser = KapabelUser(logInDict: dict! as NSDictionary)
                                CURRENTUSER = responseUser
                            }
                            else {
                                errorWith(code: errorCode)
                            }
                        }
                        else {
                            errorWith(code: statusCode)
                        }
                    }
                    completionHandler(responseUser, errorCode)
                })
        }
    }
    
    
    // MARK: Saving /loading to UserDefaults in GROUPNAME
    fileprivate func saveUserToken(_ token: String){
        UserDefaults.init(suiteName: KAPGROUPNAME)!.set(token, forKey: TokenNameKey)
    }
    
    fileprivate func getSavedUserToken() -> String{
        if let token = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: TokenNameKey) as? String{
            return token
        }
        return ""
    }
    
    fileprivate func saveUserName(_ name: String){
        UserDefaults.init(suiteName: KAPGROUPNAME)!.set(name, forKey: SavedUserNameKey)
    }
    
    
    fileprivate func getSavedUserName() -> String{
        if let token = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: SavedUserNameKey) as? String{
            return token
        }
        return ""
    }
    
    fileprivate func savesessionID(sessionID: Int){
        UserDefaults.init(suiteName: KAPGROUPNAME)!.set(sessionID, forKey: SessionNameKey)
        UserDefaults.init(suiteName: KAPGROUPNAME)!.set(NSDate(), forKey: SessionSaveDateKey)
    }
    
    fileprivate func getSavedsessionID() -> Int{
        if let lastSavedDate = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: SessionSaveDateKey) as? Date{
            if NSDate().timeIntervalSince(lastSavedDate) < SessionAliveTime {
                if let sessionID = UserDefaults.init(suiteName: KAPGROUPNAME)!.object(forKey: SessionNameKey) as? Int{
                    return sessionID
                }
            }
        }
        return 0
    }
}


