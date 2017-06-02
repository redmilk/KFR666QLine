//
//  TrueFalse.swift
//  chatdpua
//
//  Created by Artem on 5/31/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import Foundation
import UIKit.UIImage

class TrueFalse : NSObject, DateSortable {
    
    var image: UIImage
    var questionTitle: String
    let rightAnswer: Bool
    var date: Date
    
    init(_ image: UIImage, _ questionTittle: String, _ rightAnswer: Bool, _ date: Date) {
        self.image = image
        self.questionTitle = questionTittle
        self.rightAnswer = rightAnswer
        self.date = date
    }
}
