//
//  VersusSectionController.swift
//  Marslink
//
//  Created by Artem on 2/3/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import IGListKit

class VersusSectionController: IGListSectionController {
    var versusPost: Versus!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}

extension VersusSectionController: IGListSectionType {
    func numberOfItems() -> Int {
        return 1
    }
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: (AppDelegate.instance().window?.screen.bounds.height)!/3)
    }
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "VersusCell", for: self, at: index) as! VersusCell
        cell.headerLabel.text = self.versusPost.header
        cell.titleOneLabel.text = self.versusPost.labelOne
        cell.titleTwoLabel.text = self.versusPost.labelOne
        cell.imageOne.image = self.versusPost.image1
        cell.imageTwo.image = self.versusPost.image2
        
        cell.currentQuestion = versusPost
        
        return cell
    }
    func didUpdate(to object: Any) {
        self.versusPost = object as? Versus
    }
    func didSelectItem(at index: Int) {
    }
}
