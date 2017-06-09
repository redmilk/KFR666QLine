//
//  ClassicTriviaSectionCtrl.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import IGListKit
import UIKit
import Kingfisher
import Firebase

extension ClassicTriviaSectionCtrl : IGListDisplayDelegate {
    
    func listAdapter(_ listAdapter: IGListAdapter, willDisplay sectionController: IGListSectionController, cell: UICollectionViewCell, at index: Int) {
        
        if let postID = classicTriviaPost.postID {
            if let cell_ = cell as? ClassicTriviaCell {
                var count = 0
                DataBaseRef.child("likes").child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let usersWhoLiked = snapshot.value as? [String : AnyObject] {
                        count = usersWhoLiked.count
                        let uid = Auth.auth().currentUser!.uid
                        if let thisUser = usersWhoLiked[uid] as? Bool {
                            print("||||||||||||||||||||||||||")
                        }
                        let thisUserAlreadyLikedThisPost = usersWhoLiked.contains(where: { (key, value) -> Bool in
                             return key == uid
                        })
                        if thisUserAlreadyLikedThisPost {
                            cell_.likeButtonStateLike()
                        }
                    } else {
                        cell_.noLikeButtonStateLike()
                    }
                    cell_.likesCount.text = count.description
                })
            }
            DataBaseRef.removeAllObservers()
        }
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, willDisplay sectionController: IGListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, didEndDisplaying sectionController: IGListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, didEndDisplaying sectionController: IGListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell_ = cell as? ClassicTriviaCell {
            cell_.noLikeButtonStateLike()
            cell_.likesCount.text = 0.description
        }
        
    }
}

class ClassicTriviaSectionCtrl : IGListSectionController {
    var classicTriviaPost: ClassicTrivia!
    
    
    override init() {
        super.init()
        
        self.displayDelegate = self
        
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
}


extension ClassicTriviaSectionCtrl : IGListSectionType {
    func numberOfItems() -> Int {
        return 1
    }
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: (AppDelegate.instance().window!.screen.bounds.height/2))
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
