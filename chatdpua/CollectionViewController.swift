//
//  FeedViewController.swift
//  Marslink
//
//  Created by Artem on 1/30/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import IGListKit


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

// ////////////////// FEED ///////////////////////
class CollectionViewController: UIViewController {
    
    // MARK: - FIELDS
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    } ()
    
    @IBOutlet weak var collectionView: IGListCollectionView!
    
    fileprivate lazy var presentationAnimator = GuillotineTransitionAnimation()
    fileprivate var gradient = CAGradientLayer()
    
    override func viewWillAppear(_ animated: Bool) {
        //AppDelegate.instance().setupGradient(gradient: gradient, viewForGradient: collectionView, color2: .green, color1: .white)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //navigationController?.hidesBarsOnSwipe = true
    }
    // MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        //adapter preset
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
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
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @IBAction func addVersusPostButton(_ sender: UIBarButtonItem) {
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







