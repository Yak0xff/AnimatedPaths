# AnimatedPaths

Animating the drawing of a CGPath with the help of CAShapeLayer.strokeEnd.


The  Objective-C  Version is [here](https://github.com/ole/Animated-Paths).

Drawing Rectangle Path:
 
 ```swift
RCAnimatedPath.shared.drawAnimatedRectanglePath(in: targetView,
                                                            duration: 3,
                                                            lineWidth: 5,
                                                            lineColor: UIColor.red)
 ```

Drawing Polygon Path: 

```swift
RCAnimatedPath.shared.drawAnimatedPolygonPath(in: targetView,
                                                          numberOfSides: 8,
                                                          rotationAngle: 10,
                                                          polygonCornerRadius: 4,
                                                          duration: 3,
                                                          lineWidth: 5,
                                                          lineColor: UIColor.gray)
```

Drawing Text: 

```swift
RCAnimatedPath.shared.drawAnimatedText(in: targetView,
                                                   with: "Hello Swift!",
                                                   duration: 3,
                                                   lineWidth: 2,
                                                   textColor: UIColor.blue,
                                                   fontName: "PingFangSC-Bold",
                                                   fontSize: 50)
```

Drawing Custom Path: 

```swift
RCAnimatedPath.shared.drawAnimatedCustomPath(in: targetView,
                                                         path: ringPath.cgPath,
                                                         duration: 3,
                                                         lineWidth: 2,
                                                         lineColor: UIColor.black)
```
 
