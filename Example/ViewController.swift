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
    fileprivate var secondPageControl = SuperPageControl()
    fileprivate var thridPageControl = SuperPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.mode = DotMode.individual({ (index, pageControl) -> DotMode in
            pageControl.selectedDotSize = 20
            return .shape(ShapeDotConfig(shape: .circle))
        })
        
        self.secondPageControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.secondPageControl)
        self.secondPageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.secondPageControl.backgroundColor = .clear
        var shapeConfig = ShapeDotConfig(shape: .circle)
        shapeConfig.color = .red
        shapeConfig.setSelectedColor(.blue)
        self.secondPageControl.mode = .shape(shapeConfig)
        let topConstraint = self.secondPageControl.topAnchor.constraint(equalTo: self.view.topAnchor)
        topConstraint.constant = 100
        topConstraint.isActive = true
        
        self.view.addSubview(self.thridPageControl)
        self.thridPageControl.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-150-[pc]", options: [], metrics: nil, views: ["pc" : self.thridPageControl])
        constraints.append(NSLayoutConstraint(item: self.thridPageControl, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraints(constraints)
        self.thridPageControl.backgroundColor = .clear
        self.thridPageControl.defersCurrentPageDisplay = true
        self.thridPageControl.mode = DotMode.individual({ (index, pageControl) -> DotMode in
            var tick = ImageDotConfig(image: UIImage(named: "Tick")!)
            tick.tintColor = UIColor(red:0, green:0, blue:0, alpha: 0.16)
            tick.selectedTintColor = .white
            return .image(tick)
        })
        self.thridPageControl.dotSize = 20
        self.thridPageControl.dotSpaceing = 20
        self.thridPageControl.numberOfPages = 5
        self.thridPageControl.currentPage = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.secondPageControl.numberOfPages = 5
        self.secondPageControl.currentPage = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: AnyObject) {
        self.pageControl.currentPage += 1
        self.secondPageControl.currentPage += 1
    }
    
    @IBAction func previous(_ sender: AnyObject) {
        self.pageControl.currentPage -= 1
        self.secondPageControl.currentPage -= 1
    }
}

