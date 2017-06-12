//
//  CIAllAppsListViewController.swift
//  CheckIn
//
//  Created by Martin Yin on 11/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import UIKit
import BEMCheckBox

class CIAppCollectionCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView? = nil
    @IBOutlet var titleLabel: UILabel? = nil
    @IBOutlet var checkmarkView: BEMCheckBox? = nil
    @IBOutlet var updateImageView: UIImageView? = nil
    
    override func prepareForReuse() {
        imageView?.layer.cornerRadius = 4
        
        checkmarkView?.onAnimationType = .oneStroke
        checkmarkView?.offAnimationType = .oneStroke
    }
    
    func fillWithApp(appInfo: CIAppInfo, indexPath: IndexPath) {
        titleLabel?.text = appInfo.name
        if let iconURL = appInfo.iconURL, let url = URL(string: iconURL) {
            imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultIcon"))
        }
        
        checkmarkView?.tag = indexPath.item
    }
}

class CIAllAppsListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, BEMCheckBoxDelegate {
    
    @IBOutlet var collectionView: UICollectionView? = nil
    @IBOutlet var refreshButton: UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 90)
        
        let itemsInLine = floorf(Float(view.frame.size.width / layout.itemSize.width))
        let spacing = (view.frame.size.width - (CGFloat(itemsInLine) * layout.itemSize.width)) / CGFloat(itemsInLine + 1)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsetsMake(0, spacing, 0, spacing)
        collectionView?.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func doRefreshList(_ sender: Any) {
        refreshButton?.isEnabled = false
        CIAllAppsList.shared.update { result in
            self.refreshButton?.isEnabled = true
            self.collectionView?.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIAllAppsList.shared.allApps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CIAppCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CIAppCollectionCell", for: indexPath) as! CIAppCollectionCell
        
        let app = CIAllAppsList.shared.allApps[indexPath.item]
        cell.fillWithApp(appInfo: app, indexPath: indexPath)
        let appInLocalList = CILocalApps.shared.isAppInLocalList(app)
        cell.checkmarkView?.on = appInLocalList
        cell.checkmarkView?.delegate = self
        cell.updateImageView?.isHidden = !appInLocalList || CILocalApps.shared.isAppSameInLocalList(app)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let app = CIAllAppsList.shared.allApps[indexPath.item]
        
        if CILocalApps.shared.isAppInLocalList(app) {
            if CILocalApps.shared.isAppSameInLocalList(app) {
                CILocalApps.shared.removeAppFromList(app)
            }
            else {
                CILocalApps.shared.updateAppInfo(app)
            }
        }
        else {
            CILocalApps.shared.allApps.append(app)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        let indexPath = IndexPath(item: checkBox.tag, section: 0)
        collectionView(collectionView!, didSelectItemAt: indexPath)
    }
}
