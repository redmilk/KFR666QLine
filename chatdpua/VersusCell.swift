//
//  VersusCell.swift
//  Marslink
//
//  Created by Artem on 2/3/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class VersusCell: UICollectionViewCell {
    
    var currentQuestion: Versus!
    
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var titleTwoLabel: UILabel!
    @IBOutlet weak var labelVS: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizerOne = UITapGestureRecognizer(target:self, action:#selector(imageOneTapped(img:)))
        let tapGestureRecognizerTwo = UITapGestureRecognizer(target:self, action:#selector(imageTwoTapped(img:)))
        imageOne.isUserInteractionEnabled = true
        imageTwo.isUserInteractionEnabled = true
        imageOne.addGestureRecognizer(tapGestureRecognizerOne)
        imageTwo.addGestureRecognizer(tapGestureRecognizerTwo)
    }
    
    func imageOneTapped(img: AnyObject) {
        print("image One tapped")
        let index = Generator_.versusPosts.index(of: currentQuestion!)
        if let index = index {
            Generator_.versusPosts.remove(at: index)
        }

    }
    
    func imageTwoTapped(img: AnyObject) {
        print("image Two tapped")
        let index = Generator_.versusPosts.index(of: currentQuestion!)
        if let index = index {
            Generator_.versusPosts.remove(at: index)
        }

    }
}
