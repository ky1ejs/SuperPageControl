//
//  ShapeDotConfig.swift
//  SuperPageControl
//
//  Created by Kyle McAlpine on 14/05/2016.
//  Copyright © 2016 Kyle McAlpine. All rights reserved.
//

import UIKit

public enum ShapeDot {
    case Circle
    case Square
    case Triangle
}

public typealias Shadow = (size: CGFloat, offset: CGSize, color: UIColor, blur: CGFloat)

public struct ShapeDotConfig {
    public let shape: ShapeDot
    public var color: UIColor?                                  // Set to 0.25 alpha of selectedColor if nil
    public var shadow: Shadow?                                  // Optional, no shadow if nil
    public var size: CGSize?                                    // Falls back on global size
    public var selectedShape: ShapeDot?                         // Falls back on shape
    public var selectedColor: UIColor = UIColor.blackColor()
    public var selectedShadow: Shadow?                          // Falls back on shadow
    public var selectedSize: CGSize?                            // Falls back on size
    
    public init(shape: ShapeDot) {
        self.shape = shape
    }
}


// MARK: - Equatable
public func ==(lhs: ShapeDotConfig, rhs: ShapeDotConfig) -> Bool {
    if (lhs.shadow == nil && rhs.shadow != nil)
        || (lhs.shadow != nil && rhs.shadow == nil)
        || (lhs.selectedShadow == nil && rhs.selectedShadow != nil)
        || (lhs.selectedShadow != nil && rhs.selectedShadow == nil) {
        return false
    }
    if let lhsShadow = lhs.shadow, rhsShadow = rhs.shadow {
        if lhsShadow != rhsShadow {
            return false
        }
    }
    if let lhsSelectedShadow = lhs.selectedShadow, rhsSelectedShadow = rhs.selectedShadow {
        if lhsSelectedShadow != rhsSelectedShadow {
            return false
        }
    }
    return lhs.shape == rhs.shape
        && lhs.color == rhs.color
        && lhs.selectedShape == rhs.selectedShape
        && lhs.selectedColor == rhs.selectedColor
}

// Equatability for Shadow tuple
func == <T1:Equatable, T2:Equatable, T3:Equatable, T4:Equatable> (lhs: (T1, T2, T3, T4), rhs: (T1, T2, T3, T4)) -> Bool {
    return lhs.0 == rhs.0 &&
        lhs.1 == rhs.1 &&
        lhs.2 == rhs.2 &&
        lhs.3 == rhs.3
}
