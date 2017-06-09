//
//  FeedViewController.swift
//  Marslink
//
//  Created by Artem on 1/30/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import IGListKit
import Firebase
import Kingfisher

@IBDesignable class GradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.white
    @IBInspectable var secondColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [firstColor.cgColor, secondColor.cgColor]
    }
}


extension CollectionViewController: GeneratorDelegate {
    func didUpdatePostsArray(generator: Generator) {
        adapter.performUpdates(animated: true, completion: nil)
    }
}

let Generator_ = Generator()

var UserScoreLabel_: UILabel? = nil

// ////////////////// FEED ///////////////////////
class CollectionViewController: UIViewController {
    
    // MARK: - FIELDS
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    } ()
    
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var collectionView: IGListCollectionView!

    
    fileprivate lazy var presentationAnimator = GuillotineTransitionAnimation()
    fileprivate var gradient = CAGradientLayer()
    fileprivate var retrievedCount: Double = 0
    fileprivate var uid: String!
    
    var dataBaseHandle: DatabaseHandle?
    
    //*************************************// complition handler
    
    override func viewWillAppear(_ animated: Bool) {
        //AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: collectionView, color2: .green, color1: .white)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dataBaseHandle = nil
        DataBaseRef.removeAllObservers()
    }
    
    // MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        //adapter preset
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        UserScoreLabel_ = self.userScore
        //generator delegate
        Generator_.delegate = self
        //collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "space")!)
        
        let imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "space")!
        //self.generator.versusPosts.append(vsPost)
        self.view.addSubview(imageView)
        
        imageView.layer.zPosition = -10
        
        let width = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0)
        let x = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let y = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([width, height, x, y])
        
        uid = Auth.auth().currentUser!.uid
        
        
//        DataBaseRef.child("users").child(uid).child("score").runTransactionBlock({ (currentData) -> TransactionResult in
//            var value = currentData.value as? Int
//            
//            if value == nil {
//                value = 0
//            }
//            self.userScore.text = value?.description
//            return TransactionResult.success(withValue: currentData)
//        })
        
        DataBaseRef.child("users").child(uid).child("score").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? Int
            
            if value == nil {
                self.userScore.text = "0"
            } else {
                self.userScore.text = value!.description
            }
        })
        
        
        getWithoutFinishedQuestions()
        //spectateHotQuestionsOnServer()
        //getQuestionsFromServerOrCache()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    fileprivate func getQuestionsInRatingOrder() {
        
    }
    
    fileprivate func getAmountOfLastQuestion() {
        
    }
    
    fileprivate func getAllFinishedQuestions() {
        
        
        
        dataBaseHandle = Database.database().reference().child("posts").observe(.childAdded, with: { (snapshot) -> Void in
            if let retrievedQuestion = snapshot.value as? [String : Any] {
                if let type = retrievedQuestion["quizType"] as? String {
                    switch type {
                    case "CLASSIC":
                        if let usersWhoFinishedThisQuestion = retrievedQuestion["usersAnswerRight"] as? [String : Any] {
                            if let _ = usersWhoFinishedThisQuestion[self.uid] as? Bool {
                                break
                            }
                        }
                        if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String {
                            
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let date = formatter.date(from: dateString)!
                            //url only latin symbols
                            let urlToImage = URL(string: pathToImage)
                            guard urlToImage != nil else {
                                print("BAD URL LINK !!!!!!!")
                                return }
                            /////////////////
                            cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                if let image_ = image_ {
                                    //print("EXIST in cache.")
                                    //CIRCLE PROGRESS
                                    //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                    
                                    print("EXIST IN CACHE")
                                    /*** if image in Cach make new TheFightersQuestion object ****/
                                    
                                    let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                    
                                    Generator_.classicTriviaPosts.append(classic)
                                    
                                    //if question more than one
                                } else {    /*** No Cached ****/
                                    print("NOT exist in cache.")
                                    /*** if no in Cache we download ****/
                                    downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                        if error != nil {
                                            print(error!.localizedDescription)
                                            self.noInternetConnectionError()
                                            /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                        }
                                        /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                        if let image = image {
                                            print("NEW IMAGE DOWNLOADED")
                                            //CIRCLE PROGRESS
                                            //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                            
                                            cache.store(image, forKey: pathToImage)
                                            
                                            let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                            Generator_.classicTriviaPosts.append(classic)
                                            
                                            //self.adapter.performUpdates(animated: true, completion: nil)
                                        }
                                    })
                                }
                            })
                            
                            
                            /*** if no in Cache we download ****/
                            break
                        }
                    case "TRUEFALSE": break
                    case "VERSUS": break
                    default: break
                    }
                }
            }
        })
    }
    
    fileprivate func getWithoutFinishedQuestions() {
        dataBaseHandle = Database.database().reference().child("posts").observe(.childAdded, with: { (snapshot) -> Void in
            if let retrievedQuestion = snapshot.value as? [String : Any] {
                if let type = retrievedQuestion["quizType"] as? String {
                    switch type {
                    case "CLASSIC":
                        if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String {
                            
                            if let usersWhoFinishedThisQuestion = retrievedQuestion["usersAnswerRight"] as? [String : Any] {
                               if let _ = usersWhoFinishedThisQuestion[self.uid] as? Bool {
                                    break
                                }
                            }
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let date = formatter.date(from: dateString)!
                            //url only latin symbols
                            let urlToImage = URL(string: pathToImage)
                            guard urlToImage != nil else {
                                print("BAD URL LINK !!!!!!!")
                                return }
                            /////////////////
                            cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                if let image_ = image_ {
                                    //print("EXIST in cache.")
                                    //CIRCLE PROGRESS
                                    //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                    
                                    print("EXIST IN CACHE")
                                    /*** if image in Cach make new TheFightersQuestion object ****/
                                    
                                    let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                    
                                    Generator_.classicTriviaPosts.append(classic)
                                    
                                    //if question more than one
                                } else {    /*** No Cached ****/
                                    print("NOT exist in cache.")
                                    /*** if no in Cache we download ****/
                                    downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                        if error != nil {
                                            print(error!.localizedDescription)
                                            self.noInternetConnectionError()
                                            /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                        }
                                        /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                        if let image = image {
                                            print("NEW IMAGE DOWNLOADED")
                                            //CIRCLE PROGRESS
                                            //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                            
                                            cache.store(image, forKey: pathToImage)
                                            
                                            let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                            Generator_.classicTriviaPosts.append(classic)
                                            
                                            //self.adapter.performUpdates(animated: true, completion: nil)
                                        }
                                    })
                                }
                            })
                            
                            
                            /*** if no in Cache we download ****/
                            break
                        }
                    case "TRUEFALSE": break
                    case "VERSUS": break
                    default: break
                    }
                }
            }
        })
    }
    
    fileprivate func spectateHotQuestionsOnServer() {
        dataBaseHandle = Database.database().reference().child("posts").observe(.childAdded, with: { (snapshot) -> Void in
            if let retrievedQuestion = snapshot.value as? [String : Any] {
                if let type = retrievedQuestion["quizType"] as? String {
                    switch type {
                    case "CLASSIC":
                        if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String {
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let date = formatter.date(from: dateString)!
                            //url only latin symbols
                            let urlToImage = URL(string: pathToImage)
                            guard urlToImage != nil else {
                                print("BAD URL LINK !!!!!!!")
                                return }
                            /////////////////
                            cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                if let image_ = image_ {
                                    //print("EXIST in cache.")
                                    //CIRCLE PROGRESS
                                    //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                    
                                    print("EXIST IN CACHE")
                                    /*** if image in Cach make new TheFightersQuestion object ****/
                                    
                                    let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)

                                    Generator_.classicTriviaPosts.append(classic)
                                    
                                    //if question more than one
                                } else {    /*** No Cached ****/
                                    print("NOT exist in cache.")
                                    /*** if no in Cache we download ****/
                                    downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                        if error != nil {
                                            print(error!.localizedDescription)
                                            self.noInternetConnectionError()
                                            /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                        }
                                        /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                        if let image = image {
                                            print("NEW IMAGE DOWNLOADED")
                                            //CIRCLE PROGRESS
                                            //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                            
                                            cache.store(image, forKey: pathToImage)
                                            
                                            let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                            Generator_.classicTriviaPosts.append(classic)
                                            
                                            //self.adapter.performUpdates(animated: true, completion: nil)
                                        }
                                    })
                                }
                            })
                            
                            
                            /*** if no in Cache we download ****/
                            break
                        }
                    case "TRUEFALSE": break
                    case "VERSUS": break
                    default: break
                    }
                }
            }
        })
    }
    
    fileprivate func getQuestionsFromServerOrCache() {
        
        DataBaseWithPosts.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let questions = snapshot.value as! [String : AnyObject]
            var count = 0
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let date = formatter.date(from: dateString)!
                                print(count += 1)
                                //url only latin symbols
                                let urlToImage = URL(string: pathToImage)
                                guard urlToImage != nil else {
                                    print("BAD URL LINK !!!!!!!")
                                    return }
                                /////////////////
                                cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                    if let image_ = image_ {
                                        //print("EXIST in cache.")
                                        //CIRCLE PROGRESS
                                        count += 1
                                        print(count)
                                        //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                        
                                        print("EXIST IN CACHE")
                                        /*** if image in Cach make new TheFightersQuestion object ****/
                                        
                                        let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4)
                                        
                                        Generator_.classicTriviaPosts.append(classic)
                                        
                                        //if question more than one
                                    } else {    /*** No Cached ****/
                                        print("NOT exist in cache.")
                                        /*** if no in Cache we download ****/
                                        downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                            if error != nil {
                                                print(error!.localizedDescription)
                                                self.noInternetConnectionError()
                                                /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                            }
                                            /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                            if let image = image {
                                                print("NEW IMAGE DOWNLOADED")
                                                //CIRCLE PROGRESS
                                                //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                                
                                                cache.store(image, forKey: pathToImage)
                                                
                                                let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4)
                                                
                                                Generator_.classicTriviaPosts.append(classic)
                                                
                                                //self.adapter.performUpdates(animated: true, completion: nil)
                                            }
                                        })
                                    }
                                })
                                
                                
                                /*** if no in Cache we download ****/
                                break
                            }
                        case "TRUEFALSE": break
                        case "VERSUS": break
                        default: break
                        }
                    }
                }
            }
        })
        DataBaseRef.removeAllObservers()
    }
    
    
    fileprivate func retrieveOrDownloadQuestions(totalCount: Int) {
        DataBaseWithPosts.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let questions = snapshot.value as! [String : AnyObject]
            var count = 0
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let date = formatter.date(from: dateString)!
                                print(count += 1)
                                //url only latin symbols
                                let urlToImage = URL(string: pathToImage)
                                guard urlToImage != nil else {
                                    print("BAD URL LINK !!!!!!!")
                                    return }
                                
                                let classic = ClassicTrivia_new(imagePath: pathToImage, image: nil, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4)
                                
                                //Generator_.classicTriviaPosts.append(classic)
                                /*** if no in Cache we download ****/
                                //                                downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                //                                    if error != nil {
                                //                                        print(error!.localizedDescription)
                                //                                        self.noInternetConnectionError()
                                //                                        /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                //                                    }
                                //                                    /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                //                                    if let image = image {
                                //                                        print("NEW IMAGE DOWNLOADED")
                                //                                        //CIRCLE PROGRESS
                                //                                        //progress.angle = self.addToStartValue(add: 360/self.retrievedCount)
                                //
                                //                                        cache.store(image, forKey: pathToImage)
                                //
                                //                                        let classic = ClassicTrivia_new(imagePath: pathToImage, image: nil, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4)
                                //
                                //                                        Generator_.classicTriviaPosts.append(classic)
                                //
                                //                                        //self.adapter.performUpdates(animated: true, completion: nil)
                                //                                        //questionCount > 1 because there is default non-question value in database
                                //                                        questionsCount > 1 ? questionsCount -= 1 : self.downLoadComplete()
                                //                                    }
                                //                                })
                                break
                            }
                        case "TRUEFALSE": break
                        case "VERSUS": break
                        default: break
                        }
                    }
                }
            }
        })
        DataBaseWithPosts.removeAllObservers()
    }
    
    fileprivate func noInternetConnectionError() {
        
    }
    
    
    @IBAction func addPressed(_ sender: UIButton) {
        getQuestionsFromServerOrCache()
    }
    
    @IBAction func plusPressed(_ sender: UIButton) {
        
        Generator_.trueFalsePosts.append(TrueFalse(UIImage(named: "1")!, "Is it photoalbum? 1", true, Date(timeIntervalSinceNow: -100)))
        self.adapter.performUpdates(animated: true, completion: nil)
        
        //        Generator_.versusPosts.append(Versus(header: "Select hottest one", image1: UIImage(named:"1")!, image2: UIImage(named:"2")!, date: Date(timeIntervalSinceNow: 12)))
        //        adapter.performUpdates(animated: true, completion: nil)
    }
    
    @IBAction func showMenuAction(_ sender: UIButton) {
        let menuViewController = storyboard!.instantiateViewController(withIdentifier: "MenuViewController")
        menuViewController.modalPresentationStyle = .custom
        menuViewController.transitioningDelegate = self
        
        presentationAnimator.animationDelegate = menuViewController as? GuillotineAnimationDelegate
        presentationAnimator.supportView = navigationController!.navigationBar
        presentationAnimator.presentButton = sender
        present(menuViewController, animated: true, completion: nil)
    }
    
}











// ////////////////// DELEG ///////////////////////
extension CollectionViewController: IGListAdapterDataSource {
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        // 1
        var items: [IGListDiffable] = Generator_.versusPosts as [IGListDiffable]
        items += Generator_.trueFalsePosts as [IGListDiffable]
        items += Generator_.classicTriviaPosts as [IGListDiffable]
        // 2
        return items.sorted(by: { (left: Any, right: Any) -> Bool in
            if let left = left as? DateSortable, let right = right as? DateSortable {
                return left.date > right.date
            }
            return false
        })
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        if object is Versus {
            return VersusSectionController()
        } else if object is TrueFalse {
            return TrueFalseSectionController()
        } else if object is ClassicTrivia {
            return ClassicTriviaSectionCtrl()
        } else {
            return IGListSectionController()
        }
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
}

extension CollectionViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationAnimator.mode = .presentation
        return presentationAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationAnimator.mode = .dismissal
        return presentationAnimator
    }
}







