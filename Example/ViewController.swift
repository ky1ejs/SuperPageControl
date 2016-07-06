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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.mode = DotMode.Individual({ (index, pageControl) -> DotMode in
            self.pageControl.selectedDotSize = 20
            return .Shape(ShapeDotConfig(shape: .Circle))
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(sender: AnyObject) {
        self.pageControl.currentPage += 1
    }
    
    @IBAction func previous(sender: AnyObject) {
        self.pageControl.currentPage -= 1
    }
}

