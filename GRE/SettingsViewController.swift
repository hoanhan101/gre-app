//
//  SettingsViewController.swift
//  GRE
//
//  Created by Hoanh An on 7/13/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    @IBOutlet weak var vNavigationBar: UIView!
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var tbvButton: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    
    var loadingIndicator : UIActivityIndicatorView!
    var cards : [Card]!
    override func viewWillAppear(animated: Bool) {
        UIView.animateWithDuration(0.2) {
            self.navigationController!.navigationBar.barTintColor = .whiteColor();
            self.navigationController!.navigationBar.tintColor = .blackColor();
        }
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)

        cards = DB.getAllCards()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvButton.tableFooterView = UIView()
        
        print("sound \(DB.getSoundOn()) | random \(DB.getIsRandom())")
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 3
        }
        else{
            return 1
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0,0,self.view.bounds.width,40))
        let border = UIView(frame: CGRectMake(0,headerView.frame.size.height - 1,self.view.bounds.width,0.5))
        border.backgroundColor = tableView.separatorColor
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        headerView.addSubview(border)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            if(indexPath.row == CELL_TYPE_SWITCH_SOUND){
                
                var cell:SwitchCell! = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as? SwitchCell
                if (cell == nil) {
                    tableView.registerNib(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
                    cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as? SwitchCell
                }
                cell.setCellType(CELL_TYPE_SWITCH_SOUND)
                return cell
                
            }else if(indexPath.row == CELL_TYPE_SWITCH_RANDOM){
                
                var cell:SwitchCell! = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as? SwitchCell
                if (cell == nil) {
                    tableView.registerNib(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
                    cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as? SwitchCell
                }
                cell.setCellType(CELL_TYPE_SWITCH_RANDOM)
                return cell
            }
            else{
                
                var cell:ButtonCell! = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as? ButtonCell
                if (cell == nil) {
                    tableView.registerNib(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
                    cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as? ButtonCell
                }
                cell.lblTitle.text = "Reset Data"
                return cell
            }
        }
        else{
            var cell:ButtonCell! = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as? ButtonCell
            if (cell == nil) {
                tableView.registerNib(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
                cell = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as? ButtonCell
            }
            cell.lblTitle.text = "Rate App"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 2 && indexPath.section == 0){
            let alert: UIAlertView = UIAlertView.init(title: "Confirm", message: "Do you want reset your progress", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
            loadingIndicator.center = self.view.center;
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            // loadingIndicator.startAnimating()
            
            loadingIndicator.center = self.view.center
            self.view.addSubview(loadingIndicator)
            self.view.addSubview(alert)
            alert.show()
        }
        if(indexPath.section==1){
            print("RATE APP cmnd")
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            break
            
        case 1:
            
            resetData()
            break
            
        default:
            break
        }
    }
    func resetData(){
        UIView .animateWithDuration(1, animations: {
            self.loadingIndicator.startAnimating()
        }) { (complete) in
            var i = 0
            for card:Card in self.cards {
                if(card.tag != NEW_WORD_TAG){
                    DB.updateTag(card, tag: NEW_WORD_TAG)
                    i += 1
                    print("updating... \(Float(i)*100/Float(self.cards.count))%%")
                }
            }
            let  alertFinish = UIAlertView.init(title: "RESET DONE", message: "All cards were reset", delegate: nil, cancelButtonTitle: "OK")
            self.view.addSubview(alertFinish)
            self.loadingIndicator.stopAnimating()
            alertFinish.show()
            
        }
        
    }
    
    @IBAction func btnBackDidTap(sender: AnyObject) {
        
        let settingsVC : ListPackViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("ListPackViewController") as? ListPackViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.addAnimation(transition, forKey: kCATransition)
        presentViewController(settingsVC, animated: false, completion: nil)
        
    }
}
