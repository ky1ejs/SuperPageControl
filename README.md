
SuperPageControl is a replacement for UIPageControl that gives:

- Images
- CGPaths
- Granular control over each dot

**Swift 2 since v0.3**


### Carthage

```
github "kylejm/SuperPageControl" >= 0.1
```

### Modes

```swift
.Image(UIImage)
.Path(CGPathRef)
.Preset(SuperPageControlDotShape)
.Individual(SuperPageControlDelegate)
```

The `.Individual`'s associated delegate gets asked for the mode for each individual dot.

### Preset shapes

```swift
enum SuperPageControlDotShape {
    case Circle
    case Square
    case Triangle
}
```

Please write more and PR :smile:

### Todo

- [ ] Delegate handling of dot colors
- [ ] Weak delegate - problem with making SuperPageControlDelegate Equatable and keeping enum association. See code comment.
