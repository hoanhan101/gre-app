//
//  PackCard.swift
//  GRE
//
//  Created by Hoanh An on 7/7/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import Foundation
import RealmSwift

class PackCard:Object{
    dynamic var name              : String = ""
    dynamic var numberCard        : Int    = 0
    dynamic var numberMasterCard  : Int    = 0
    dynamic var numberReviewCard  : Int    = 0
    dynamic var numberLearningCard: Int    = 0
    var cards : List<Card> = List<Card>()
    
    static func create(name: String, cards : List<Card>) -> PackCard {
        let newPack = PackCard()
        newPack.name = name
        newPack.cards = cards
        newPack.numberCard = cards.count
        newPack.numberMasterCard = 0
        newPack.numberReviewCard = 0
        newPack.numberLearningCard = 0
        if(DB.getPackByName(name)==nil){
            DB.createPack(newPack)
        }
        return newPack
    }
}
