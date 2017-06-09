//
//  AppDelegate.swift
//  chatdpua
//
//  Created by Artem on 1/24/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase
import PCLBlurEffectAlert
import Kingfisher

extension CALayer {
    func borderUIColor() -> UIColor? {
        return borderColor != nil ? UIColor(cgColor: borderColor!) : nil
    }
    
    func setBorderUIColor(color: UIColor) {
        borderColor = color.cgColor
    }
}

var DataBaseWithUsers: DatabaseReference!
var DataBaseWithPosts: DatabaseReference!

var StorageWithPosts: StorageReference!
var StorageWithUsers: StorageReference!

var DataBaseRef: DatabaseReference!
var StorageRef: StorageReference!

let downloader = ImageDownloader(name: "DOWNLOADER")
let cache = ImageCache(name: "CACHE")


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!

    /// DidFinishLaunhingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //navigation bar
        UINavigationBar.appearance().barTintColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        //UIApplication.shared.statusBarStyle = .lightContent
        
        FirebaseApp.configure()
        
        DataBaseRef = Database.database().reference()
        StorageRef = Storage.storage().reference(forURL: "gs://universequiz-11e9b.appspot.com")
        
        StorageWithUsers = StorageRef.child("users")
        StorageWithPosts = StorageRef.child("posts")

        DataBaseWithUsers = Database.database().reference().child("users")
        DataBaseWithPosts = Database.database().reference().child("posts")
        
        downloader.downloadTimeout = 30
        cache.maxCachePeriodInSecond = -1
        cache.maxDiskCacheSize = 0
        
        return true
    }

    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func setupGradient(gradient: CAGradientLayer, viewForGradient: UIView, color2: UIColor, color1: UIColor = UIColor.white) {
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = viewForGradient.frame
        //gradient.frame = CGRect(x: 0.0, y: 0.0, width: viewForGradient.frame.size.width, height: viewForGradient.frame.size.height)
        gradient.zPosition = -10
        viewForGradient.layer.addSublayer(gradient)
    }
    
    func showAlert(title: String, msg: String) {
        let alert = PCLBlurEffectAlert.Controller(title: "\(title)", message: "\(msg)", effect: UIBlurEffect(style: .dark), style: .actionSheet)
        let action = PCLBlurEffectAlert.Action(title: "Cancel", style: .cancel, handler: { (act) in
            //cancel button on alertview, setLogin button to initial state
        })
        
        alert.addAction(action)
        alert.configure(cornerRadius: 10)
        alert.configure(overlayBackgroundColor: UIColor(colorLiteralRed: 0, green: 0, blue: 30, alpha: 0.4))
        alert.configure(messageFont: UIFont(name: "HelveticaNeue", size: 18.0)!, messageColor: UIColor.white)
        alert.show()
    }
    
    func showActivityIndicator() {
        if let window = window {
            self.container = UIView()
            self.container.frame = window.frame
            self.container.center = window.center
            self.container.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.center = CGPoint(x: self.container.frame.size.width/2, y: self.container.frame.size.height/2)
            self.container.addSubview(self.activityIndicator)
            self.window?.addSubview(self.container)
            self.activityIndicator.startAnimating()
        }
    }
    
    func dismissActivityIndicator() {
        if let _ = self.window {
            self.container.removeFromSuperview()
        }
    }
}

