//
//  ClassicTriviaCell.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class ClassicTriviaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer4: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var currentQuestion: ClassicTrivia!
    
    var gradient = CAGradientLayer()
    
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
    
    @IBAction func answer1Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
    }
    @IBAction func answer2Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
    }
    @IBAction func answer3Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
    }
    @IBAction func answer4Pressed(_ sender: UIButton) {
        let result = answerQuestion(answer: sender.titleLabel!.text!)
        print(result.description)
    }
   
}
