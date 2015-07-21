//
//  SuperPageControl.swift
//
//  Created by Kyle McAlpine on 17/07/2015.
//  Copyright (c) 2015 Kyle McAlpine. All rights reserved.
//

import UIKit

public protocol SuperPageControlDelegate {
    func modeForDot(index: Int, pageControl: SuperPageControl) -> SuperPageControlDotMode
}

public enum SuperPageControlDotShape {
    case Circle
    case Square
    case Triangle
}

//final class WeakBox<T: AnyObject> {
//    // weak variable must be optional in case it gets deallocated
//    weak private(set) var value: T?
//    
//    init(_ value: T) {
//        self.value = value
//    }
//}

public enum SuperPageControlDotMode: Equatable {
    case Image(image: UIImage, selectedImage: UIImage?)
    case Path(path: CGPathRef, selectedPath: CGPathRef?)
    case Shape(shape: SuperPageControlDotShape, selectedShape: SuperPageControlDotShape?)
    //    case Individual(WeakBox<ImagePageControlDelegate>)
    case Individual(SuperPageControlDelegate)
}

public func ==(lhs: SuperPageControlDotMode, rhs: SuperPageControlDotMode) -> Bool {
    switch (lhs, rhs) {
    case let (.Image(lhsImage, lhsSelectedImage), .Image(rhsImage, rhsSelectedImage))
        where lhsImage == rhsImage && lhsSelectedImage == rhsSelectedImage:
        return true
    case let (.Path(lhsPath, lhsSelectedPath), .Path(rhsPath, rhsSelectedPath))
        where lhsPath === rhsPath && lhsSelectedPath === rhsSelectedPath:
        return true
    case let (.Shape(lhsShape, lhsSelectedShape), .Shape(rhsShape, rhsSelectedShape))
        where lhsShape == rhsShape && lhsSelectedShape == rhsSelectedShape:
        return true
    case (.Individual, .Individual):
        // Comparing the delegate is hard. Can't make it Equatable as it then can't be used with enums
        // Will come back to this... Famous last words..
        return true
    default:
        return false
    }
}

@IBDesignable public class SuperPageControl: UIControl {
    @IBInspectable public var numberOfPages: Int = 1 {
        didSet {
            if numberOfPages != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var currentPage: Int = 1 {
        didSet {
            if currentPage != oldValue {
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
    
    public var mode = SuperPageControlDotMode.Shape(shape: .Circle, selectedShape: nil) {
        didSet {
            if mode != oldValue {
                self.setNeedsDisplay()
            }
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
    @IBInspectable public var dotShadowOffset: CGSize = CGSizeMake(0, 1) {
        didSet {
            if dotShadowOffset != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var dotColor: UIColor? {
        didSet {
            if dotColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var dotShadowColor: UIColor = .clearColor() {
        didSet {
            if dotShadowColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var dotShadowBlur: CGFloat = 0 {
        didSet {
            if dotShadowBlur != oldValue {
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
    @IBInspectable public var selectedDotColor: UIColor = .blackColor() {
        didSet {
            if selectedDotColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var selectedDotShadowColor: UIColor? {
        didSet {
            if selectedDotShadowColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var selectedDotShadowBlur: CGFloat? {
        didSet {
            if selectedDotShadowBlur != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable public var selectedDotShadowOffset: CGSize? {
        didSet {
            if selectedDotShadowOffset != oldValue {
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
            case let .Individual(delegate):
                for i in 0...self.numberOfPages - 1 {
                    self.drawDot(delegate.modeForDot(i, pageControl: self), atIndex: i, context: context)
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
            var dotSize = self.dotSize
            var dotShadowColor = self.dotShadowColor
            var dotShadowOffset = self.dotShadowOffset
            var dotShadowBlur = self.dotShadowBlur
            if i == self.currentPage {
                if let selectedDotSize = self.selectedDotSize {
                    dotSize = selectedDotSize
                }
                if let selectedDotShadowColor = self.selectedDotShadowColor {
                    dotShadowColor = selectedDotShadowColor
                }
                if let selectedDotShadowOffset = self.selectedDotShadowOffset {
                    dotShadowOffset = selectedDotShadowOffset
                }
                if let selectedDotShadowBlur = self.selectedDotShadowBlur {
                    dotShadowBlur = selectedDotShadowBlur
                }
            }
            
            // Offset for dot i
            CGContextSaveGState(context)
            let offset = (self.dotSize + self.dotSpaceing) * CGFloat(i) + self.dotSize / 2
            CGContextTranslateCTM(context, self.vertical ? 0 : offset, self.vertical ? offset : 0);
            
            switch mode {
            case let .Image(image, selectedImage):
                let dotImage = (i == self.currentPage && selectedImage != nil) ? selectedImage! : image
                dotImage.drawInRect(CGRectMake(-dotImage.size.width / 2, -dotImage.size.height / 2, dotImage.size.width, dotImage.size.height))
                break
            case let .Path(path, selectedPath):
                let dotPath = (i == self.currentPage && selectedPath != nil) ? selectedPath! : path
                CGContextBeginPath(context)
                CGContextAddPath(context, dotPath)
                CGContextFillPath(context)
                break
            case let .Shape(shape, selectedShape):
                if dotShadowColor !=  .clearColor() {
                    CGContextSetShadowWithColor(context, dotShadowOffset, dotShadowBlur, dotShadowColor.CGColor);
                }
                
                let dotShape = (i == self.currentPage && selectedShape != nil) ? selectedShape! : shape
                if i == self.currentPage {
                    self.selectedDotColor.setFill()
                } else if let dotColor = self.dotColor {
                    dotColor.setFill()
                } else {
                    self.selectedDotColor.colorWithAlphaComponent(0.25).setFill()
                }
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
        self.currentPage = forward ? self.currentPage + 1 : self.currentPage - 1
        if !self.defersCurrentPageDisplay {
            self.setNeedsDisplay()
        } else {
            self.sendActionsForControlEvents(.ValueChanged)
            super.endTrackingWithTouch(touch, withEvent: event)
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
        
        var dotShadowOffset = (self.dotShadowColor != .clearColor()) ? self.dotShadowOffset : CGSizeZero
        var dotShadowBlur = (self.dotShadowColor != .clearColor()) ? self.dotShadowBlur : 0
        if let selectedDotShadowColor = self.selectedDotShadowColor where selectedDotShadowColor != .clearColor() {
            if let selectedDotShadowOffset = self.selectedDotShadowOffset {
                dotShadowOffset = CGSizeMake(max(dotShadowOffset.width, selectedDotShadowOffset.width), max(dotShadowOffset.height, selectedDotShadowOffset.height))
            }
            if let selectedDotShadowBlur = self.selectedDotShadowBlur {
                dotShadowBlur = max(dotShadowBlur, selectedDotShadowBlur)
            }
        }
        dotSize.width += (dotShadowOffset.width * 2) + (dotShadowBlur * 2)
        dotSize.height += (dotShadowOffset.height * 2) + (dotShadowBlur * 2)
        
        return dotSize
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return self.sizeThatFits(self.bounds.size)
    }
}
