//
//  TrueFalseSectionController.swift
//  chatdpua
//
//  Created by Artem on 5/31/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import IGListKit
import UIKit

class TrueFalseSectionController : IGListSectionController {
    var trueFalsePost: TrueFalse!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}

extension TrueFalseSectionController : IGListSectionType {
    func numberOfItems() -> Int {
        return 1
    }
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: (AppDelegate.instance().window?.screen.bounds.height)!/3)
    }
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "TrueFalseCell", for: self, at: index) as! TrueFalseCell
        cell.imageView.image = trueFalsePost.image
        cell.headerLabel.text = trueFalsePost.questionTitle
        cell.currentQuestion = trueFalsePost
        return cell
    }
    func didUpdate(to object: Any) {
        self.trueFalsePost = object as? TrueFalse
    }
    func didSelectItem(at index: Int) {
    }
}
