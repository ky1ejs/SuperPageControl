//
//  DotMode.swift
//  SuperPageControl
//
//  Created by Kyle McAlpine on 14/05/2016.
//  Copyright © 2016 Kyle McAlpine. All rights reserved.
//

import UIKit

public typealias DotModeGenerator = (_ index: Int, _ pageControl: SuperPageControl) -> DotMode

public enum DotMode: Equatable {
    case image(ImageDotConfig)
    case path(path: CGPath, selectedPath: CGPath?)
    case shape(ShapeDotConfig)
    case individual(DotModeGenerator)
    
    // Helper to calculate size
    func shadowsForPageControl(_ pageControl: SuperPageControl) -> [Shadow]? {
        switch self {
        case let .shape(shapeConfig):
            var shadows = [Shadow]()
            if let shadow = shapeConfig.shadow {
                shadows.append(shadow)
            }
            if let selectedShadow = shapeConfig.selectedShadow {
                shadows.append(selectedShadow)
            }
            return (shadows.count > 0) ? shadows : nil
        case let .individual(generator):
            var shadows = [Shadow]()
            for i in 0...pageControl.numberOfPages - 1 {
                if let shadowsForPage = generator(i, pageControl).shadowsForPageControl(pageControl) {
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
    case let (.image(lhsImageConfig), .image(rhsImageConfig))
        where lhsImageConfig == rhsImageConfig:
        return true
    case let (.path(lhsPath, lhsSelectedPath), .path(rhsPath, rhsSelectedPath))
        where lhsPath === rhsPath && lhsSelectedPath === rhsSelectedPath:
        return true
    case let (.shape(lhsShapeConfig), .shape(rhsShapeConfig))
        where lhsShapeConfig == rhsShapeConfig:
        return true
    case (.individual, .individual):
        // Comparing the delegate is hard. Can't make it Equatable as it then can't be used with enums
        // Will come back to this... Famous last words..
        return true
    default:
        return false
    }
}
