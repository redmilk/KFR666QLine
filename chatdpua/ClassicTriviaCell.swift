//
//  ClassicTriviaCell.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase
import IGListKit


class ClassicTriviaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer4: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCount: UILabel!
    
    var currentQuestion: ClassicTrivia!
    var gradient = CAGradientLayer()
    
    var alreadyLiked = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate func initNewQuestionNoAnimation(newQuestion: ClassicTrivia?) {
        if let newQuestion = newQuestion {
            currentQuestion = newQuestion
        }
    }
    
    fileprivate func answerQuestion(answer: String) -> Bool {
        let index = Generator_.classicTriviaPosts.index(of: currentQuestion!)
        let answer_ = currentQuestion.rightAnswer
        if let index = index {
            Generator_.classicTriviaPosts.remove(at: index)
        }
        return answer == answer_ ? true : false
    }
    
    func likeButtonStateLike() {
        likeButton.backgroundColor = .black
        likeButton.setTitle("♥️", for: .normal)
    }
    
    func noLikeButtonStateLike() {
        likeButton.backgroundColor = .black
        likeButton.setTitle("💟", for: .normal)
    }
    
    
    fileprivate func updateDatabaseIfRight() {
        
        let uid = Auth.auth().currentUser!.uid
        let answeredUserID: [String : Any] = [uid : true]
        DataBaseWithPosts.child(currentQuestion.postID!).child("usersAnswerRight").updateChildValues(answeredUserID)
        let answeredPostID: [String : Any] = [currentQuestion.postID! : true]
        DataBaseRef.child("users").child(uid).child("finishedQuestions").updateChildValues(answeredPostID)
        DataBaseRef.child("users").child(uid).child("score").runTransactionBlock({ (currentData) -> TransactionResult in
            var value = currentData.value as? Int
            
            if value == nil {
                value = 0
            }
            
            currentData.value = value! + 1
            
            //UserScoreLabel_?.text = (value! + 1).description
            
            return TransactionResult.success(withValue: currentData)
        })

    }
    
    @IBAction func answer1Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
        if result {
            updateDatabaseIfRight()
        }
    }
    @IBAction func answer2Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
        if result {
            updateDatabaseIfRight()
        }
    }
    @IBAction func answer3Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
        if result {
            updateDatabaseIfRight()
        }
    }
    @IBAction func answer4Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
        if result {
            updateDatabaseIfRight()
        }
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        if let postID = currentQuestion.postID {
            let uid = Auth.auth().currentUser!.uid
            
            DataBaseRef.child("likes").child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                /// if there is any user who liked the post
                if let usersWhoLiked = snapshot.value as? [String : AnyObject] {
                    
                    let thisUserAlreadyLikedThisPost = usersWhoLiked.contains(where: { (key, _) -> Bool in
                        return key == uid
                    })
                    if thisUserAlreadyLikedThisPost {
                        self.noLikeButtonStateLike()
                        self.likesCount.text = (Int(self.likesCount.text!)! - 1).description
                        DataBaseRef.child("likes").child(postID).child(uid).removeValue()
                        // delete like
                        DataBaseRef.child("posts").child(postID).child("likesCount").runTransactionBlock({ (currentData) -> TransactionResult in
                            var value = currentData.value as? Int
                            //print((value?.description)! + "<<<<<<<<----------:::::::::")
                            if value == nil {
                                value = 0
                            }
                            
                            if value! > 0 {
                                value! -= 1
                            }
                            
                            let likesCount: [String : Any] = ["likesCount" : self.likesCount.text!]
                            DataBaseRef.child("posts").child(postID).updateChildValues(likesCount)
                            
                            return TransactionResult.success(withValue: currentData)
                        })
                    } else {
                        // like the post
                        let postInfo: [String : Any] = [uid : true]
                        DataBaseRef.child("likes").child(postID).updateChildValues(postInfo)
                        self.likeButton.setTitle("♥️", for: .normal)
                        self.likesCount.text = (Int(self.likesCount.text!)! + 1).description
                        DataBaseRef.child("posts").child(postID).child("likesCount").runTransactionBlock({ (currentData) -> TransactionResult in
                            var value = currentData.value as? Int
                            
                            if value == nil {
                                value = 0
                            }
                            
                            value! += 1
                            
                            let likesCount: [String : Any] = ["likesCount" : self.likesCount.text!]
                            DataBaseRef.child("posts").child(postID).updateChildValues(likesCount)
                            return TransactionResult.success(withValue: currentData)
                        })
                    }
                } else {
                    let postInfo: [String : Any] = [uid : true]
                    DataBaseRef.child("likes").child(postID).updateChildValues(postInfo)
                    self.likeButton.setTitle("♥️", for: .normal)
                    self.likesCount.text = (Int(self.likesCount.text!)! + 1).description
                    DataBaseRef.child("posts").child(postID).child("likesCount").runTransactionBlock({ (currentData) -> TransactionResult in
                        var value = currentData.value as? Int
                        
                        if value == nil {
                            value = 0
                        }
                        
                        value! += 1
                        
                        let likesCount: [String : Any] = ["likesCount" : self.likesCount.text!]
                        DataBaseRef.child("posts").child(postID).updateChildValues(likesCount)
                        return TransactionResult.success(withValue: currentData)
                    })
                }
            })
            DataBaseRef.removeAllObservers()
        }
        
    }
    
}
