//
//  ViewController.swift
//  AnimatedPaths
//
//  Created by Robin on 16/2/23.
//  Copyright © 2016年 Robin. All rights reserved.
//

import UIKit
import QuartzCore
import CoreText
import CoreGraphics

class ViewController: UIViewController, CAAnimationDelegate {
    
    var animationLayer: CALayer?
    var pathLayer: CAShapeLayer?
    var penLayer: CALayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let targetView: UIView = self.view
        
        RCAnimatedPath().drawAnimatedRectanglePath(in: targetView, duration: 10, lineWidth: 20, lineColor: UIColor.red)

        RCAnimatedPath().drawAnimatedPolygonPath(in: targetView, numberOfSides: 8, rotationAngle: 30, polygonCornerRadius: 8, duration: 10, lineWidth: 5, lineColor: UIColor.gray)

        RCAnimatedPath().drawAnimatedText(in: targetView, with: "K E G", duration: 10, lineWidth: 2, textColor: UIColor.blue, fontName: "anyFontName", fontSize: 50)

//        RCAnimatedPath().drawAnimatedCustomPath(in: targetView, path: myPath, duration: 15, lineWidth: 5, lineColor: UIColor.blue)

        RCAnimatedPath.shared.drawAnimatedRectanglePath(in: targetView, duration: 10, lineWidth: 20, lineColor: UIColor.red)

        
//        animationLayer = CALayer()
//        animationLayer?.frame = CGRect(x: 20.0, y: 40.0, width: self.view.layer.bounds.width - 40.0, height: self.view.layer.bounds.height - 84.0)
//        self.view.layer.addSublayer(animationLayer!)
//
//        setupDrawingLayer()
//        startAnimation()
    }
    
    func clearLayer() {
        if let _ = pathLayer{
            penLayer?.removeFromSuperlayer()
            pathLayer?.removeFromSuperlayer()
            penLayer = nil
            pathLayer = nil
        }
    }
    
    func setupPenLayer() {
        let penImage = UIImage(named: "noun_project_347_2")!
        let pensLayer = CALayer()
        pensLayer.contents = penImage.cgImage
        pensLayer.anchorPoint = CGPoint.zero
        pensLayer.frame = CGRect(x: 0.0, y: 0.0, width: penImage.size.width, height: penImage.size.height)
        pathLayer?.addSublayer(pensLayer)
        
        penLayer = pensLayer

    }
    
    func setupDrawingLayer() {
    
        clearLayer()
        
        if let _ = animationLayer{
            let pathRect: CGRect = animationLayer!.bounds.insetBy(dx: 100.0, dy: 100.0)
            let bottomLeft = CGPoint(x: pathRect.minX, y: pathRect.minY)
            let topLeft = CGPoint(x: pathRect.minX, y: pathRect.minY + pathRect.height * 2.0 / 3.0)
            let bottomRight = CGPoint(x: pathRect.maxX, y: pathRect.minY)
            let topRight = CGPoint(x: pathRect.maxX, y: pathRect.minY + pathRect.height * 2.0 / 3.0)
            let roofTip = CGPoint(x: pathRect.midX, y: pathRect.maxY)
            
            let path = UIBezierPath()
            path.move(to: bottomLeft)
            path.addLine(to: topLeft)
            path.addLine(to: roofTip)
            path.addLine(to: topRight)
            path.addLine(to: topLeft)
            path.addLine(to: bottomRight)
            path.addLine(to: topRight)
            path.addLine(to: bottomLeft)
            path.addLine(to: bottomRight)
            
            let pathShapeLayer = CAShapeLayer()
            pathShapeLayer.frame = animationLayer!.bounds
            pathShapeLayer.bounds = pathRect
            pathShapeLayer.isGeometryFlipped = true
            pathShapeLayer.path = path.cgPath
            pathShapeLayer.strokeColor = UIColor.black.cgColor
            pathShapeLayer.fillColor = nil
            pathShapeLayer.lineWidth = 10.0
            pathShapeLayer.lineJoin = kCALineJoinBevel
            
            animationLayer!.addSublayer(pathShapeLayer)
            
            pathLayer = pathShapeLayer
        }
        
        setupPenLayer()
    }
    
    
    
    func setupTextLayer() {
        clearLayer() 

        let font = CTFontCreateWithName("PingFangSC-Light" as CFString, 120, nil)
        let attrStr = NSAttributedString(string: "Hello Swift", attributes: [kCTFontAttributeName as String: font])
        let line = CTLineCreateWithAttributedString(attrStr)
        let runArray = CTLineGetGlyphRuns(line)
        
        let letters = CGMutablePath()
        
        for runIndex in 0..<CFArrayGetCount(runArray) {
            let runUnsafe: UnsafeRawPointer = CFArrayGetValueAtIndex(runArray, runIndex)
            let run = unsafeBitCast(runUnsafe, to: CTRun.self)

            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run) {
                let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                var glyph: CGGlyph = CGGlyph()
                var position: CGPoint = CGPoint()
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                let letter = CTFontCreatePathForGlyph(font, glyph, nil)
                let t = CGAffineTransform(translationX: position.x, y: position.y);
                
                letters.addPath(letter!, transform:t)
            }
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.append(UIBezierPath(cgPath: letters))
        
        
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 10, y: 120, width: self.view.layer.bounds.width - 20, height: 100)
        layer.isGeometryFlipped = true
        layer.path = path.cgPath
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = nil
        layer.lineWidth = 3.0
        layer.lineJoin = kCALineJoinBevel
        
        animationLayer?.addSublayer(layer)
        
        pathLayer = layer
        
        setupPenLayer()
    }
    
    func startAnimation() {
        penLayer?.removeAllAnimations()
        pathLayer?.removeAllAnimations()
        
        penLayer?.isHidden = false
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 10.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        pathLayer?.add(pathAnimation, forKey: "strokeEnd")
        
        let penAnimation = CAKeyframeAnimation(keyPath: "position")
        penAnimation.duration = 10.0
        penAnimation.path = pathLayer?.path
        penAnimation.calculationMode = kCAAnimationPaced
        penAnimation.delegate = self
        penLayer?.add(penAnimation, forKey: "position")
    }
    
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
         penLayer?.isHidden = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    @IBAction func replayAction(_ sender: AnyObject) {
        startAnimation()
    }

    @IBAction func drawingTypeSelector(_ sender: AnyObject) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            setupDrawingLayer()
        case 1:
            setupTextLayer()
        default:
            break
        }
        startAnimation()
    }
}

