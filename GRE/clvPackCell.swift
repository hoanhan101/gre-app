//
//  clvPackCell.swift
//  GRE
//
//  Created by Hoanh An on 7/11/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import UIKit

class clvPackCell: UICollectionViewCell {
    
    @IBOutlet weak var lblRemaining: UILabel!
    @IBOutlet weak var progessDone: UIProgressView!
    @IBOutlet weak var imgDone: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 3.0;
    }
    func cellWith(pack : PackCard){
       // self.backgroundColor = COMMON1_PACK_COLOR
        lblTitle.text = pack.name;
        lblTotal.text = "\(pack.cards.count) cards in this pack"
        let numberMasterCard = DB.getNumberTagOfPack(pack, tag: MASTER_TAG)
        if(pack.cards.count == numberMasterCard){
            lblRemaining.text = "All cards mastered"
            imgDone.image = UIImage.init(named: "img-check")
        }
        else{
            lblRemaining.text = "\(pack.cards.count - numberMasterCard) remaining to master"
             imgDone.image = nil
        }
       progessDone.setProgress(Float(numberMasterCard)/Float(pack.cards.count), animated: false)
    }
}
