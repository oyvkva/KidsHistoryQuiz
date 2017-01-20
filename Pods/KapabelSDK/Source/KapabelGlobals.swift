//
//  KapabelGlobals.swift
//  KapabelSDK
//
//  Created by Øyvind Kvanes on 19/01/2017.
//  Copyright © 2017 Kvanes AS. All rights reserved.
//

// Variables
var KAPLOG = false
var KAPTOAST = true
var KAPGATE = true
var KAPAPPID = 0
var KAPGROUPNAME = ""

var APITOKEN = ""
var USERTOKEN = ""
var USERNAME = ""
var SESSIONID = 0
var CURRENTUSER = KapabelUser(logInDict: ["token":"0"])

// Contants
let BaseURL = "https://kapabel.no/v1/api/"
let AppStoreURL = URL(string: "itms://itunes.apple.com/no/app/kapabel-for-students-parents/id1140067858?mt=8")
let SessionAliveTime = 3600.0 // Seconds a session stays alive until a new is created

// UserDefault keys
let AppTaskListKey = "TheKapabelTasks"
let TokenNameKey = "TheKapabelToken"
let SessionNameKey = "TheKapabelSession"
let SavedUserNameKey = "TheKapabelSavedUserName"
let SessionSaveDateKey = "TheKapabelSessionSaveDate"



// MARK: Helper methods

func errorWith(code: Int){
    if (code == 401){
        logMs("Wrong API key")
    }
    else if (code == 404){
        logMs("URL not found")
    }
    else if (code == 1){
        logMs("Wrong token, please log in again")
    }
    else if (code == 7){
        logMs("Task already closed")
    }
    else if (code == 14){
        logMs("TaskID does not exist")
    }
    else if (code == -1009){
        logMs("Offline mode for: \(USERNAME)")
    }
    else {
        logMs("Unknown error \(code)")
    }
    
}

func headers() -> [String: String]{
    return [
        "Authorization": "Token token=\(APITOKEN)",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
}

func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
    if let data = text.data(using: String.Encoding.utf8) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            return json
        } catch {
            logMs("Error converting string")
        }
    }
    return nil
}

func urlScheme() -> String {
    
    let info = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject]
    if let urlSchemes = info?[0]["CFBundleURLSchemes"]
    {
        
        
        if let schemes = urlSchemes as? NSArray{
            if schemes.count > 0 {
                return (schemes[0] as? String)!
            }
        }
    }
    return "http://kapabel.io"
}



// MARK: Logging
func logMs(_ msg: String){
    if (KAPLOG){
        print("KapabelSDK: \(msg)")
    }
}


// MARK: Toasts
func displayWelcomeToastFor(name: String) {
    if (KAPTOAST){
        let toastMessage = "\("Logged in as".kapLocalized) \(name)."
        KapabelToast.make(toastMessage).show()
    }
}

func displayErrorToast() {
    if (KAPTOAST){
        let toastMessage = "Login failed.".kapLocalized
        KapabelToast.make(toastMessage).show()
    }
}

func displayOfflineModeToastFor(user: String) {
    if (KAPTOAST){
        let toastMessage = "\("Results will be saved offline for".kapLocalized) \(user)."
        KapabelToast.make(toastMessage).show()
        
        let tasksLeft = KapabelTaskManager.instance.getTasksArrayCount()
        if tasksLeft > 1 {
            let toastMessage = "\("Offline results saved".kapLocalized): \(tasksLeft)"
            KapabelToast.make(toastMessage).show()
        }
        KapabelToast.make("The results will be submitted when you go online.".kapLocalized).show()
    }
}

func displayLoggedOutToast() {
    if (KAPTOAST){
        let toastMessage = "Not logged in. Please log in again.".kapLocalized
        KapabelToast.make(toastMessage).show()
    }
}

func displaySubmitToast(tasksLeft: Int) {
    if (KAPTOAST){
        let toastMessage = "\("Submitting".kapLocalized) \(tasksLeft) \("results".kapLocalized)..."
        KapabelToast.make(toastMessage).show()
    }
}

func displaySubmitDoneToast() {
    if (KAPTOAST){
        let toastMessage = "Results submitted.".kapLocalized
        KapabelToast.make(toastMessage).show()
    }
}


// MARK: String extension

extension String {
    var kapLocalized: String {
        return NSLocalizedString(self, tableName: "Kapabel", bundle: Bundle.main, value: "", comment: "")
    }
}
