//
//  MenuViewController.swift
//  GuillotineMenuExample
//
//  Created by Maksym Lazebnyi on 10/8/15.
//  Copyright © 2015 Yalantis. All rights reserved.
//

import UIKit

extension MenuViewController: GuillotineAnimationDelegate {
    
    func animatorDidFinishPresentation(_ animator: GuillotineTransitionAnimation) {
        print("menuDidFinishPresentation")
    }
    func animatorDidFinishDismissal(_ animator: GuillotineTransitionAnimation) {
        print("menuDidFinishDismissal")
    }
    
    func animatorWillStartPresentation(_ animator: GuillotineTransitionAnimation) {
        print("willStartPresentation")
    }
    
    func animatorWillStartDismissal(_ animator: GuillotineTransitionAnimation) {
        print("willStartDismissal")
    }
}

class MenuViewController: UIViewController, GuillotineMenu {
    
    var dismissButton: UIButton?
    var titleLabel: UILabel?
    
    var gradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissButton = {
            let button = UIButton(frame: .zero)
            button.setImage(UIImage(named: "ic_menu"), for: .normal)
            button.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
            return button
        }()
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 1;
            label.text = "Activity"
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.textColor = UIColor.white
            label.sizeToFit()
            return label
        }()
        
        //AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: self.view, color2: .white, color1: .blue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Menu: viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Menu: viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Menu: viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Menu: viewDidDisappear")
    }
    
    func dismissButtonTapped(_ sender: UIButton) {
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func closeMenu(_ sender: UIButton) {
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusClassic(_ sender: UIButton) {
        let classic = ClassicTrivia(image: UIImage(named: "1")!, questionTitle: "What the fuck? _____", rightAnswer: "Bitch", date: Date(timeIntervalSinceNow: 0), answer1: "Pussy", answer2: "Boy", answer3: "Dog", answer4: "Bitch")
        
        Generator_.classicTriviaPosts.append(classic)
        //presentingViewController!.dismiss(animated: true, completion: nil)
    }
    @IBAction func plusVersus(_ sender: UIButton) {
        let versus = Versus(header: "Who wins?", image1: UIImage(named: "1")!, image2: UIImage(named: "2")!, date: Date(timeIntervalSinceNow: 0), labelOne: "Pussy", labelTwo: "Juicy")
        Generator_.versusPosts.append(versus)
        //presentingViewController!.dismiss(animated: true, completion: nil)
    }
    @IBAction func plusTrueFalse(_ sender: UIButton) {
         Generator_.trueFalsePosts.append(TrueFalse(UIImage(named: "1")!, "This is my picture, isn't it?", true, Date(timeIntervalSinceNow: 0)))
        //presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
}


