//
//  SuperPageControl.swift
//
//  Created by Kyle McAlpine on 17/07/2015.
//  Copyright (c) 2015 Kyle McAlpine. All rights reserved.
//

import UIKit

@IBDesignable open class SuperPageControl: UIControl {
    @IBInspectable open var numberOfPages: Int = 1 {
        didSet {
            if numberOfPages != oldValue {
                self.invalidateIntrinsicContentSize()
                self.setNeedsDisplay()
            }
        }
    }
    fileprivate var _currentPage = 1
    @IBInspectable open var currentPage: Int {
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
    @IBInspectable open var defersCurrentPageDisplay: Bool = false
    @IBInspectable open var hidesForSinglePage = false {
        didSet {
            if hidesForSinglePage != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable open var vertical: Bool = false {
        didSet {
            if vertical != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    open var mode = DotMode.shape(ShapeDotConfig(shape: .circle)) {
        didSet {
            if mode != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable open var dotSpaceing: CGFloat = 10 {
        didSet {
            if dotSpaceing != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable open var dotSize: CGFloat = 10 {
        didSet {
            if dotSize != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable open var selectedDotSize: CGFloat? {
        didSet {
            if selectedDotSize != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK - Initialisation
    func initialise() {
        self.contentMode = .redraw
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    open func sizeForNumberOfPages(_ numberOfPages: Int) -> CGSize {
        let width = self.dotSize + (self.dotSize + self.dotSpaceing) * CGFloat((numberOfPages - 1))
        return self.vertical ? CGSize(width: self.dotSize, height: width) : CGSize(width: width, height: self.dotSize)
    }
    
    open func updateCurrentPageDisplay() {
        self.setNeedsDisplay()
    }
    
    open override func layoutSubviews() {
        self.setNeedsDisplay()
    }
    
    override open func draw(_ rect: CGRect) {
        self.drawForMode(self.mode)
    }
    
    func drawForMode(_ mode: DotMode) {
        if self.numberOfPages > 1 || !self.hidesForSinglePage {
            let context = UIGraphicsGetCurrentContext()!
            let size = self.sizeForNumberOfPages(self.numberOfPages)
            if self.vertical {
                context.translateBy(x: self.frame.size.width / 2, y: (self.frame.size.height - size.height) / 2)
            } else {
                context.translateBy(x: (self.frame.size.width - size.width) / 2, y: self.frame.size.height / 2)
            }
            
            if case .individual(let generator) = self.mode {
                for i in 0...self.numberOfPages - 1 {
                    let mode = generator(i, self)
                    self.drawDot(mode, atIndex: i, context: context)
                }
            } else {
                (0...self.numberOfPages - 1).forEach() { [weak self] in
                    guard let safeSelf = self else { return }
                    safeSelf.drawDot(safeSelf.mode, atIndex: $0, context: context)
                }
            }
        }
    }
    
    func drawDot(_ mode: DotMode, atIndex i: Int, context: CGContext) {
        switch mode {
        case .individual:
            self.drawForMode(mode)
        default:
            // Offset for dot i
            context.saveGState()
            let offset = (self.dotSize + self.dotSpaceing) * CGFloat(i) + self.dotSize / 2
            context.translateBy(x: self.vertical ? 0 : offset, y: self.vertical ? offset : 0)
            
            switch mode {
            case let .image(imageConfig):
                var dotImage = i == self.currentPage ? imageConfig.selectedImage : imageConfig.image
                let tint = i == self.currentPage ? imageConfig.selectedTintColor : imageConfig.tintColor
                if let tint = tint {
                    dotImage = dotImage.tintWithColor(tint)
                }
                dotImage.draw(in: CGRect(x: -dotSize / 2, y: -dotSize / 2, width: dotSize, height: dotSize))
            case let .path(path, selectedPath):
                let dotPath = (i == self.currentPage) ? selectedPath ?? path : path
                context.beginPath()
                context.addPath(dotPath)
                context.fillPath()
            case let .shape(shapeConfig):
                if i == self.currentPage, let selectedShadow = shapeConfig.selectedShadow , selectedShadow.color != .clear {
                    context.setShadow(offset: selectedShadow.offset, blur: selectedShadow.blur, color: selectedShadow.color.cgColor)
                } else if let shadow = shapeConfig.shadow , shadow.color != .clear {
                    context.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color.cgColor)
                }
                
                if i == self.currentPage {
                    shapeConfig.selectedColor.setFill()
                } else {
                    shapeConfig.color.setFill()
                }
                
                let dotSize = (i == self.currentPage) ? self.selectedDotSize ?? self.dotSize : self.dotSize
                let dotShape = (i == self.currentPage) ? shapeConfig.selectedShape : shapeConfig.shape
                switch dotShape {
                case .circle:
                    context.fillEllipse(in: CGRect(x: -dotSize / 2, y: -dotSize / 2, width: dotSize, height: dotSize))
                case .square:
                    context.fill(CGRect(x: -dotSize / 2, y: -dotSize / 2, width: dotSize, height: dotSize))
                case .triangle:
                    context.beginPath()
                    context.move(to: CGPoint(x: 0, y: -dotSize / 2))
                    context.addLine(to: CGPoint(x: dotSize / 2, y: dotSize / 2))
                    context.addLine(to: CGPoint(x: -dotSize / 2, y: dotSize / 2))
                    context.addLine(to: CGPoint(x: 0, y: -dotSize / 2))
                    context.fillPath()
                }
            default:
                break
            }
            
            context.restoreGState()
            break
        }
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch = touch {
            let point = touch.location(in: self)
            let forward = self.vertical ? (point.y > self.frame.size.height / 2) : (point.x > self.frame.size.width / 2)
            let newPage = forward ? self.currentPage + 1 : self.currentPage - 1
            if newPage >= 0 && newPage < self.numberOfPages {
                _currentPage = newPage
                if !self.defersCurrentPageDisplay {
                    self.setNeedsDisplay()
                } else {
                    self.sendActions(for: .valueChanged)
                    super.endTracking(touch, with: event)
                }
            }
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var dotSize = self.sizeForNumberOfPages(self.numberOfPages)
        if let selectedDotSize = self.selectedDotSize {
            let width = selectedDotSize - self.dotSize
            let height = max(36, max(self.dotSize, selectedDotSize))
            dotSize.width = self.vertical ? height : dotSize.width + width
            dotSize.height = self.vertical ? dotSize.height + width : height
        }
        
        if let shadows = self.mode.shadowsForPageControl(self) {
            var shadowOffset = CGSize.zero
            var shadowBlur: CGFloat = 0
            for shadow in shadows {
                shadowOffset = CGSize(width: max(shadowOffset.width, shadow.offset.width), height: max(shadowOffset.height, shadow.offset.height))
                shadowBlur = max(shadowBlur, shadow.blur)
            }
            dotSize.width += (shadowOffset.width * 2) + (shadowBlur * 2)
            dotSize.height += (shadowOffset.height * 2) + (shadowBlur * 2)
        }
        
        return dotSize
    }
    
    override open var intrinsicContentSize : CGSize {
        return self.sizeThatFits(self.bounds.size)
    }
}
