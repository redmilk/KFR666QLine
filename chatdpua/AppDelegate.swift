//
//  AppDelegate.swift
//  chatdpua
//
//  Created by Artem on 1/24/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

extension CALayer {
    func borderUIColor() -> UIColor? {
        return borderColor != nil ? UIColor(cgColor: borderColor!) : nil
    }
    
    func setBorderUIColor(color: UIColor) {
        borderColor = color.cgColor
    }
}

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
}

