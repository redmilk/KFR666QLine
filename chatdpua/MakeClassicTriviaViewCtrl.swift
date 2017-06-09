//
//  MakeClassicTriviaViewCtrl.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

class MakeClassicTriviaViewCtrl: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionHeaderLabel: UILabel!
    @IBOutlet weak var questionHeaderTextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var answer3TextField: UITextField!
    @IBOutlet weak var answer4TextField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    fileprivate var rightAnswerIndex: Int = 1
    fileprivate var rightAnswerString: String = ""
    
    fileprivate var imagePicker = UIImagePickerController()
    
    fileprivate var gradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageViewTapped(img:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        //AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: self.view, color2: .blue, color1: .white)
    }
    
    func imageViewTapped(img: AnyObject) {
        print("imageView tapped")
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: false, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    fileprivate func saveWithUploading() {
        
        guard questionHeaderTextField.text != nil && answer1TextField.text != nil && answer2TextField.text != nil && answer3TextField.text != nil && answer4TextField.text != nil else {
            AppDelegate.instance().showAlert(title: "Error", msg: "All fields required!")
            return
        }
        
        guard imageView.image != UIImage(named: "photoalbum")! else {
            AppDelegate.instance().showAlert(title: "Error", msg: "Select picture!")
            return
        }
        
        let uid = Auth.auth().currentUser!.uid
        let key = DataBaseRef.child("posts").childByAutoId().key
        let imageRef = StorageRef.child("posts").child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
        
        AppDelegate.instance().showActivityIndicator()
        
        //in image future adress we put our data
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            //if no error, we can take futher this img url
            imageRef.downloadURL(completion: { (url, err) in
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                //if url exists
                if let url = url {
                    let date_ = Date(timeIntervalSinceNow: 0)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.string(from: date_)

                    let classicQuiz = ["quizType" : "CLASSIC",
                                       "questionHeader" : self.questionHeaderTextField.text!,
                                       "answer1" : self.answer1TextField.text!,
                                       "answer2" : self.answer2TextField.text!,
                                       "answer3" : self.answer3TextField.text!,
                                       "answer4" : self.answer4TextField.text!,
                                       "rightAnswer" : self.rightAnswerString == "" ? self.answer1TextField.text! : self.rightAnswerString,
                                       "pathToImage" : url.absoluteString,
                                       "postID" : key,
                                       "userID" :  uid,
                                       "date" : date] as [String : Any]
                    
                    //post feed for database
                    let classicQuizAssambled = [key : classicQuiz]
                    //insert in posts -> post feed
                    DataBaseRef.child("posts").updateChildValues(classicQuizAssambled)
                    
                    DataBaseRef.child("info").child("postsCount").runTransactionBlock({ (currentData) -> TransactionResult in
                        var value = currentData.value as? Int
                        
                        if value == nil {
                            value = 0
                        }
                        
                        currentData.value = value! + 1
                        
                        //UserScoreLabel_?.text = (value! + 1).description
                        
                        return TransactionResult.success(withValue: currentData)
                    })
                    
                    DataBaseRef.child("users").child(uid).child("score").runTransactionBlock({ (currentData) -> TransactionResult in
                        var value = currentData.value as? Int
                        
                        if value == nil {
                            value = 0
                        }
                        
                        currentData.value = value! - 1
                        
                        //UserScoreLabel_?.text = (value! - 1).description
                        
                        return TransactionResult.success(withValue: currentData)
                    })
                }
                AppDelegate.instance().dismissActivityIndicator()
                self.dismiss(animated: false, completion: nil)
            })
        })
        uploadTask.resume()
    }
    
    
    
    
    
    
    
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if let answer1 = self.answer1TextField.text {
                rightAnswerString = answer1
            }
        case 1:
            if let answer2 = self.answer2TextField.text {
                rightAnswerString = answer2
            }
        case 2:
            if let answer3 = self.answer3TextField.text {
                rightAnswerString = answer3
            }
        case 3:
            if let answer4 = self.answer4TextField.text {
                rightAnswerString = answer4
            }
        default: break
        }
    }
    
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        saveWithUploading()
        /**** For just array (no web) ****/
        /* if imageView.image != UIImage(named: "photoalbum") && answer1TextField.text != nil && answer2TextField.text != nil && answer3TextField.text != nil && answer4TextField.text != nil && rightAnswerString != "" {
            let classicTrivia = ClassicTrivia(image: imageView.image!, questionTitle: questionHeaderTextField.text, rightAnswer: rightAnswerString, date: Date(timeIntervalSinceNow: 0), answer1: answer1TextField.text!, answer2: answer2TextField.text!, answer3: answer3TextField.text!, answer4: answer4TextField.text!)
            Generator_.classicTriviaPosts.append(classicTrivia)
            self.dismiss(animated: false, completion: nil)
        } */
    }
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
