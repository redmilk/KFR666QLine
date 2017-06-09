//
//  MakeVSViewController.swift
//  chatdpua
//
//  Created by Artem on 1/27/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class MakeVSViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerTextField: UITextField!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var labelVS: UILabel!
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonDone: UIButton!
    
    var imagePickerOne = UIImagePickerController()
    var imagePickerTwo = UIImagePickerController()
    
    var appendAndReloadClosure: ((_ vsPost: Versus) -> ())!

    var gradient = CAGradientLayer()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerOne.delegate = self
        imagePickerTwo.delegate = self
        
        let tapGestureRecognizerOne = UITapGestureRecognizer(target:self, action:#selector(imageOneTapped(img:)))
        let tapGestureRecognizerTwo = UITapGestureRecognizer(target:self, action:#selector(imageTwoTapped(img:)))
        imageViewOne.isUserInteractionEnabled = true
        imageViewTwo.isUserInteractionEnabled = true
        imageViewOne.addGestureRecognizer(tapGestureRecognizerOne)
        imageViewTwo.addGestureRecognizer(tapGestureRecognizerTwo)
        
        
        gradient.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        gradient.zPosition = -10
        //self.view.layer.addSublayer(gradient)
        
    }
    
    func imageOneTapped(img: AnyObject) {
        print("image One tapped")
        imagePickerOne.sourceType = .photoLibrary
        self.present(imagePickerOne, animated: true, completion:  nil)
    }
    
    func imageTwoTapped(img: AnyObject) {
        print("image Two tapped")
        imagePickerTwo.sourceType = .photoLibrary
        self.present(imagePickerTwo, animated: true, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if picker == imagePickerOne {
                imageViewOne.image = image
            } else if picker == imagePickerTwo {
                imageViewTwo.image = image
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        // MARK: - done button (saving)
        // id tekushego yuzera
        
        let vs = Versus(header: self.headerTextField.text!, image1: imageViewOne.image!, image2: imageViewTwo.image!, date: Date(timeIntervalSinceNow: -100))
        Generator_.versusPosts.append(vs)
        self.dismiss(animated: false, completion: nil)
    }
}
