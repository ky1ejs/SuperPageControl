//
//  SuperPageControl.swift
//
//  Created by Kyle McAlpine on 17/07/2015.
//  Copyright (c) 2015 Kyle McAlpine. All rights reserved.
//

import UIKit

public enum SuperPageControlDotShape {
    case Circle
    case Square
    case Triangle
}

public typealias Shadow = (size: CGFloat, offset: CGSize, color: UIColor, blur: CGFloat)

public struct SuperPageControlShapeConfiguation {
    public let shape: SuperPageControlDotShape
    public var color: UIColor?                                  // Set to 0.25 alpha of selectedColor if nil
    public var shadow: Shadow?                                  // Optional, no shadow if nil
    public var size: CGSize?                                    // Falls back on global size
    public var selectedShape: SuperPageControlDotShape?         // Falls back on shape
    public var selectedColor: UIColor = UIColor.blackColor()
    public var selectedShadow: Shadow?                          // Falls back on shadow
    public var selectedSize: CGSize?                            // Falls back on size
    
    public init(shape: SuperPageControlDotShape) {
        self.shape = shape
    }
}

public struct SuperPageControlImageConfiguration {
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

public typealias DotModeGenerator = (index: Int, pageControl: SuperPageControl) -> SuperPageControlDotMode

public enum SuperPageControlDotMode: Equatable {
    case Image(SuperPageControlImageConfiguration)
    case Path(path: CGPathRef, selectedPath: CGPathRef?)
    case Shape(SuperPageControlShapeConfiguation)
    //    case Individual(WeakBox<ImagePageControlDelegate>)
    case Individual(DotModeGenerator)
    
    // Helper to calculate size
    private func shadowsForPageControl(pageControl: SuperPageControl) -> [Shadow]? {
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

//final class WeakBox<T: AnyObject> {
//    // weak variable must be optional in case it gets deallocated
//    weak private(set) var value: T?
//
//    init(_ value: T) {
//        self.value = value
//    }
//}

@IBDesignable public class SuperPageControl: UIControl {
    @IBInspectable public var numberOfPages: Int = 1 {
        didSet {
            if numberOfPages != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    private var _currentPage = 1
    @IBInspectable public var currentPage: Int {
        get {
            return _currentPage
        }
        set {
            if newValue >= 0 && newValue < self.numberOfPages &&  newValue !=  _currentPage {
                _currentPage = newValue
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var defersCurrentPageDisplay: Bool = false
    @IBInspectable public var hidesForSinglePage = false {
        didSet {
            if hidesForSinglePage != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    //    @property (nonatomic, assign, getter = isWrapEnabled) IBInspectable BOOL wrapEnabled;
    @IBInspectable public var vertical: Bool = false {
        didSet {
            if vertical != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    public var mode = SuperPageControlDotMode.Shape(SuperPageControlShapeConfiguation(shape: .Circle)) {
        didSet {
            // TODO: check equality when setting .Individual cases bad access
            // unless you stick a break point in the SuperPageControlDotMode
            // == function
//            if mode != oldValue {
                self.setNeedsDisplay()
//            }
        }
    }
    @IBInspectable public var dotSpaceing: CGFloat = 10 {
        didSet {
            if dotSpaceing != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var dotSize: CGFloat = 10 {
        didSet {
            if dotSize != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var selectedDotSize: CGFloat? {
        didSet {
            if selectedDotSize != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    // mark - Initialisation
    func initialise() {
        self.contentMode = .Redraw
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    public func sizeForNumberOfPages(numberOfPages: Int) -> CGSize {
        let width = self.dotSize + (self.dotSize + self.dotSpaceing) * CGFloat((numberOfPages - 1))
        return self.vertical ? CGSizeMake(self.dotSize, width) : CGSizeMake(width, self.dotSize);
    }
    
    public func updateCurrentPageDisplay() {
        self.setNeedsDisplay()
    }
    
    override public func drawRect(rect: CGRect) {
        self.drawForMode(self.mode)
    }
    
    func drawForMode(mode: SuperPageControlDotMode) {
        if self.numberOfPages > 1 || !self.hidesForSinglePage {
            
            let context = UIGraphicsGetCurrentContext()
            let size = self.sizeForNumberOfPages(self.numberOfPages)
            if self.vertical {
                CGContextTranslateCTM(context, self.frame.size.width / 2, (self.frame.size.height - size.height) / 2)
            } else {
                CGContextTranslateCTM(context, (self.frame.size.width - size.width) / 2, self.frame.size.height / 2)
            }
            
            // Change to if statement when Swift 2.0 brings switch's pattern matching to if
            switch self.mode {
            case let .Individual(generator):
                for i in 0...self.numberOfPages - 1 {
                    self.drawDot(generator(index: i, pageControl: self), atIndex: i, context: context)
                }
                break
            default:
                for i in 0...self.numberOfPages - 1 {
                    self.drawDot(self.mode, atIndex: i, context: context)
                }
                break
            }
        }
    }
    
    func drawDot(mode: SuperPageControlDotMode, atIndex i: Int, context: CGContextRef) {
        switch mode {
        case .Individual:
            self.drawForMode(mode)
        default:
            // Offset for dot i
            CGContextSaveGState(context)
            let offset = (self.dotSize + self.dotSpaceing) * CGFloat(i) + self.dotSize / 2
            CGContextTranslateCTM(context, self.vertical ? 0 : offset, self.vertical ? offset : 0);
            
            switch mode {
            case let .Image(imageConfig):
                var dotImage = imageConfig.image
                var tint = imageConfig.tintColor
                if i == self.currentPage {
                    if let selectedImage = imageConfig.selectedImage {
                        dotImage = selectedImage
                    }
                    tint = imageConfig.selectedTintColor
                }
                if tint != nil {
                    dotImage = dotImage.tintWithColor(tint!)
                }
                dotImage.drawInRect(CGRectMake(-dotSize / 2, -dotSize / 2, dotSize, dotSize))
                break
            case let .Path(path, selectedPath):
                let dotPath = (i == self.currentPage) ? selectedPath ?? path : path
                CGContextBeginPath(context)
                CGContextAddPath(context, dotPath)
                CGContextFillPath(context)
                break
            case let .Shape(shapeConfig):
                if i == self.currentPage, let shadow = shapeConfig.selectedShadow where shadow.color != .clearColor() {
                    CGContextSetShadowWithColor(context, shadow.offset, shadow.blur, shadow.color.CGColor)
                } else if let shadow = shapeConfig.shadow where shadow.color != .clearColor() {
                    CGContextSetShadowWithColor(context, shadow.offset, shadow.blur, shadow.color.CGColor)
                }
                
                if i == self.currentPage {
                    shapeConfig.selectedColor.setFill()
                } else if let dotColor = shapeConfig.color {
                    dotColor.setFill()
                } else {
                    shapeConfig.selectedColor.colorWithAlphaComponent(0.25).setFill()
                }
                
                let dotSize = (i == self.currentPage) ? self.selectedDotSize ?? self.dotSize : self.dotSize
                let dotShape = (i == self.currentPage) ? shapeConfig.selectedShape ?? shapeConfig.shape : shapeConfig.shape
                switch dotShape {
                case .Circle:
                    CGContextFillEllipseInRect(context, CGRectMake(-dotSize / 2, -dotSize / 2, dotSize, dotSize));
                    break
                case .Square:
                    CGContextFillRect(context, CGRectMake(-dotSize / 2, -dotSize / 2, dotSize, dotSize));
                    break
                case .Triangle:
                    CGContextBeginPath(context);
                    CGContextMoveToPoint(context, 0, -dotSize / 2);
                    CGContextAddLineToPoint(context, dotSize / 2, dotSize / 2);
                    CGContextAddLineToPoint(context, -dotSize / 2, dotSize / 2);
                    CGContextAddLineToPoint(context, 0, -dotSize / 2);
                    CGContextFillPath(context);
                    break
                }
                break
            default:
                break
            }
            
            CGContextRestoreGState(context);
            break
        }
    }
    
    override public func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        let point = touch.locationInView(self)
        let forward = self.vertical ? (point.y > self.frame.size.height / 2) : (point.x > self.frame.size.width / 2)
        let newPage = forward ? self.currentPage + 1 : self.currentPage - 1
        if newPage >= 0 && newPage < self.numberOfPages {
            _currentPage = newPage
            if !self.defersCurrentPageDisplay {
                self.setNeedsDisplay()
            } else {
                self.sendActionsForControlEvents(.ValueChanged)
                super.endTrackingWithTouch(touch, withEvent: event)
            }
        }
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        var dotSize = self.sizeForNumberOfPages(self.numberOfPages)
        if let selectedDotSize = self.selectedDotSize {
            let width = selectedDotSize - self.dotSize
            let height = max(36, max(self.dotSize, selectedDotSize))
            dotSize.width = self.vertical ? height : dotSize.width + width
            dotSize.height = self.vertical ? dotSize.height + width : height
        }
        
        if let shadows = self.mode.shadowsForPageControl(self) {
            var shadowOffset = CGSizeZero
            var shadowBlur: CGFloat = 0
            for shadow in shadows {
                shadowOffset = CGSizeMake(max(shadowOffset.width, shadow.offset.width), max(shadowOffset.height, shadow.offset.height))
                shadowBlur = max(shadowBlur, shadow.blur)
            }
            dotSize.width += (shadowOffset.width * 2) + (shadowBlur * 2)
            dotSize.height += (shadowOffset.height * 2) + (shadowBlur * 2)
        }
        
        return dotSize
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return self.sizeThatFits(self.bounds.size)
    }
}

extension UIImage {
    func tintWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
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
public func ==(lhs: SuperPageControlDotMode, rhs: SuperPageControlDotMode) -> Bool {
    switch (lhs, rhs) {
    case let (.Image(lhsImageConfig), .Image(rhsImageConfig))
        where lhsImageConfig == rhsImageConfig:
        return true
    case let (.Path(lhsPath, lhsSelectedPath), .Path(rhsPath, rhsSelectedPath))
        where lhsPath === rhsPath && lhsSelectedPath === rhsSelectedPath:
        return true
    case let (.Shape(lhsShapeConfig), .Shape(rhsShapeConfig))
        where lhsShapeConfig == lhsShapeConfig:
        return true
    case (.Individual, .Individual):
        // Comparing the delegate is hard. Can't make it Equatable as it then can't be used with enums
        // Will come back to this... Famous last words..
        return true
    default:
        return false
    }
}

public func ==(lhs: SuperPageControlShapeConfiguation, rhs: SuperPageControlShapeConfiguation) -> Bool {
    if (lhs.shadow == nil && rhs.shadow != nil)
        || (lhs.shadow != nil && rhs.shadow == nil)
        || (lhs.selectedShadow == nil && rhs.selectedShadow != nil)
        || (lhs.selectedShadow != nil && rhs.selectedShadow == nil) {
        return false
    }
    if let lhsShadow = lhs.shadow, rhsShadow = rhs.shadow {
        if !(lhsShadow == rhsShadow) {
            return false
        }
    }
    if let lhsSelectedShadow = lhs.selectedShadow, rhsSelectedShadow = rhs.selectedShadow {
        if !(lhsSelectedShadow == rhsSelectedShadow) {
            return false
        }
    }
    return lhs.shape == rhs.shape
        && lhs.color == rhs.color
        && lhs.selectedShape == rhs.selectedShape
        && lhs.selectedColor == rhs.selectedColor
}

public func ==(lhs: SuperPageControlImageConfiguration, rhs: SuperPageControlImageConfiguration) -> Bool {
    return lhs.image == rhs.image
    && lhs.selectedImage == rhs.selectedImage
    && lhs.selectedTintColor == rhs.selectedTintColor
        && lhs.tintColor == rhs.tintColor
}

func == <T:Equatable, T2:Equatable, T3:Equatable, T4:Equatable> (lhs: (T,T2,T3,T4), rhs: (T,T2,T3,T4)) -> Bool {
    return lhs.0 == rhs.0 &&
        lhs.1 == rhs.1 &&
        lhs.2 == rhs.2 &&
        lhs.3 == rhs.3
}
