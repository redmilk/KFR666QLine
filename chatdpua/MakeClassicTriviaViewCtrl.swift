//
//  MakeClassicTriviaViewCtrl.swift
//  chatdpua
//
//  Created by Artem on 6/1/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class MakeClassicTriviaViewCtrl: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionHeaderLabel: UILabel!
    @IBOutlet weak var questionHeaderTextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var answer3TextField: UITextField!
    @IBOutlet weak var answer4TextField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    fileprivate var rightAnswerIndex: Int = 0
    fileprivate var rightAnswerString: String = ""
    
    fileprivate var imagePicker = UIImagePickerController()
    
    fileprivate var gradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageViewTapped(img:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: self.view, color2: .blue, color1: .white)
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
        if imageView.image != UIImage(named: "photoalbum") && answer1TextField.text != nil && answer2TextField.text != nil && answer3TextField.text != nil && answer4TextField.text != nil && rightAnswerString != "" {
            let classicTrivia = ClassicTrivia(image: imageView.image!, questionTitle: questionHeaderTextField.text, rightAnswer: rightAnswerString, date: Date(timeIntervalSinceNow: 0), answer1: answer1TextField.text!, answer2: answer2TextField.text!, answer3: answer3TextField.text!, answer4: answer4TextField.text!)
            Generator_.classicTriviaPosts.append(classicTrivia)
            self.dismiss(animated: false, completion: nil)
        }
    }
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
