//
//  SuperPageControl.swift
//
//  Created by Kyle McAlpine on 17/07/2015.
//  Copyright (c) 2015 Kyle McAlpine. All rights reserved.
//

import UIKit

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
    
    public var mode = DotMode.Shape(ShapeDotConfig(shape: .Circle)) {
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
    
    // MARK - Initialisation
    func initialise() {
        self.contentMode = .Redraw
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }

    required public init?(coder aDecoder: NSCoder) {
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
    
    func drawForMode(mode: DotMode) {
        if self.numberOfPages > 1 || !self.hidesForSinglePage {
            let context = UIGraphicsGetCurrentContext()!
            let size = self.sizeForNumberOfPages(self.numberOfPages)
            if self.vertical {
                CGContextTranslateCTM(context, self.frame.size.width / 2, (self.frame.size.height - size.height) / 2)
            } else {
                CGContextTranslateCTM(context, (self.frame.size.width - size.width) / 2, self.frame.size.height / 2)
            }
            
            if case .Individual(let generator) = self.mode {
                for i in 0...self.numberOfPages - 1 {
                    let mode = generator(index: i, pageControl: self)
                    self.drawDot(mode, atIndex: i, context: context)
                }
            } else {
                (0...self.numberOfPages - 1).forEach() { self.drawDot(self.mode, atIndex: $0, context: context) }
            }
        }
    }
    
    func drawDot(mode: DotMode, atIndex i: Int, context: CGContextRef) {
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
                if i == self.currentPage, let selectedShadow = shapeConfig.selectedShadow where selectedShadow.color != .clearColor() {
                    CGContextSetShadowWithColor(context, selectedShadow.offset, selectedShadow.blur, selectedShadow.color.CGColor)
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
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if let touch = touch {
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
