//
//  SignUpViewCtrl.swift
//  chatdpua
//
//  Created by Artem on 6/3/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewCtrl: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var confirmPwd: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageViewTapped(img:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageViewTapped(img: AnyObject) {
        print("imageView tapped")
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: false, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            self.registerButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
        self.registerButton.isHidden = false
    }
    
    /// Select Picture
    @IBAction func selectPictureHandler(_ sender: UIButton) {
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    func savePressed() {
        let name = self.name.text!
        let email = self.email.text!
        let pwd1 = self.pwd.text!
        let pwd2 = self.confirmPwd.text!
        let img = imageView.image!
        
        if img == UIImage(named: "photoalbum")! {
            // MARK: - vstavit alert
        }
        
        // Проверка на валидность введенных строк
        guard name != "", email != "", pwd1 != "", pwd2 != "" else {
            // vstavit alert
            // MARK: - vstavit alert
            return
        }
        if pwd1 != pwd2 {
            // vstavit alert
            // MARK: - vstavit alert
            return
        } else {
            Auth.auth().createUser(withEmail: email, password: pwd1, completion: { (user, error) in
                
                if error != nil {
                    //vstavit alert
                    // MARK: - vstavit alert
                    //error!.localizedDescription
                    return
                }
                
                if let user = user {
                    // MARK: - new user has been registred
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges(completion: nil)
                    //sozdaem ssilku v storage, so znacheniem user id, tam budet hranitsya kartinka, pod imenem id usera
                    let imageRef = StorageRef.child("\(user.uid)")
                    //szhat kartinku, --> data
                    let imageFromImageView = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    //vigruzit ee v hranilishe
                    
                    let uploadTask = imageRef.putData(imageFromImageView!, metadata: nil, completion: { (meta, error_) in
                        if error_ != nil {
                            // vstavit alert
                            // MARK: - vstavit alert
                            return
                        }
                        //vzyat ssilku na teper zagruzhennuyu kartinku iz hranilishya
                        imageRef.downloadURL(completion: { (url, error__) in
                            if error__ != nil {
                                // vstavit alert
                                // MARK: - vstabit alert
                                return
                            }
                            if let url = url {
                                //poluchili url na kartinku kotouyu dobavim v map
                                //sozdali infu o yuzere, upakovali v map
                                let userInfo: [String : Any] = ["uid" : user.uid,
                                                                "name" : name,
                                                                "avatar" : url.absoluteString,
                                                                "score" : 0.description]
                                
                                //sozdaem v data base vkladku users/HjhdSjlK34H8jsd 'userID'
                                //teper nuzhno prikrepit k yuzeru kotoriy tolko chto zaregistrirovalsya eto infu v database
                                DataBaseRef.child(user.uid).setValue(userInfo)
                            }
                        })
                    })
                    //nachat zagruzku?
                    uploadTask.resume()

                    let usersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                    self.present(usersViewController, animated: true, completion: nil)

                }
            })
        }
    }
    
    /// Button Next
    @IBAction func nextButtonHandler(_ sender: UIButton) {
        //if
        guard self.name.text != "", self.email.text != "", self.pwd.text != "", self.confirmPwd.text != "" else {
            print("All fields required")
            return
        }
        if self.pwd.text == self.confirmPwd.text {
            Auth.auth().createUser(withEmail: self.email.text!, password: self.pwd.text!, completion: { (user, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    
                    //to display who posted it
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.name.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = StorageRef.child("\(user.uid).jpg")
                    
                    let imageFromImageView = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.putData(imageFromImageView!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(er!.localizedDescription)
                            }
                            if let url = url {
                                
                                let userInfo: [String : Any] = ["uid": user.uid,
                                                                "full name": self.name.text!,
                                                                "urlToImage": url.absoluteString,
                                                                "score" : 0]
                                
                                DataBaseRef.child("users").child(user.uid).setValue(userInfo)
                                
                                let userViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                                self.present(userViewController, animated: true, completion: nil)
                                
                            }
                        })
                    })
                    
                    uploadTask.resume()
                }
            })
            
        } else {
            print("Password does not match")
        }
    }
}

