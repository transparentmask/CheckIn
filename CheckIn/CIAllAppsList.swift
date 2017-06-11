//
//  CIAllAppsList.swift
//  CheckIn
//
//  Created by Martin Yin on 17/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

final class CIAllAppsList: NSObject {
    
    static let shared = CIAllAppsList()
    
    var allApps = [CIAppInfo]()
    var localUpdate: Date? = nil
    var updating: Bool = false
    
    let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return SessionManager(configuration: configuration)
    }()

    static var localListFile: URL! {
        get {
            return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("allApps.json")
        }
    }
    
    private override init() {
        super.init()
        
        if !readLocalList() {
            update()
        }
    }
    
    func readLocalList() -> Bool {
        if let data = try? Data(contentsOf: CIAllAppsList.localListFile) {
            localUpdate = Date(timeIntervalSinceNow: 0)
            allApps.removeAll()
            
            let json = JSON(data)
            if let update = json["update"].double {
                localUpdate = Date(timeIntervalSince1970: update)
            }
            if let apps = json["apps"].array {
                for app in apps {
                    allApps.append(CIAppInfo(appInfo: app))
                }
            }
            
            return true
        }
        
        return false
    }
    
    func queryRemoteList(_ completionHandler: @escaping (Bool) -> Void) {
        manager.request("https://nas.mask911.net/checkin/apps.php?c").responseData { response in
            if let data = response.result.value {
                try? data.write(to: CIAllAppsList.localListFile)
                completionHandler(true)
            }
            else {
                completionHandler(false)
            }
        }
    }
    
    func checkUpdate(_ completionHandler: @escaping (TimeInterval) -> Void) {
        manager.request("https://nas.mask911.net/checkin/apps.php?t").responseString { response in
            if let updateString = response.result.value, let updateTime = Double(updateString) {
                completionHandler(updateTime)
            }
            else {
                completionHandler(0)
            }
        }
    }
    
    func update(completionHandler: ((Bool) -> Void)? = nil) {
        updating = true
        queryRemoteList({result in
            if result {
                _ = self.readLocalList()
            }
            if let completionHandler = completionHandler {
                self.updating = false
                completionHandler(result)
            }
        })
    }

}
