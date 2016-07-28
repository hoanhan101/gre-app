//
//  SwitchCell.swift
//  GRE
//
//  Created by Hoanh An on 7/13/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnSwitch: UISwitch!
    
    let CELL_TYPE_SWITCH_SOUND : Int = 0
    let CELL_TYPE_SWITCH_RANDOM : Int = 1
    
    
    var typeCell: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.btnSwitch.onTintColor = .redColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    func setCellType(cellType: Int){
        typeCell = cellType
        if(typeCell == CELL_TYPE_SWITCH_SOUND){
            lblTitle.text = "Sound On"
            if(DB.getSoundOn()){
                self.btnSwitch .setOn(true, animated: false)
            }
            else{
                self.btnSwitch .setOn(false, animated: false)
            }
        }
        else
            if(typeCell == CELL_TYPE_SWITCH_RANDOM){
                lblTitle.text = "Random Cards"
                if(DB.getIsRandom()){
                    self.btnSwitch .setOn(true, animated: false)
                }
                else{
                    self.btnSwitch .setOn(false, animated: false)
                }
        }
    }
    @IBAction func btnSwitch(sender: AnyObject) {
        if(btnSwitch.on == true){
            switch  typeCell{
            case CELL_TYPE_SWITCH_SOUND:
                turnOnSound()
            case CELL_TYPE_SWITCH_RANDOM:
                turnOnRandom()
                break
            default:
                break
            }
        }
        else{
            switch  typeCell{
            case CELL_TYPE_SWITCH_SOUND:
                turnOffSound()
            case CELL_TYPE_SWITCH_RANDOM:
                turnOffRandom()
                break
            default:
                break
            }
            
        }
        print(" sound: \(DB.getSoundOn()) | random \(DB.getIsRandom())")
    }
    
    func turnOffSound(){
        DB.updateSetting(1, randomCard: -1)
    }
    
    func turnOnSound() {
        DB.updateSetting(0, randomCard: -1)
    }
    
    func turnOnRandom() {
        DB.updateSetting(-1, randomCard: 1)
    }
    
    func turnOffRandom() {
        DB.updateSetting(-1, randomCard: 0)
    }
}
