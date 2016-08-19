//
//  ViewController.swift
//  Development
//
//  Created by Kyle McAlpine on 20/07/2015.
//  Copyright (c) 2015 Kyle McAlpine. All rights reserved.
//

import UIKit
import SuperPageControl

class ViewController: UIViewController {
    @IBOutlet weak var pageControl: SuperPageControl!
    private var secondPageControl = SuperPageControl()
    private var thridPageControl = SuperPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.mode = DotMode.Individual({ (index, pageControl) -> DotMode in
            pageControl.selectedDotSize = 20
            return .Shape(ShapeDotConfig(shape: .Circle))
        })
        
        self.secondPageControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.secondPageControl)
        self.secondPageControl.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        self.secondPageControl.backgroundColor = .clearColor()
        var shapeConfig = ShapeDotConfig(shape: .Circle)
        shapeConfig.color = .redColor()
        shapeConfig.setSelectedColor(.blueColor())
        self.secondPageControl.mode = .Shape(shapeConfig)
        let topConstraint = self.secondPageControl.topAnchor.constraintEqualToAnchor(self.view.topAnchor)
        topConstraint.constant = 100
        topConstraint.active = true
        
        self.view.addSubview(self.thridPageControl)
        self.thridPageControl.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-150-[pc]", options: [], metrics: nil, views: ["pc" : self.thridPageControl])
        constraints.append(NSLayoutConstraint(item: self.thridPageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraints(constraints)
        self.thridPageControl.backgroundColor = .clearColor()
        self.thridPageControl.defersCurrentPageDisplay = true
        self.thridPageControl.mode = DotMode.Individual({ (index, pageControl) -> DotMode in
            var tick = ImageDotConfig(image: UIImage(named: "Tick")!)
            tick.tintColor = UIColor(red:0, green:0, blue:0, alpha: 0.16)
            tick.selectedTintColor = .whiteColor()
            return .Image(tick)
        })
        self.thridPageControl.dotSize = 20
        self.thridPageControl.dotSpaceing = 20
        self.thridPageControl.numberOfPages = 5
        self.thridPageControl.currentPage = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.secondPageControl.numberOfPages = 5
        self.secondPageControl.currentPage = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(sender: AnyObject) {
        self.pageControl.currentPage += 1
        self.secondPageControl.currentPage += 1
    }
    
    @IBAction func previous(sender: AnyObject) {
        self.pageControl.currentPage -= 1
        self.secondPageControl.currentPage -= 1
    }
}

