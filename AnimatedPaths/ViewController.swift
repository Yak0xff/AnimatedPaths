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

class ViewController: UIViewController {
    
    var animationLayer: CALayer?
    var pathLayer: CAShapeLayer?
    var penLayer: CALayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        animationLayer = CALayer()
        animationLayer?.frame = CGRectMake(20.0, 40.0, CGRectGetWidth(self.view.layer.bounds) - 40.0, CGRectGetHeight(self.view.layer.bounds) - 84.0)
        self.view.layer.addSublayer(animationLayer!)
        
        setupDrawingLayer()
        startAnimation()
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
        pensLayer.contents = penImage.CGImage
        pensLayer.anchorPoint = CGPointZero
        pensLayer.frame = CGRectMake(0.0, 0.0, penImage.size.width, penImage.size.height)
        pathLayer?.addSublayer(pensLayer)
        
        penLayer = pensLayer

    }
    
    func setupDrawingLayer() {
    
        clearLayer()
        
        if let _ = animationLayer{
            let pathRect: CGRect = CGRectInset(animationLayer!.bounds, 100.0, 100.0)
            let bottomLeft = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMinY(pathRect))
            let topLeft = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMinY(pathRect) + CGRectGetHeight(pathRect) * 2.0 / 3.0)
            let bottomRight = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMinY(pathRect))
            let topRight = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMinY(pathRect) + CGRectGetHeight(pathRect) * 2.0 / 3.0)
            let roofTip = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect))
            
            let path = UIBezierPath()
            path.moveToPoint(bottomLeft)
            path.addLineToPoint(topLeft)
            path.addLineToPoint(roofTip)
            path.addLineToPoint(topRight)
            path.addLineToPoint(topLeft)
            path.addLineToPoint(bottomRight)
            path.addLineToPoint(topRight)
            path.addLineToPoint(bottomLeft)
            path.addLineToPoint(bottomRight)
            
            let pathShapeLayer = CAShapeLayer()
            pathShapeLayer.frame = animationLayer!.bounds
            pathShapeLayer.bounds = pathRect
            pathShapeLayer.geometryFlipped = true
            pathShapeLayer.path = path.CGPath
            pathShapeLayer.strokeColor = UIColor.blackColor().CGColor
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
        
        let font = CTFontCreateWithName("PingFangSC-Bold", 120, nil)
        let attrStr = NSAttributedString(string: "Hello Swift!", attributes: [kCTFontAttributeName as String: font])
        let line = CTLineCreateWithAttributedString(attrStr)
        let runArray = CTLineGetGlyphRuns(line)
        
        let letters = CGPathCreateMutable()
        
        for runIndex in 0..<CFArrayGetCount(runArray) {
            let runUnsafe: UnsafePointer<Void> = CFArrayGetValueAtIndex(runArray, runIndex) 
            let run = unsafeBitCast(runUnsafe, CTRunRef.self)
            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run) {
                let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                var glyph: CGGlyph = CGGlyph()
                var position: CGPoint = CGPoint()
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                let letter = CTFontCreatePathForGlyph(font, glyph, nil)
                var t = CGAffineTransformMakeTranslation(position.x, position.y);
                
                CGPathAddPath(letters, &t, letter)
            }
        }
                
        let path = UIBezierPath()
        path.moveToPoint(CGPointZero)
        path.appendPath(UIBezierPath(CGPath: letters))
        
        
        let layer = CAShapeLayer()
        layer.frame = CGRectMake(10, 120, CGRectGetWidth(self.view.layer.bounds) - 20, 100)
        layer.geometryFlipped = true
        layer.path = path.CGPath
        layer.strokeColor = UIColor.redColor().CGColor
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
        
        penLayer?.hidden = false
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 10.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        pathLayer?.addAnimation(pathAnimation, forKey: "strokeEnd")
        
        let penAnimation = CAKeyframeAnimation(keyPath: "position")
        penAnimation.duration = 10.0
        penAnimation.path = pathLayer?.path
        penAnimation.calculationMode = kCAAnimationPaced
        penAnimation.delegate = self
        penLayer?.addAnimation(penAnimation, forKey: "position")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        penLayer?.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    @IBAction func replayAction(sender: AnyObject) {
        startAnimation()
    }

    @IBAction func drawingTypeSelector(sender: AnyObject) {
        
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

