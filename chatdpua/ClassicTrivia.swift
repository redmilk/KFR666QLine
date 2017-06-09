//
//  ClassicTrivia.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import Foundation
import UIKit.UIImage

class ClassicTrivia : NSObject, DateSortable {
    
    let image: UIImage
    let questionTitle: String?
    let rightAnswer: String
    let date: Date
    let postID: String?
    
    let answer1: String
    let answer2: String
    let answer3: String
    let answer4: String
    
    var isLikedByCurrentUser: Bool?
    
    init(image: UIImage, questionTitle: String?, rightAnswer: String, date: Date, answer1: String, answer2: String, answer3: String, answer4: String, isLikedByCurrentUser: Bool? = nil, postID: String? = nil) {
        self.image = image
        self.questionTitle = questionTitle
        self.rightAnswer = rightAnswer
        self.date = date
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.answer4 = answer4
        self.postID = postID
        self.isLikedByCurrentUser = isLikedByCurrentUser
    }
}

class ClassicTrivia_new : NSObject, DateSortable {
    
    let imagePath: String?
    let image: UIImage?
    let questionTitle: String?
    let rightAnswer: String
    let date: Date
    
    let answer1: String
    let answer2: String
    let answer3: String
    let answer4: String
    
    init(imagePath: String?, image: UIImage?, questionTitle: String?, rightAnswer: String, date: Date, answer1: String, answer2: String, answer3: String, answer4: String) {
        self.image = image
        self.imagePath = imagePath
        self.questionTitle = questionTitle
        self.rightAnswer = rightAnswer
        self.date = date
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.answer4 = answer4
    }

    
}
