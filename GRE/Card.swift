//
//  Card.swift
//  GRE
//
//  Created by Hoanh An on 7/7/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import RealmSwift
class Card: Object {
    dynamic var word   : String = ""
    dynamic var type   : String = ""
    dynamic var script : String = ""
    dynamic var tag    : String = ""
    
    static func create(word: String, type: String, script: String, tag: String) -> Card {
        let newCard = Card()
        newCard.word = word
        newCard.type = type
        newCard.script = script
        newCard.tag = NEW_WORD_TAG
        DB.createCard(newCard)
        return newCard
    }
}
