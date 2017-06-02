//
//  VS.swift
//  chatdpua
//
//  Created by Artem on 1/27/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import Foundation
import UIKit.UIImage

class Versus : NSObject, DateSortable {
    
    var header: String
    var labelOne: String
    var labelTwo: String
    var image1: UIImage
    var image2: UIImage
    var date: Date
    
    init(header: String,
         image1: UIImage,
         image2: UIImage,
         date: Date,
         labelOne: String = "Object One",
         labelTwo: String = "Object Two"
        ) {
        self.header = header
        self.labelOne = labelOne
        self.labelTwo = labelTwo
        self.image1 = image1
        self.image2 = image2
        self.date = date
    }
}


/* good randomizer generit po 10 chisel, potom iz nih srednee brat */
