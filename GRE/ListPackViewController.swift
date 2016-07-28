//
//  ListPackViewController.swift
//  GRE
//
//  Created by Hoanh An on 7/7/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import RealmSwift

class ListPackViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var vCollection: UIView!
    @IBOutlet weak var btnSettings: UIButton!
    
    var collectionView:UICollectionView!
    var packs =  [PackCard]()
    @IBOutlet weak var clvPack: UICollectionView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIView.animateWithDuration(0.2) {
            self.navigationController!.navigationBar.barTintColor = .whiteColor();
        }
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        packs = DB.getAllPacks()
         clvPack.reloadData()
    }
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        clvPack.layoutIfNeeded()
        clvPack .reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dumpData()
        addBarButton()
        clvPack.registerNib(UINib.init(nibName: "clvPackCell", bundle: nil), forCellWithReuseIdentifier: "clvPackCell")
    }
    
    func configCollectionView() {
        self.view.layoutIfNeeded()
    }
    
    func addBarButton(){
        
        let title = UILabel.init(frame: CGRectMake(0, 0, 320, 40))
        title.textAlignment = .Left
        title.text = "Flash Cards"
        self.navigationItem.titleView = title
        
        
        let btnSettings : UIButton = UIButton.init(frame: CGRectMake(0, 0, 30, 30))
        btnSettings.setImage(UIImage.init(named: "img-settings"), forState: .Normal)
        btnSettings.addTarget(self, action: #selector(btnSettingsDidTap), forControlEvents: .TouchUpInside)
        let btnBarSettings : UIBarButtonItem = UIBarButtonItem.init(customView: btnSettings)
        self.navigationItem.setRightBarButtonItem(btnBarSettings, animated: true)
    }
    
    func dumpData() {
        if let file = NSBundle(forClass:AppDelegate.self).pathForResource("text", ofType: "txt") {
            let data = NSData(contentsOfFile: file)!
            let json = JSON(data:data)
            //print(json)
            for index in 0..<json.count{
                let name  = json[index]["name"].string!
                let cards = json[index]["card"]
                let listCard : List<Card> = List<Card>()
                for index in 0..<cards.count{
                    let word     = cards[index]["word"].string!
                    let type     = cards[index]["type"].string!
                    let script   = cards[index]["script"].string!
                    let tag      = cards[index]["tag"].string!
                    let newCard : Card = Card.create(word, type: type, script: script, tag: tag);
                    listCard.append(newCard)
                }
                //let newPack: PackCard = PackCard .create(name, cards:listCard)
                //packs.append(newPack)
                PackCard .create(name, cards:listCard)
            }
            packs = DB.getAllPacks()
            clvPack.reloadData()
            print("[List Pack]numberPacks : \(packs.count)")
        } else {
            print("file not exists")
        }
    }
    
    //MARK: CollectionView datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packs.count;
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let identifier = "clvPackCell"
        
        var cell: clvPackCell! = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? clvPackCell
        
        if (cell == nil) {
            collectionView.registerNib(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? clvPackCell
        }
        
        let selectedPack : PackCard = packs[indexPath.row]
        cell.backgroundColor = ColorGenarator.getColor(indexPath.row)
        cell.cellWith(selectedPack)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let width = collectionView.frame.size.width/2-12;
        let height = width*0.57;
        return CGSize.init(width:width, height: height);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8,0, 8) // margin between cells
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    //MARK: CollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let flashCard : FlashCardViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("FlashCardViewController") as? FlashCardViewController)!
        flashCard.currentPack = packs[indexPath.row]
        flashCard.packIndex = indexPath.row
        self.navigationController?.pushViewController(flashCard, animated: true)
    }
    
    //MARK: Button Settings
    
    @IBAction func btnSettingsDidTap(sender: AnyObject) {
        
        let settingsVC : SettingsViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    
}
