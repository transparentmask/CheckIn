//
//  CIMainListViewController.swift
//  CheckIn
//
//  Created by Martin Yin on 10/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit

//class CIAppInfoCell: UITableViewCell {
//    
//    @IBOutlet var imageView: UIImageView?
//}

class CIMainListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView? = nil
    @IBOutlet var editButton: UIBarButtonItem? = nil
    @IBOutlet var startButton: UIBarButtonItem? = nil
    @IBOutlet var settingsButton: UIBarButtonItem? = nil
    @IBOutlet var addNewButton: UIButton? = nil
    
    var inCheckinLoop: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addNewButton?.isHidden = true
        addNewButton?.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView?.reloadData()
        startButton?.isEnabled = !CILocalApps.shared.isAllOpened()

        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func applicationDidBecomeActive(_ notification: NSNotification) {
        tableView?.reloadData()
        
        if inCheckinLoop {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.openApp({ result in
                    if !result {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.navigationItem.leftBarButtonItem?.isEnabled = true
                        
                        self.inCheckinLoop = false
                        
                        if CILocalApps.shared.isAllOpened() {
                            self.startButton?.isEnabled = false
                            
                            let alert = UIAlertController(title: "今日签到完毕", message: "记得明天再来哦!", preferredStyle: .alert)
                            let doneAction = UIAlertAction(title: "知道了", style: .default, handler: { action in
                                alert.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(doneAction)
                            self.navigationController?.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.startButton?.isEnabled = true
                            
                            self.showOpenError(CILocalApps.shared.uncheckinApp())
                        }
                    }
                })
            })
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        tableView?.setEditing(editing, animated: true)
        addNewButton?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.addNewButton?.alpha = editing ? 1 : 0
        }) { result in
            self.addNewButton?.isHidden = !editing
            
        }
        
        if editing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit(_:)))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishEdit(_:)))
        }
        else {
            navigationItem.leftBarButtonItem = editButton
            navigationItem.rightBarButtonItem = startButton
        }
        
        super.setEditing(editing, animated: animated)
    }
    
    @IBAction func doModifyList(_ sender: Any) {
        self.setEditing(true, animated: true)
    }

    @IBAction func doStartCheckIn(_ sender: Any) {
        openApp { result in
            if result {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                
                self.inCheckinLoop = true
            }
            else {
                self.showOpenError(CILocalApps.shared.uncheckinApp())
            }
        }
    }
    
    func openApp(_ completion: ((Bool) -> Swift.Void)? = nil) {
        if let app = CILocalApps.shared.uncheckinApp() {
            app.open(completion)
        }
        else if let completion = completion {
            completion(false)
        }
    }
    
    func showOpenError(_ appInfo: CIAppInfo? = nil) {
        let alert = UIAlertController(title: "出错啦", message: "可能是未知错误", preferredStyle: .alert)
        if let app = appInfo {
            alert.message = "\(app.name!) 无法打开"
        }
        let doneAction = UIAlertAction(title: "知道了", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(doneAction)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func cancelEdit(_ sender: Any) {
        self.setEditing(false, animated: true)
        
        CILocalApps.shared.loadList()
        tableView?.reloadData()
    }
    
    func finishEdit(_ sender: Any) {
        self.setEditing(false, animated: true)
        
        CILocalApps.shared.saveList()
        tableView?.reloadData()
    }
    
    @IBAction func doAddNewApp(_ sender: Any) {
        performSegue(withIdentifier: "ShowAddApp", sender: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddApp" {
        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CILocalApps.shared.allApps.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CIAppInfoCell", for: indexPath)

        let app = CILocalApps.shared.allApps[indexPath.row]
        if let iconURL = app.iconURL, let url = URL(string: iconURL) {
            cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultIcon"))
            cell.imageView?.layer.cornerRadius = 4
        }
        cell.textLabel?.text = app.name
        cell.accessoryType = app.alreadyOpen ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.detailButton

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = CILocalApps.shared.allApps[indexPath.row]
        app.open { result in
            if !result {
                self.showOpenError(app)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let app = CILocalApps.shared.allApps[indexPath.row]
        let alert = UIAlertController(title: app.name, message: "\(app.id!)\n\(app.url!)", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(doneAction)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CILocalApps.shared.allApps.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if !self.isEditing {
                CILocalApps.shared.saveList()
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let app = CILocalApps.shared.allApps.remove(at: sourceIndexPath.row)
        CILocalApps.shared.allApps.insert(app, at: destinationIndexPath.row)
    }

}

