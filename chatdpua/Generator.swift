//
//  VersusGenerator.swift
//  chatdpua
//
//  Created by Artem on 2/4/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit.UIImage

protocol GeneratorDelegate: class {
    func didUpdatePostsArray(generator: Generator)
}

class Generator {
    
    weak var delegate: GeneratorDelegate?
    
    var versusPosts: [Versus] = {
        var versusPosts = [Versus]()
        
        return versusPosts
        }() {
        didSet {
            delegate?.didUpdatePostsArray(generator: self)
        }
    }
    
    var trueFalsePosts: [TrueFalse] = {
        var trueFalsePosts = [TrueFalse]()
        return trueFalsePosts
        }() {
        didSet {
            delegate?.didUpdatePostsArray(generator: self)
        }
    }
    
    var classicTriviaPosts: [ClassicTrivia] = {
        var classicTriviaPosts = [ClassicTrivia]()
        return classicTriviaPosts
        }() {
        didSet {
            delegate?.didUpdatePostsArray(generator: self)
        }
    }
}
