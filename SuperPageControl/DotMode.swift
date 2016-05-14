//
//  DotMode.swift
//  SuperPageControl
//
//  Created by Kyle McAlpine on 14/05/2016.
//  Copyright © 2016 Kyle McAlpine. All rights reserved.
//

import UIKit

public typealias DotModeGenerator = (index: Int, pageControl: SuperPageControl) -> DotMode

public enum DotMode: Equatable {
    case Image(ImageDotConfig)
    case Path(path: CGPathRef, selectedPath: CGPathRef?)
    case Shape(ShapeDotConfig)
    case Individual(DotModeGenerator)
    
    // Helper to calculate size
    func shadowsForPageControl(pageControl: SuperPageControl) -> [Shadow]? {
        switch self {
        case let .Shape(shapeConfig):
            var shadows = [Shadow]()
            if let shadow = shapeConfig.shadow {
                shadows.append(shadow)
            }
            if let selectedShadow = shapeConfig.selectedShadow {
                shadows.append(selectedShadow)
            }
            return (shadows.count > 0) ? shadows : nil
        case let .Individual(generator):
            var shadows = [Shadow]()
            for i in 0...pageControl.numberOfPages - 1 {
                if let shadowsForPage = generator(index: i, pageControl: pageControl).shadowsForPageControl(pageControl) {
                    shadows += shadowsForPage
                }
            }
            return (shadows.count > 0) ? shadows : nil
        default:
            return nil
        }
    }
}


// MARK: - Equatable
public func ==(lhs: DotMode, rhs: DotMode) -> Bool {
    switch (lhs, rhs) {
    case let (.Image(lhsImageConfig), .Image(rhsImageConfig))
        where lhsImageConfig == rhsImageConfig:
        return true
    case let (.Path(lhsPath, lhsSelectedPath), .Path(rhsPath, rhsSelectedPath))
        where lhsPath === rhsPath && lhsSelectedPath === rhsSelectedPath:
        return true
    case let (.Shape(lhsShapeConfig), .Shape(rhsShapeConfig))
        where lhsShapeConfig == rhsShapeConfig:
        return true
    case (.Individual, .Individual):
        // Comparing the delegate is hard. Can't make it Equatable as it then can't be used with enums
        // Will come back to this... Famous last words..
        return true
    default:
        return false
    }
}
