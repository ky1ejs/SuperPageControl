//
//  ImageDotConfig.swift
//  SuperPageControl
//
//  Created by Kyle McAlpine on 14/05/2016.
//  Copyright © 2016 Kyle McAlpine. All rights reserved.
//

import UIKit

public struct ImageDotConfig {
    public let image: UIImage
    public var tintColor: UIColor?          // No tint color if not set
    public var size: CGSize?                // Falls back on global size
    public var selectedImage: UIImage?      // Falls back on image
    public var selectedTintColor: UIColor?  // Falls back on tintColor
    public var selectedSize: CGSize?        // Falls back on size
    
    public init(image: UIImage) {
        self.image = image
    }
}


// MARK: - Equatable
public func ==(lhs: ImageDotConfig, rhs: ImageDotConfig) -> Bool {
    return lhs.image == rhs.image
        && lhs.selectedImage == rhs.selectedImage
        && lhs.selectedTintColor == rhs.selectedTintColor
        && lhs.tintColor == rhs.tintColor
}
