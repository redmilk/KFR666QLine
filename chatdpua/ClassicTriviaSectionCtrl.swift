//
//  ClassicTriviaSectionCtrl.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import IGListKit
import UIKit

class ClassicTriviaSectionCtrl : IGListSectionController {
    var classicTriviaPost: ClassicTrivia!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}

extension ClassicTriviaSectionCtrl : IGListSectionType {
    func numberOfItems() -> Int {
        return 1
    }
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: (AppDelegate.instance().window!.screen.bounds.height))
    }
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "ClassicTriviaCell", for: self, at: index) as! ClassicTriviaCell
        cell.answer1.setTitle(classicTriviaPost.answer1, for: .normal)
        cell.answer2.setTitle(classicTriviaPost.answer2, for: .normal)
        cell.answer3.setTitle(classicTriviaPost.answer3, for: .normal)
        cell.answer4.setTitle(classicTriviaPost.answer4, for: .normal)

        cell.imageView.image = classicTriviaPost.image
        cell.currentQuestion = classicTriviaPost
        
        return cell
    }
    func didUpdate(to object: Any) {
        self.classicTriviaPost = object as? ClassicTrivia
    }
    func didSelectItem(at index: Int) {
    }
}
