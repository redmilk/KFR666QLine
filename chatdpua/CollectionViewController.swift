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

func addParallaxToView(vw: UIView) {
    let amount = 100
    
    let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    horizontal.minimumRelativeValue = -amount
    horizontal.maximumRelativeValue = amount
    
    let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    vertical.minimumRelativeValue = -amount
    vertical.maximumRelativeValue = amount
    
    let group = UIMotionEffectGroup()
    group.motionEffects = [horizontal, vertical]
    vw.addMotionEffect(group)
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
    fileprivate var startValue: Double = 0
    
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
        
        DataBaseRef.child("users").child(uid).child("score").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? Int
            
            if value == nil {
                self.userScore.text = "0"
            } else {
                self.userScore.text = value!.description
            }
        })
        DataBaseRef.removeAllObservers()
        
        // MARK: -View Did Load
        
        //getAllQuestionsFromServer()
        //getQuestionsSolvedByCurrentUser()
        //getMostLikedQuestions()
        getMostLikedQuestionsNotSolvedByCurrentUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    fileprivate func getAmountOfLastUnsolvedQuestion() {
        
    }
    
    
    // MARK: - TOP LIKED NO SOLVED
    fileprivate func getMostLikedQuestionsNotSolvedByCurrentUser() { /// ready to use
        Generator_.classicTriviaPosts.removeAll()
        Generator_.trueFalsePosts.removeAll()
        Generator_.versusPosts.removeAll()
        
        
        DataBaseRef.child("posts").queryOrdered(byChild: "likesCount").queryStarting(atValue: "1").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard snapshot.exists() else {
                return
            }
            
            let questions = snapshot.value as! [String : AnyObject]
            
            let questionsCount = Double(questions.count)
            var counter = questions.count - 1 //because there is deafult empty value in database
            guard counter != 0 else {
                AppDelegate.instance().showAlert(title: "Empty", msg: "Sorry, you solved all top liked questions :)")
                return
            }
            AppDelegate.instance().showProgressIndicator()
            

            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String {
                                
                                // if user already solved this question break
                                if let usersWhoFinishedThisQuestion = retrievedQuestion["usersAnswerRight"] as? [String : Any] {
                                    if let _ = usersWhoFinishedThisQuestion[self.uid] as? Bool {
                                        counter -= 1
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
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
                                    return
                                }
                                
                                cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                    if let image_ = image_ {
                                        counter -= 1
                                        //CIRCLE PROGRESS
                                        ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)

                                        print("EXIST IN CACHE")
                                        /*** if image in Cach make new TheFightersQuestion object ****/
                                        
                                        let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                        
                                        Generator_.classicTriviaPosts.append(classic)
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
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
                                                counter -= 1
                                                //CIRCLE PROGRESS
                                                ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)

                                                cache.store(image, forKey: pathToImage)
                                                
                                                let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                                Generator_.classicTriviaPosts.append(classic)
                                                if counter <= 0 {
                                                    self.retrieveComplete()
                                                }
                                            }
                                        })
                                    }
                                })
                            }
                            break
                        case "TRUEFALSE": break
                        case "VERSUS": break
                        default: break
                        }
                    }
                }
            }
            
        })
        /// detach listeners
        DataBaseRef.removeAllObservers()
    }
    
    // MARK: - TOP LIKED
    fileprivate func getMostLikedQuestions() { /// ready to use
        Generator_.classicTriviaPosts.removeAll()
        Generator_.trueFalsePosts.removeAll()
        Generator_.versusPosts.removeAll()
        
        DataBaseRef.child("posts").queryOrdered(byChild: "likesCount").queryStarting(atValue: "1").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard snapshot.exists() else {
                return
            }
            
            let questions = snapshot.value as! [String : AnyObject]
            
            let questionsCount = Double(questions.count)
            var counter = questions.count - 1 //because there is deafult empty value in database
            guard counter != 0 else {
                AppDelegate.instance().showAlert(title: "No Likes", msg: "Sorry, there is no questions liked by you")
                return
            }
            AppDelegate.instance().showProgressIndicator()

            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
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
                                        counter -= 1
                                        //CIRCLE PROGRESS
                                        ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)

                                        print("EXIST IN CACHE")
                                        /*** if image in Cach make new TheFightersQuestion object ****/
                                        
                                        let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                        
                                        Generator_.classicTriviaPosts.append(classic)
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
                                    } else {    /*** If No Cached ****/
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
                                                counter -= 1
                                                //CIRCLE PROGRESS
                                                ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)

                                                cache.store(image, forKey: pathToImage)
                                                
                                                let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                                Generator_.classicTriviaPosts.append(classic)
                                                if counter <= 0 {
                                                    self.retrieveComplete()
                                                }
                                            }
                                        })
                                    }
                                })
                            }
                            break
                        case "TRUEFALSE": break
                        case "VERSUS": break
                        default: break
                        }
                    }
                }
            }
            
        })
        /// detach listeners
        DataBaseRef.removeAllObservers()
    }
    // MARK: - LIKED BY ME
    fileprivate func getQuestionLikedByCurrentUser() { /// ready to use
        print("____getQuestionLikedByCurrentUser____")

        Generator_.classicTriviaPosts.removeAll()
        Generator_.trueFalsePosts.removeAll()
        Generator_.versusPosts.removeAll()
        
        DataBaseWithPosts.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let questions = snapshot.value as! [String : AnyObject]
            
            let questionsCount = Double(questions.count)
            var counter = questions.count - 1 //because there is deafult empty value in database
            guard counter != 0 else {
                AppDelegate.instance().showAlert(title: "No Likes", msg: "Sorry, there is no questions liked by you")
                return
            }
            AppDelegate.instance().showProgressIndicator()

            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String {
                                
                                // check if current user liked this post
                                DataBaseRef.child("likes").child(postID).child(self.uid).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                                    guard snapshot.exists() else {
                                        counter -= 1
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
                                        return
                                    }
                                    if let _ = snapshot.value as? Bool {
                                        //this user liked the question
                                        
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
                                                counter -= 1
                                                //CIRCLE PROGRESS
                                                ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)

                                                print("EXIST IN CACHE")
                                                /*** if image in Cach make new TheFightersQuestion object ****/
                                                
                                                let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                                
                                                Generator_.classicTriviaPosts.append(classic)
                                                if counter <= 0 {
                                                    self.retrieveComplete()
                                                }
                                                //if question more than one
                                            } else {    /*** No Cached ****/
                                                print("NOT exist in cache.")
                                                /*** if no in Cache we download ****/
                                                downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                                    if error != nil {
                                                        print(error!.localizedDescription)
                                                        self.noInternetConnectionError()
                                                    }
                                                    /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                                    if let image = image {
                                                        print("NEW IMAGE DOWNLOADED")
                                                        counter -= 1
                                                        //CIRCLE PROGRESS
                                                        ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                                        
                                                        cache.store(image, forKey: pathToImage)
                                                        
                                                        let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                                        Generator_.classicTriviaPosts.append(classic)
                                                        if counter <= 0 {
                                                            self.retrieveComplete()
                                                        }
                                                    }
                                                })
                                            }
                                        })
                                    } else {
                                        counter -= 1
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
                                    }
                                })
                            }
                            break
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
    
    // MARK: - SOLVED BY USER
    fileprivate func getQuestionsSolvedByCurrentUser() { /// ready to use
        print("____getQuestionsSolvedByCurrentUser____")
        Generator_.classicTriviaPosts.removeAll()
        Generator_.trueFalsePosts.removeAll()
        Generator_.versusPosts.removeAll()
        
        DataBaseWithPosts.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                return
            }
            let questions = snapshot.value as! [String : AnyObject]
            
            let questionsCount = Double(questions.count)
            var counter = questions.count - 1 //because there is deafult empty value in database
            guard counter != 0 else {
                AppDelegate.instance().showAlert(title: "Empty", msg: "There is no questions, answered by you")
                return
            }
            AppDelegate.instance().showProgressIndicator()
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            // if this question has users who solved it
                            if let usersWhoFinishedThisQuestion = retrievedQuestion["usersAnswerRight"] as? [String : Any] {
                                // if current user solved this question already we go in
                                if let _ = usersWhoFinishedThisQuestion[self.uid] as? Bool {
                                    
                                    if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String {
                                        
                                        
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        let date = formatter.date(from: dateString)!
                                        //url only latin symbols
                                        let urlToImage = URL(string: pathToImage)
                                        guard urlToImage != nil else {
                                            AppDelegate.instance().showAlert(title: "Error", msg: "Bad URL")
                                            return
                                        }
                                        /////////////////
                                        cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                            if let image_ = image_ {
                                                counter -= 1
                                                //CIRCLE PROGRESS
                                                ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                                
                                                print("EXIST IN CACHE")
                                                /*** if image in Cach make new TheFightersQuestion object ****/
                                                
                                                let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                                
                                                Generator_.classicTriviaPosts.append(classic)
                                                if counter <= 0 {
                                                    self.retrieveComplete()
                                                }
                                                //if question more than one
                                            } else {    /*** No Cached ****/
                                                print("NOT exist in cache.")
                                                /*** if no in Cache we download ****/
                                                downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                                    if error != nil {
                                                        print(error!.localizedDescription)
                                                        self.noInternetConnectionError()
                                                        AppDelegate.instance().dismissProgressIndicator()
                                                        /***/ //MARK: - !<esli zagruzit ne udalos to...>!
                                                    }
                                                    /*** if image download suceed cache it and make new TheFightersQuestion object ****/
                                                    if let image = image {
                                                        counter -= 1
                                                        print("NEW IMAGE DOWNLOADED")
                                                        //CIRCLE PROGRESS
                                                        ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                                        
                                                        cache.store(image, forKey: pathToImage)
                                                        
                                                        let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, isLikedByCurrentUser: false, postID: postID)
                                                        Generator_.classicTriviaPosts.append(classic)
                                                        if counter <= 0 {
                                                            self.retrieveComplete()
                                                        }
                                                    }
                                                })
                                            }
                                        })
                                    }
                                } else { // this user didnt answer this question (we need user's solved questions)
                                    // there is no our user in current questions 'usersWhoAnsweredRight'
                                    counter -= 1
                                    if counter <= 0 {
                                        self.retrieveComplete()
                                    }
                                    break
                                }
                            } else { // this question doesn't have 'usersWhoAnsweredRight' at all
                                counter -= 1
                                if counter <= 0 {
                                    self.retrieveComplete()
                                }
                                break
                            }
                            break
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
    
    // MARK: - NOT SOLVED
    fileprivate func getQuestionsNotSolvedByCurrentUser() { /// ready to use
        print("\n_____getQuestionsNotSolvedByCurrentUser_____")
        Generator_.classicTriviaPosts.removeAll()
        Generator_.trueFalsePosts.removeAll()
        Generator_.versusPosts.removeAll()
                
        DataBaseWithPosts.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                return
            }
            let questions = snapshot.value as! [String : AnyObject]
            let questionsCount = Double(questions.count)
            var counter = questions.count - 1 //because there is deafult empty value in database
            guard counter != 0 else {
                AppDelegate.instance().showAlert(title: "Empty", msg: "There is no questions for you. You solved them all, You are smart!")
                return
            }
            AppDelegate.instance().showProgressIndicator()
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String  {
                                
                                if let usersWhoFinishedThisQuestion = retrievedQuestion["usersAnswerRight"] as? [String : Any] {
                                    if let _ = usersWhoFinishedThisQuestion[self.uid] as? Bool {
                                        counter -= 1
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
                                        break
                                    }
                                }
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let date = formatter.date(from: dateString)!
                                //url only latin symbols
                                let urlToImage = URL(string: pathToImage)
                                guard urlToImage != nil else {
                                    AppDelegate.instance().showAlert(title: "Error", msg: "Bad URL")
                                    AppDelegate.instance().dismissProgressIndicator()
                                    return
                                }
                                
                                cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                    if let image_ = image_ {
                                        
                                        
                                        counter -= 1
                                        //CIRCLE PROGRESS
                                        ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                        
                                        print("questionType: CLASSIC, header: \(header), rightAnswer: \(rightAnswer):::EXIST IN CACHE")
                                        /*** if image in Cach make new TheFightersQuestion object ****/
                                        
                                        let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, postID: postID)
                                        
                                        Generator_.classicTriviaPosts.append(classic)
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
                                        //if question more than one
                                    } else {    /*** No Cached ****/
                                        print("Current question Image doesn't exist in cache. Start downloading....")
                                        downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                            if error != nil {
                                                print(error!.localizedDescription)
                                                self.noInternetConnectionError()
                                            }
                                            /*** if image download suceed cache it and make new Question object ****/
                                            if let image = image {
                                                
                                                counter -= 1
                                                print("NEW IMAGE DOWNLOADED")
                                                //CIRCLE PROGRESS
                                                ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                                cache.store(image, forKey: pathToImage)
                                                let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, postID: postID)
                                                Generator_.classicTriviaPosts.append(classic)
                                                
                                                print("66666666666666666 counter's current value is \(counter)")
                                                if counter <= 0 {
                                                    self.retrieveComplete()
                                                }
                                            }
                                        })
                                    }
                                })
                            }
                            break
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
    // MARK: - GET ALL
    fileprivate func getAllQuestionsFromServer() { ///ready to use
        
        Generator_.classicTriviaPosts.removeAll()
        Generator_.trueFalsePosts.removeAll()
        Generator_.versusPosts.removeAll()
        
        DataBaseWithPosts.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                return
            }
            let questions = snapshot.value as! [String : AnyObject]
            let questionsCount = Double(questions.count)
            var counter = questions.count - 1 //because there is deafult empty value in database
            guard counter != 0 else {
                AppDelegate.instance().showAlert(title: "Empty", msg: "There is no questions for you. You solved them all, You are smart!")
                return
            }
            AppDelegate.instance().showProgressIndicator()
            
            for(_, value) in questions {
                
                if let retrievedQuestion = value as? [String : Any] {
                    
                    if let type = retrievedQuestion["quizType"] as? String {
                        switch type {
                        case "CLASSIC":
                            
                            if let header = retrievedQuestion["questionHeader"] as? String, let answer1 = retrievedQuestion["answer1"] as? String, let answer2 = retrievedQuestion["answer2"] as? String, let answer3 = retrievedQuestion["answer3"] as? String, let answer4 = retrievedQuestion["answer4"] as? String, let rightAnswer = retrievedQuestion["rightAnswer"] as? String, let pathToImage = retrievedQuestion["pathToImage"] as? String, let dateString = retrievedQuestion["date"] as? String, let postID = retrievedQuestion["postID"] as? String  {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let date = formatter.date(from: dateString)!
                                //url only latin symbols
                                let urlToImage = URL(string: pathToImage)
                                guard urlToImage != nil else {
                                    AppDelegate.instance().showAlert(title: "Error", msg: "Bad URL")
                                    return
                                }
                                /////////////////
                                cache.retrieveImage(forKey: pathToImage, options: nil, completionHandler: { (image_, cacheType) in
                                    if let image_ = image_ {
                                        
                                        
                                        counter -= 1
                                        //CIRCLE PROGRESS
                                        ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                        
                                        print("questionType: CLASSIC, header: \(header), rightAnswer: \(rightAnswer):::EXIST IN CACHE")
                                        /*** if image in Cach make new TheFightersQuestion object ****/
                                        
                                        let classic = ClassicTrivia(image: image_, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, postID: postID)
                                        
                                        Generator_.classicTriviaPosts.append(classic)
                                        print("66666666666666666 counter's current value is \(counter)")
                                        if counter <= 0 {
                                            self.retrieveComplete()
                                        }
                                        //if question more than one
                                    } else {    /*** No Cached ****/
                                        print("Current question Image doesn't exist in cache. Start downloading....")
                                        downloader.downloadImage(with: urlToImage!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, originalData) in
                                            if error != nil {
                                                print(error!.localizedDescription)
                                                self.noInternetConnectionError()
                                            }
                                            /*** if image download suceed cache it and make new Question object ****/
                                            if let image = image {
                                                
                                                counter -= 1
                                                print("NEW IMAGE DOWNLOADED")
                                                //CIRCLE PROGRESS
                                                ProgressIndicator.angle = self.addToStartValue(add: 360/questionsCount)
                                                cache.store(image, forKey: pathToImage)
                                                let classic = ClassicTrivia(image: image, questionTitle: header, rightAnswer: rightAnswer, date: date, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, postID: postID)
                                                Generator_.classicTriviaPosts.append(classic)
                                                
                                                print("66666666666666666 counter's current value is \(counter)")
                                                if counter <= 0 {
                                                    self.retrieveComplete()
                                                }
                                            }
                                        })
                                    }
                                })
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
    
    
    fileprivate func noInternetConnectionError() {
        AppDelegate.instance().showAlert(title: "No connection", msg: "Please, check your internet connection")
    }
    
    fileprivate func addToStartValue(add: Double) -> Double{
        if startValue <= 360 {
            self.startValue += add
            
        } else if startValue >= 360 {
            
        }
        print(startValue)
        return self.startValue
    }
    
    fileprivate func retrieveComplete() {
        ProgressIndicator.animate(toAngle: 360.0, duration: 1.0) { (bool) in
            AppDelegate.instance().dismissProgressIndicator()
            self.startValue = 0.0
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func showAllQuestions(_ sender: UIButton) {
        getQuestionsNotSolvedByCurrentUser()
    }
    @IBAction func showQuestionsLikedByCurrentUser(_ sender: UIButton) {
        getQuestionLikedByCurrentUser()
    }
    @IBAction func showMostLikedQuestions(_ sender: UIButton) {
        getMostLikedQuestions()
    }
    @IBAction func showCurrentUserSolvedQuestion(_ sender: UIButton) {
        getQuestionsSolvedByCurrentUser()
    }
    
    @IBAction func showAllQuestionsWithSolved(_ sender: UIButton) {
        getAllQuestionsFromServer()
    }
    
    @IBAction func showMostLikedNoSolved(_ sender: UIButton) {
        getMostLikedQuestionsNotSolvedByCurrentUser()
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







