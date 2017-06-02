//
//  TrueFalseCell.swift
//  chatdpua
//
//  Created by Artem on 5/31/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class TrueFalseCell: UICollectionViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var currentQuestion: TrueFalse!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate func initNewQuestionNoAnimation(newQuestion: TrueFalse?) {
        if let newQuestion = newQuestion {
            currentQuestion = newQuestion
            
        }
    }
    
    fileprivate func answerQuestion(answer: Bool) -> Bool {
        let index = Generator_.trueFalsePosts.index(of: currentQuestion!)
        let answer_ = currentQuestion.rightAnswer
        if let index = index {
            Generator_.trueFalsePosts.remove(at: index)
        }
        return answer == answer_ ? true : false
    }
    
    @IBAction func truePressed(_ sender: UIButton) {
        let result = answerQuestion(answer: true)
        print("::::::::::::" + result.description + "\n")
    }
    
    @IBAction func falsePressed(_ sender: UIButton) {
        let result = answerQuestion(answer: false)
        print("::::::::::::" + result.description + "\n")
    }
}

