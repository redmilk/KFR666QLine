//
//  ViewController.swift
//  chatdpua
//
//  Created by Artem on 5/31/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class MakeTrueFalseViewCtrl: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var switcherIndicatorLabel: UILabel!
    var imagePicker = UIImagePickerController()
    
    var gradient = CAGradientLayer()
    
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

    @IBAction func donePressed(_ sender: UIButton) {
        if questionTextField.text != nil && imageView.image != UIImage(named: "photoalbum") {
            let trueFalse = TrueFalse(self.imageView.image!, questionTextField.text!, switcher.isOn, Date(timeIntervalSinceNow: 0))
            Generator_.trueFalsePosts.append(trueFalse)
        } else {
            print("Not all fields ready")
        }
        self.dismiss(animated: false, completion: { _ in
            
        })
    }
    
    @IBAction func switcherValueChanged(_ sender: UISwitch) {
        switcherIndicatorLabel.text = switcher.isOn ? "TRUE" : "FALSE"
    }

    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}
