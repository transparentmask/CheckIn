//
//  AppDelegate.swift
//  CheckIn
//
//  Created by Martin Yin on 10/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        checkUpdate()
        
        _ = CIAllAppsList.shared
        if !FileManager.default.fileExists(atPath: CILocalApps.listFile.path) {
            try? FileManager.default.copyItem(at: Bundle.main.url(forResource: "apps", withExtension: "json")!, to: CILocalApps.listFile)
        }
        
        return true
    }
    
    func checkUpdate() {
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            configuration.urlCache = nil
            return SessionManager(configuration: configuration)
        }()
        
        manager.request("https://nas.mask911.net/checkin/update.json").responseData { response in
            if let data = response.result.value {
                let json = JSON(data)
                
                if let remoteVersion = json["version"].string, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let package = json["package"].string, let packageURL = URL(string: package), remoteVersion > version {
                    
                    let alert = UIAlertController(title: "发现新版本", message: "现在有个新版本: \(remoteVersion), 升级一下呗.", preferredStyle: .alert)
                    
                    if let force = json["force"].bool, force == true {
                    }
                    else {
                        let laterAction = UIAlertAction(title: "再说", style: .default, handler: { action in
                            alert.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(laterAction)
                    }

                    let updateAction = UIAlertAction(title: "升级去", style: .default, handler: { action in
                        DispatchQueue.main.async {
                            UIApplication.shared.open(packageURL, completionHandler: { result in
                                exit(0)
                            })
                        }
                    })
                    alert.addAction(updateAction)

                    if let tabbarController = self.window?.rootViewController as? UITabBarController, let viewController = tabbarController.selectedViewController {
                        viewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        CILocalApps.shared.saveList()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

