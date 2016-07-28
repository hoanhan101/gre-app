//
//  FlashCardViewController.swift
//  GRE
//
//  Created by Hoanh An on 7/9/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import AVFoundation
import Spring

class FlashCardViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    @IBOutlet weak var vFlashCard: UIView!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblMaster: UILabel!
    @IBOutlet weak var lblLearning: UILabel!
    @IBOutlet weak var vProgress: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var btnNotKnew: UIButton!
    @IBOutlet weak var btnKnew: UIButton!
    @IBOutlet weak var vNavigationBar: UIView!
    @IBOutlet weak var vContent: UIView!
    
    var btnBarSound: UIButton! = nil
    
    var vMaster   : UIView!
    var vReview   : UIView!
    var vLearning : UIView!
    
    var frontFlashCard : FrontFlashCardViewModel!
    var backFlashCard  : BackFlashCardViewModel!
    var isFlip = false
    var currentCard = 0
    var cardCollection = [Card]()
    var currentPack : PackCard!
    var packIndex : Int!
    
    var soundOn = Variable(false)
    var numberOfLearning  : Variable<Int> = Variable(0)
    var numberOfReviewing : Variable<Int> = Variable(0)
    var numberOfMaster    : Variable<Int> = Variable(0)
    
    var synthesizer : AVSpeechSynthesizer!
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        updateLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        configColor()
    }
    override func viewWillDisappear(animated: Bool) {
        self.synthesizer.stopSpeakingAtBoundary(.Word)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configLayout()
        self.dumpData()
        self.soundOn.value = DB.getSoundOn()
        
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        
        self.frontFlashCard.card = self.cardCollection[self.currentCard]
        self.backFlashCard.card  = self.cardCollection[self.currentCard]
        
        numberOfMaster.value = DB.getNumberTagOfPack(self.currentPack, tag: MASTER_TAG)
        numberOfReviewing.value = DB.getNumberTagOfPack(self.currentPack, tag: REVIEW_TAG)
        numberOfLearning.value = DB.getNumberTagOfPack(self.currentPack, tag: LEARNING_TAG)
        
        vFlashCard.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init()
        _ = tapGesture.rx_event.subscribeNext {
            gestureReconizer in
            self.flipFlashCard()
        }
        self.vFlashCard.addGestureRecognizer(tapGesture)
        
        _ = self.soundOn.asObservable().subscribeNext{
            isOn in
            self.btnBarSound.userInteractionEnabled = isOn
            if isOn {
                self.btnBarSound.setImage(UIImage(named: "img-sound"), forState: .Normal)
            }
            else {
                self.btnBarSound.setImage(UIImage(named: "img-sound-mute"), forState: .Normal)
            }
            
        }
    }
    
    //MARK: Animation
    func flipFlashCard() {
        let frameBackCard = CGRectMake(0, 0, vFlashCard.layer.frame.size.width,
                                    self.backFlashCard.height)
        self.synthesizer.stopSpeakingAtBoundary(.Word)
        self.backFlashCard.frame = frameBackCard
        updateLayout()
        if !self.isFlip {
            UIView.transitionFromView(frontFlashCard, toView: backFlashCard, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            self.isFlip = true
        }
        else {
            UIView.transitionFromView(backFlashCard, toView: frontFlashCard, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            self.isFlip = false
        }
    }
    
    func nextCard(view : SpringView) {
        view.delay = 0.1
        view.velocity = 0.5
        view.animateNext {
            view.animation = "slideRight"
            view.animateTo()
            view.x = self.view.bounds.width + self.vFlashCard.bounds.width
            view.animateToNext {
                view.animate()
            }
            view.x = 0
            view.animateToNext {
                view.animateTo()
                self.setButtuonEnable(true)
            }
        }
    }
    
    //MARK: Config UI
    func configColor(){
        //set backgorund View
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        UIView .animateWithDuration(0.2) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            self.navigationController?.navigationBar.translucent = false
            self.vContent.backgroundColor = ColorGenarator.getColor(self.packIndex)
            self.navigationController!.navigationBar.barTintColor = ColorGenarator.getColor(self.packIndex);
            self.navigationController!.navigationBar.tintColor = .whiteColor();
            self.navigationItem.title = self.currentPack.name
            
        }
        
    }
    
    func updateLayout(){
        self.vFlashCard.layoutIfNeeded()
        self.vFlashCard.setNeedsLayout()
        self.backFlashCard.setNeedsLayout()
        self.backFlashCard.layoutIfNeeded()
        let frameFrontCard = CGRectMake(0, 0, self.vFlashCard.layer.frame.size.width,
                                        2*self.vFlashCard.layer.frame.size.height/3)
        self.frontFlashCard.frame = frameFrontCard
        self.backFlashCard.updateLayout()
    }
    
    func configLayout() {
        self.vFlashCard.layoutIfNeeded()
        
        // Load FrontFlashCardView
        self.frontFlashCard = NSBundle.mainBundle().loadNibNamed("FrontFlashCardView", owner: self, options: nil) [0] as! FrontFlashCardViewModel
        let frameFrontCard = CGRectMake(0, 0, self.vFlashCard.layer.frame.size.width,
                                        2*self.vFlashCard.layer.frame.size.height/3)
        self.frontFlashCard.frame = frameFrontCard
        self.vFlashCard.addSubview(self.frontFlashCard)
        
        // Load BackFlashCardView
        self.backFlashCard = NSBundle.mainBundle().loadNibNamed("BackFlashCardView", owner: self, options: nil) [0] as! BackFlashCardViewModel
        // Label progress
        self.vReview = UIView()
        self.vMaster = UIView()
        self.vLearning  = UIView()
        
        // Corner radius button
        self.btnKnew.layer.cornerRadius = self.btnKnew.frame.height/2
        self.btnNotKnew.layer.cornerRadius = self.btnNotKnew.frame.height/2
        
        _ = numberOfMaster.asObservable().subscribeNext {
            master in
            self.lblMaster.text = "\(master) Mastered"
            self.caculateProgressPhase(self.vMaster, color: MASTER_TAG_COLOR,
                origiX: 0, numberCard: master)
            self.updateProgressPhase(self.vReview, origiX: self.vMaster.frame.width,
                width: self.vReview.frame.width, height: self.vReview.frame.height)
            self.updateProgressPhase(self.vLearning, origiX: self.vMaster.frame.width +
                self.vReview.frame.width,
                width: self.vLearning.frame.width, height: self.vLearning.frame.height)
        }
        
        _ = numberOfReviewing.asObservable().subscribeNext {
            review in
            self.lblReview.text = "\(review) Reviewing"
            self.caculateProgressPhase(self.vReview, color: REVIEW_TAG_COLOR,
                origiX: self.vMaster.frame.width, numberCard: review)
            self.updateProgressPhase(self.vLearning, origiX: self.vMaster.frame.width +
                self.vReview.frame.width,
                width: self.vLearning.frame.width, height: self.vLearning.frame.height)
        }
        
        _ = numberOfLearning.asObservable().subscribeNext {
            learning in
            self.lblLearning.text = "\(learning) Learning"
            self.caculateProgressPhase(self.vLearning, color: LEARNING_TAG_COLOR,
                origiX: self.vReview.frame.width + self.vMaster.frame.width, numberCard: learning)
        }
        
        //add bar button
        addBarButton()
    }
    
    func addBarButton(){
        
        btnBarSound = UIButton.init(frame: CGRectMake(0, 0, 30, 30))
        btnBarSound.setImage(UIImage.init(named: "img-sound"), forState: .Normal)
        btnBarSound.addTarget(self, action: #selector(speakWordNonRx), forControlEvents: .TouchUpInside)
        let btnBar = UIBarButtonItem.init(customView: btnBarSound)
        self.navigationItem.setRightBarButtonItem(btnBar, animated: true)
    }
    
    func setButtuonEnable(enable : Bool) {
        self.btnNotKnew.userInteractionEnabled = enable
        self.btnKnew.userInteractionEnabled = enable
    }
    
    func caculateProgressPhase(view : UIView, color : UIColor, origiX : CGFloat, numberCard : Int) {
        let totalQuestion = self.cardCollection.count
        self.vProgress.layoutIfNeeded()
        let width = self.vProgress.layer.bounds.width
        let vHeight = self.vProgress.layer.bounds.height
        var vWidth : CGFloat = 0
        if numberCard != 0 {
            vWidth = CGFloat(numberCard)*width/CGFloat(totalQuestion)
        }
        
        let frame = CGRectMake(origiX, 0, vWidth, vHeight)
        view.frame = frame
        view.backgroundColor = color
        view.removeFromSuperview()
        self.vProgress.addSubview(view)
    }
    
    func updateProgressPhase(view : UIView, origiX : CGFloat, width : CGFloat, height : CGFloat) {
        let frame = CGRectMake(origiX, 0, width, height)
        view.frame = frame
    }
    
    //MARK: Dump data
    func dumpData() {
        
        for index in 0..<self.currentPack.cards.count {
            let jsonCard = self.currentPack.cards[index]
            let word     = jsonCard.word
            let type     = jsonCard.type
            let script   = jsonCard.script
            let tag      = jsonCard.tag
            
            if DB.getCardByWord(word) == nil {
                let card = Card.create(word, type: type, script: script, tag: tag)
                self.cardCollection.append(card)
            }
            else {
                self.cardCollection.append(DB.getCardInPack(self.currentPack, word: word))
            }
        }
        self.bindingData()
    }
    
    func bindingData() {
        
        _ = self.btnNotKnew.rx_tap.subscribeNext {
            UIView.transitionFromView(self.backFlashCard, toView: self.frontFlashCard, duration: 0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            self.setButtuonEnable(false)
            self.isFlip = false
            self.nextCard(self.frontFlashCard)
            self.synthesizer.stopSpeakingAtBoundary(.Word)
            self.isFlip = false
            let card = self.cardCollection[self.currentCard]
            if card.tag == MASTER_TAG {
                DB.updateTag(self.currentPack, word: card.word, tag: LEARNING_TAG)
                self.numberOfMaster.value -= 1
                self.numberOfLearning.value += 1
            }
            else if card.tag == REVIEW_TAG {
                DB.updateTag(self.currentPack, word: card.word, tag: LEARNING_TAG)
                self.numberOfReviewing.value -= 1
                self.numberOfLearning.value += 1
            }
            else if card.tag == NEW_WORD_TAG {
                DB.updateTag(self.currentPack, word: card.word, tag: LEARNING_TAG)
                self.numberOfLearning.value += 1
            }
            
            self.currentCard += 1
            if self.currentCard == self.cardCollection.count {
                self.currentCard = 0
            }
            self.frontFlashCard.card = self.cardCollection[self.currentCard]
            self.backFlashCard.card  = self.cardCollection[self.currentCard]
        }
        
        _ = self.btnKnew.rx_tap.subscribeNext {
            UIView.transitionFromView(self.backFlashCard, toView: self.frontFlashCard, duration: 0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            self.isFlip = false
            self.setButtuonEnable(false)
            self.nextCard(self.frontFlashCard)
            self.synthesizer.stopSpeakingAtBoundary(.Word)
            self.isFlip = false
            let card = self.cardCollection[self.currentCard]
            if card.tag == NEW_WORD_TAG {
                DB.updateTag(self.currentPack, word: card.word, tag: MASTER_TAG)
                self.numberOfMaster.value += 1
            }
            else if card.tag == REVIEW_TAG {
                DB.updateTag(self.currentPack, word: card.word, tag: MASTER_TAG)
                self.numberOfMaster.value += 1
                self.numberOfReviewing.value -= 1
            }
            else if card.tag == MASTER_TAG {
                
            }
            else if card.tag == LEARNING_TAG {
                DB.updateTag(self.currentPack, word: card.word, tag: REVIEW_TAG)
                self.numberOfReviewing.value += 1
                self.numberOfLearning.value  -= 1
            }
            
            self.currentCard += 1
            if self.currentCard == self.cardCollection.count {
                self.currentCard = 0
            }
            self.frontFlashCard.card = self.cardCollection[self.currentCard]
            self.backFlashCard.card  = self.cardCollection[self.currentCard]
        }
        
    }
    
    //MARK: Speak word
    
    func speakWordNonRx(){
        self.btnBarSound.userInteractionEnabled = false
        var text = ""
        if !self.isFlip {
            text = self.cardCollection[self.currentCard].word
        }
        else {
            let tags = ["strong","br"]
            text = "\(self.cardCollection[self.currentCard].type) \(self.cardCollection[self.currentCard].script)".deleteHTMLTags(tags)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.4
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synthesizer.speakUtterance(utterance)
    }
    // AVSpeach delegate
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        //self.btnSound.userInteractionEnabled = true
        self.btnBarSound.userInteractionEnabled = true
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didCancelSpeechUtterance utterance: AVSpeechUtterance) {
        //self.btnSound.userInteractionEnabled = true
        self.btnBarSound.userInteractionEnabled = true
    }
}
