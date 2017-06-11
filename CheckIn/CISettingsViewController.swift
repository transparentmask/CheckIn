//
//  CISettingsViewController.swift
//  CheckIn
//
//  Created by Martin Yin on 31/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit
import UserNotifications
import SDWebImage

class CINotificationSwitchCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel? = nil
    @IBOutlet var switchControl: UISwitch? = nil
}

class CINotificationTimeCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var titleLabel: UILabel? = nil
    @IBOutlet var timePicker: UIPickerView? = nil
    
    var pickerHandler: ((Int) -> Void)? = nil
    
    var time: Int {
        get {
            if let timePicker = timePicker {
                return timePicker.selectedRow(inComponent: 0)
            }
            
            return 21
        }
        set {
            if let timePicker = timePicker {
                timePicker.selectRow(newValue, inComponent: 0, animated: false)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (component == 0) ? 24 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 60
        }
        else if component == 1 {
            return 20
        }
        else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(format: "%.2i", row)
        }
        else if component == 1 {
            return ":"
        }
        else {
            return "00"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerHandler = pickerHandler {
            pickerHandler(row)
        }
    }
}

class CINotificationConfirmCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel? = nil
}

class CISettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView? = nil
    @IBOutlet var versionLabel: UILabel? = nil
    @IBOutlet var copyrightLabel: UILabel? = nil
    
    var secretTapCount: Int = 0 {
        didSet {
            if secretTapCount >= 5 {
                secretTapCount = 0
                
//                SDWebImageManager.shared().downloadImage(with: URL(string: "https://nas.mask911.net/checkin/tao.php"), options: .avoidAutoSetImage, progress: nil, completed: { (image, error, cacheType, finished, _) in
//                    
//                    let backgroundView = UIView(frame: self.view.bounds)
//                    backgroundView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
//                    
//                    self.view.addSubview(backgroundView)
//                })
            }
        }
    }
    
    var usingLocalNotification: Bool = false {
        didSet {
            saveSettings()
            self.tableView?.reloadSections(IndexSet.init(integer: 0), with: .automatic)
        }
    }
//    var notificationTimes: [Int] = [21]
    var notificationTime: Int = 21 {
        didSet {
            saveSettings()
            self.tableView?.reloadSections(IndexSet.init(integer: 0), with: .automatic)
        }
    }
    
    var tmpTime: Int = 21 {
        didSet {
            if usingLocalNotification {
                self.tableView?.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadSettings()
        
        versionLabel?.text = "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
        copyrightLabel?.text = "© 2017 Martin & Vachell & 🍑"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSettings() {
        let userDefaults = UserDefaults.standard
        
        usingLocalNotification = userDefaults.bool(forKey: "CIUsingLocalNotification")
        if userDefaults.object(forKey: "CINotificationTime") != nil {
            notificationTime = userDefaults.integer(forKey: "CINotificationTime")
        }
//        if let times = userDefaults.array(forKey: "CINotificationTimes") as? [Int] {
//            self.notificationTimes.removeAll()
//            self.notificationTimes.append(contentsOf: times)
//        }
    }
    
    func saveSettings() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(usingLocalNotification, forKey: "CIUsingLocalNotification")
        userDefaults.set(notificationTime, forKey: "CINotificationTime")
//        userDefaults.set(notificationTimes, forKey: "CINotificationTimes")
        
        userDefaults.synchronize()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usingLocalNotification ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 1, section: 0) {
            return 100
        }
        
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == IndexPath(row: 0, section: 0) {
            let cell: CINotificationSwitchCell = tableView.dequeueReusableCell(withIdentifier: "CINotificationSwitchCell", for: indexPath) as! CINotificationSwitchCell
            
            cell.switchControl?.isOn = usingLocalNotification
            cell.switchControl?.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
            
            return cell
        }
        else if indexPath == IndexPath(row: 1, section: 0) {
            let cell: CINotificationTimeCell = tableView.dequeueReusableCell(withIdentifier: "CINotificationTimeCell", for: indexPath) as! CINotificationTimeCell
            
//            cell.time = notificationTimes.first!
            cell.time = notificationTime
            cell.pickerHandler = { time in
                self.tmpTime = time
            }
            
            return cell
        }
        else {
            let cell: CINotificationConfirmCell = tableView.dequeueReusableCell(withIdentifier: "CINotificationConfirmCell", for: indexPath) as! CINotificationConfirmCell
            
            cell.titleLabel?.textColor = (tmpTime == notificationTime) ? UIColor.darkGray : UIColor(red: 4.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1)
            cell.selectionStyle = (tmpTime == notificationTime) ? .none : .default
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == IndexPath(row: 2, section: 0) && tmpTime != notificationTime {
            processNotificationSettings()
        }
    }
    
    func notificationSwitchChanged(_ sender: Any) {
        usingLocalNotification = !usingLocalNotification
        
        let center = UNUserNotificationCenter.current()
//        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    self.processNotificationSettings()
                }
                else {
                    let alert = UIAlertController(title: "无法设置签到提醒", message: "请到系统设置中允许本程序使用通知服务", preferredStyle: .alert)
                    let doneAction = UIAlertAction(title: "知道了", style: .default, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                        self.usingLocalNotification = false
                    })
                    alert.addAction(doneAction)
                    self.navigationController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func processNotificationSettings() {
        if(usingLocalNotification) {
            notificationTime = tmpTime
            
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "CINotificationTitle", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "CINotificationBody", arguments: nil)
            content.sound = UNNotificationSound.default()
            
//            for time in notificationTimes {
//                var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: Date())
//                if let hour = dateComponents.hour, hour > time {
//                    dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: Date(timeIntervalSinceNow: 24*60*60))
//                }
//                dateComponents.hour = time
//                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//            }
            
//            var allIdentifiers: [String] = [String]()
//            for time in notificationTimes {
//                allIdentifiers.append("CINotification\(time)Hour")
//            }
//
//            if allIdentifiers.count > 0 {
//                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIdentifiers)
//                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: allIdentifiers)
//            }
            
            let allIdentifiers: [String] = ["CINotificationHour"]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIdentifiers)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: allIdentifiers)
            
//            for time in notificationTimes {
                var dateComponents = Calendar.current.dateComponents([.timeZone], from: Date())
                dateComponents.hour = notificationTime
            dateComponents.minute = 17
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "CINotificationHour", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if let error = error {
                        debugPrint(error)
                    }
                })
//            }
        }
        else {
            let allIdentifiers: [String] = ["CINotificationHour"]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIdentifiers)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: allIdentifiers)
        }
    }
    
    @IBAction func secretGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        let pointInFooterView = gesture.location(in: tableView?.tableFooterView)
        
        struct calculator {
            static var glyphRect: CGRect? = nil
        }
        
        if calculator.glyphRect == nil {
            if let copyrightLabel = copyrightLabel, let text = copyrightLabel.text, let attributedText = copyrightLabel.attributedText {
                let textStorage = NSTextStorage(attributedString: attributedText)
                
                let layoutManager = NSLayoutManager()
                textStorage.addLayoutManager(layoutManager)
                
                let textContainer = NSTextContainer(size: copyrightLabel.frame.size)
                layoutManager.addTextContainer(textContainer)
                textContainer.lineFragmentPadding = 0

                let textRange = (text as NSString).range(of: "🍑")
                let glyphRange = layoutManager.glyphRange(forCharacterRange: textRange, actualCharacterRange: nil)
                calculator.glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                calculator.glyphRect = calculator.glyphRect?.offsetBy(dx: copyrightLabel.frame.origin.x, dy: copyrightLabel.frame.origin.y)
                calculator.glyphRect = calculator.glyphRect?.insetBy(dx: -10, dy: -10)
            }
        }

        if let glyphRect = calculator.glyphRect, glyphRect.contains(pointInFooterView) {
            secretTapCount += 1
        }
        else {
            secretTapCount = 0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
