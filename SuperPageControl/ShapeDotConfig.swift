//
//  ShapeDotConfig.swift
//  SuperPageControl
//
//  Created by Kyle McAlpine on 14/05/2016.
//  Copyright © 2016 Kyle McAlpine. All rights reserved.
//

import UIKit

public enum Shape {
    case Circle
    case Square
    case Triangle
}

public typealias Shadow = (size: CGFloat, offset: CGSize, color: UIColor, blur: CGFloat)

public struct ShapeDotConfig {
    public let shape: Shape
    public var color: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
    public var shadow: Shadow?
    
    private var _selectedShape: Shape?
    public var selectedShape: Shape { return self._selectedShape ?? self.shape }
    public mutating func setSelectedShape(shape: Shape?) { self._selectedShape = shape }
    
    private var _selectedColor: UIColor?
    public var selectedColor: UIColor { return self._selectedColor ?? self.color }
    public mutating func setSelectedColor(color: UIColor?) { self._selectedColor = color }
    
    private var _selectedShadow: Shadow?
    public var selectedShadow: Shadow? {
        get { return self._selectedShadow ?? self.shadow }
        set { self._selectedShadow = newValue }
    }
    
    public init(shape: Shape) { self.shape = shape }
}


// MARK: - Equatable
public func ==(lhs: ShapeDotConfig, rhs: ShapeDotConfig) -> Bool {
    return lhs.shape == rhs.shape
        && lhs.color == rhs.color
        && lhs.shadow == rhs.shadow
        && lhs.selectedShape == rhs.selectedShape
        && lhs.selectedColor == rhs.selectedColor
        && lhs.selectedShadow == rhs.selectedShadow
}

// Equatability for Shadow tuple
func == <T1:Equatable, T2:Equatable, T3:Equatable, T4:Equatable> (lhs: (T1, T2, T3, T4)?, rhs: (T1, T2, T3, T4)?) -> Bool {
    return lhs?.0 == rhs?.0 &&
        lhs?.1 == rhs?.1 &&
        lhs?.2 == rhs?.2 &&
        lhs?.3 == rhs?.3
}
