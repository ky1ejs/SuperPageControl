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
    public var tintColor: UIColor? 
    
    private var _selectedImage: UIImage?
    public var selectedImage: UIImage { return self.selectedImage ?? self.image }
    public mutating func setSelectedImage(image: UIImage?) { self._selectedImage = image }
    
    private var _selectedTintColor: UIColor?
    public var selectedTintColor: UIColor? {
        get { return self._selectedTintColor ?? self.tintColor }
        set { self._selectedTintColor = newValue }
    }
    
    public init(image: UIImage) { self.image = image }
}


// MARK: - Equatable
public func ==(lhs: ImageDotConfig, rhs: ImageDotConfig) -> Bool {
    return lhs.image == rhs.image
        && lhs.selectedImage == rhs.selectedImage
        && lhs.selectedTintColor == rhs.selectedTintColor
        && lhs.tintColor == rhs.tintColor
}
