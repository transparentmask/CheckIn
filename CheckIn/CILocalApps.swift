//
//  CILocalApps.swift
//  CheckIn
//
//  Created by Martin Yin on 29/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit
import SwiftyJSON

class CILocalApps: NSObject {
    
    static let shared = CILocalApps()
    
    var allApps = [CIAppInfo]()
    
    static var listFile: URL! {
        get {
            return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("localApps.json")
        }
    }
    
    private override init() {
        super.init()
        
        loadList()
    }
    
    func loadList() {
        if let data = try? Data(contentsOf: CILocalApps.listFile) {
            allApps.removeAll()
            
            let json = JSON(data)
            if let apps = json["apps"].array {
                for app in apps {
                    allApps.append(CIAppInfo(appInfo: app))
                }
            }
        }
    }
    
    func saveList() {
        var appJSONs = [JSON]()
        for app in allApps {
            appJSONs.append(JSON(app.dictionary()))
        }
        
        let json = JSON(dictionaryLiteral: ("apps", appJSONs))

        debugPrint(CILocalApps.listFile.path)
        if let jsonString = json.rawString() {
            debugPrint(jsonString)
            try! jsonString.write(to: CILocalApps.listFile, atomically: true, encoding: .utf8)
        }
    }

    func isAllOpened() -> Bool {
        var allOpened = true
        allApps.forEach { app in
            if !app.alreadyOpen {
                allOpened = false
            }
        }
        
        return allOpened
    }
    
    func uncheckinApp() -> CIAppInfo? {
        for app in allApps {
            if !app.alreadyOpen {
                return app
            }
        }
        
        return nil
    }
    
    func isAppInLocalList(appInfo: CIAppInfo) -> Bool {
        for app in allApps {
            if app.id == appInfo.id {
                return true
            }
        }
        
        return false
    }
    
    func removeAppFromList(appInfo: CIAppInfo) {
        for (index, app) in allApps.enumerated() {
            if app.id == appInfo.id {
                allApps.remove(at: index)
                break
            }
        }
    }
}
