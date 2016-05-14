//
//  UIImageHelpers.swift
//  SuperPageControl
//
//  Created by Kyle McAlpine on 14/05/2016.
//  Copyright © 2016 Kyle McAlpine. All rights reserved.
//

import UIKit

extension UIImage {
    func tintWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        CGContextClipToMask(context, rect, self.CGImage)
        color.setFill()
        CGContextFillRect(context, rect);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGContextRestoreGState(context)
        return newImage;
    }
}
