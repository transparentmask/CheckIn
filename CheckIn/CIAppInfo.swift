//
//  CIAppInfo.swift
//  CheckIn
//
//  Created by Martin Yin on 10/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class CIAppInfo: NSObject, NSCoding {
    
    var id: String? = nil
    var name: String? = nil
    var icon: UIImage? = nil
    var iconURL: String? = nil {
        didSet {
            if let iconURL = iconURL, let url = URL(string: iconURL) {
                SDWebImageManager.shared().downloadImage(with: url, options: .avoidAutoSetImage, progress: nil, completed: { (image, error, cacheType, finished, _) in
                    self.icon = image
                })
            }
        }
    }
    var url: String? = nil
    var alreadyOpen: Bool {
        get {
            return Calendar.current.isDateInToday(Date(timeIntervalSince1970: checkinTime))
        }
    }
    var checkinTime: TimeInterval = 0

    override var description: String {
        return "id: \(id!); name: \(name!); icon: \(iconURL!); url: \(url!)"
    }
    
    override var debugDescription: String {
        return description
    }

    override init() {
        super.init()
    }
    
    convenience init(appInfo: JSON) {
        self.init()
        
        id = appInfo["id"].string
        name = appInfo["name"].string
        iconURL = appInfo["icon"].string
        url = appInfo["url"].string
        if let time = appInfo["checkinTime"].double {
            checkinTime = time
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.iconURL = aDecoder.decodeObject(forKey: "iconURL") as? String
        self.url = aDecoder.decodeObject(forKey: "url") as? String
        self.checkinTime = aDecoder.decodeObject(forKey: "checkinTime") as! TimeInterval
    }
    
    func encode(with aCoder: NSCoder) {
        if let id = id {
            aCoder.encode(id, forKey: "id")
        }
        if let name = name {
            aCoder.encode(name, forKey: "name")
        }
        if let iconURL = iconURL {
            aCoder.encode(iconURL, forKey: "iconURL")
        }
        if let url = url {
            aCoder.encode(url, forKey: "url")
        }
        aCoder.encode(checkinTime, forKey: "checkinTime")
    }
    
    func dictionary() -> Dictionary<String, Any> {
        return ["id": id!, "name": name!, "icon": iconURL!, "url": url!, "checkinTime": checkinTime]
    }
    
    func open(_ completion: ((Bool) -> Swift.Void)? = nil) {
        if let url = url, let appURL = URL(string: url) {
            UIApplication.shared.open(appURL, completionHandler: { result in
                if result {
                    self.checkinTime = Date().timeIntervalSince1970
                }
                if let completion = completion {
                    completion(result)
                }
            })
        }
    }
}
