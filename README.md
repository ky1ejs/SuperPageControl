
SuperPageControl is a replacement for UIPageControl that gives:

- Images
- CGPaths
- Granular control over each dot

### Carthage

```
github "kylejm/SuperPageControl" >= 0.1
```

### Modes

```swift
public enum DotMode: Equatable {
    case Image(ImageDotConfig)
    case Path(path: CGPathRef, selectedPath: CGPathRef?)
    case Shape(ShapeDotConfig)
    case Individual(DotModeGenerator)
}

public typealias DotModeGenerator = (index: Int, pageControl: SuperPageControl) -> DotMode
```

### Preset shapes

```swift
enum Shape {
    case Circle
    case Square
    case Triangle
}
```
