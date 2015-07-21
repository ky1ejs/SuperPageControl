//
//  ViewController.swift
//  Development
//
//  Created by Kyle McAlpine on 20/07/2015.
//  Copyright (c) 2015 Kyle McAlpine. All rights reserved.
//

import UIKit
import SuperPageControl

class ViewController: UIViewController, SuperPageControlDelegate {
    @IBOutlet weak var pageControl: SuperPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.pageControl.mode = self.modeForDot(1, pageControl: self.pageControl)
        self.pageControl.mode = .Individual(self)
//        self.pageControl.mode = .Image(image: UIImage(named: "Cross")!, selectedImage: UIImage(named: "Tick")!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func modeForDot(index: Int, pageControl: SuperPageControl) -> SuperPageControlDotMode {
        return .Shape(shape: .Triangle, selectedShape: .Square)
//        return SuperPageControlDotMode.Image(image: UIImage(named: "Cross")!, selectedImage: UIImage(named: "Tick")!)
    }
}

