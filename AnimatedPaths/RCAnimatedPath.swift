//
//  RCAnimatedPath.swift
//  AnimatedPaths
//
//  Created by Robin on 17/11/23.
//  Copyright © 2017年 Robin. All rights reserved.
//

import UIKit
import QuartzCore
import CoreText
import CoreGraphics



class RCAnimatedPath{
    
    class var shared: RCAnimatedPath{
        struct Singleton{
            static let instance = RCAnimatedPath()
        }
        return Singleton.instance
    }
    
    var animationLayer: CALayer?
    var pathLayer: CAShapeLayer?
    
    private var inputPath: CGPath!
    private var inputDuration: CFTimeInterval = 10
    private var inputLineWidth: CGFloat = 10
    private var inputLineColor = UIColor.black
    
    private var inputRotationAngle: CGFloat = 0
    private var inputPolygonSidesNumber: Int = 6
    private var inputCornerRadius: Float = 8
    
    private var inputText = ""
    private var inputFontSize: CGFloat = 20
    private var inputFontName = "PingFangSC-Bold"
    

    
    func drawAnimatedCustomPath(in view: UIView,
                                path: CGPath,
                                duration: CFTimeInterval,
                                lineWidth: CGFloat,
                                lineColor: UIColor){
        self.inputDuration = duration
        self.inputLineWidth = lineWidth
        self.inputLineColor = lineColor
        self.inputPath = path
        
        animationLayer = CALayer()
        animationLayer?.frame = CGRect(x: 0, y: 0, width: view.layer.bounds.width, height: view.layer.bounds.height)
        view.layer.addSublayer(animationLayer!)
        view.clipsToBounds = true
        
        setupDrawingLayer()
        startAnimation()
    }
    
    func drawAnimatedRectanglePath(in view: UIView,
                                   duration: CFTimeInterval,
                                   lineWidth: CGFloat,
                                   lineColor: UIColor){
        self.inputDuration = duration
        self.inputLineWidth = lineWidth
        self.inputLineColor = lineColor
        
        self.inputPath = rectanglePath(view: view)
        
        animationLayer = CALayer()
        
        animationLayer?.frame = CGRect(x: 0, y: 0, width: view.layer.bounds.width, height: view.layer.bounds.height)
        view.layer.addSublayer(animationLayer!)
        view.clipsToBounds = true
        
        setupDrawingLayer()
        startAnimation()
    }
    
    func drawAnimatedPolygonPath(in view: UIView,
                                 numberOfSides polygonSidesNumber: Int?,
                                 rotationAngle: CGFloat?,
                                 polygonCornerRadius: Float?,
                                 duration: CFTimeInterval,
                                 lineWidth: CGFloat,
                                 lineColor: UIColor){
        self.inputDuration = duration
        self.inputLineWidth = lineWidth
        self.inputLineColor = lineColor
        if let _rotationAngle = rotationAngle
        {
            self.inputRotationAngle = _rotationAngle
        }
        if let _polygonSidesNumber = polygonSidesNumber
        {
            self.inputPolygonSidesNumber = _polygonSidesNumber
        }
        if let _polygonCornerRadius = polygonCornerRadius
        {
            self.inputCornerRadius = _polygonCornerRadius
        }
        
        self.inputPath = polygonPath(view: view)
        
        
        animationLayer = CALayer()
        animationLayer?.frame = CGRect(x: 0, y: 0, width: view.layer.bounds.width, height: view.layer.bounds.height)
        view.layer.addSublayer(animationLayer!)
        
        setupDrawingLayer()
        startAnimation()
    }
    
    func drawAnimatedText(in view: UIView,
                          with text: String,
                          duration: CFTimeInterval,
                          lineWidth: CGFloat,
                          textColor: UIColor,
                          fontName: String?,
                          fontSize: CGFloat?){
        self.inputText = text
        self.inputDuration = duration
        self.inputLineWidth = lineWidth
        self.inputLineColor = textColor
        if let _fontSize = fontSize
        {
            self.inputFontSize = _fontSize
        }
        if let _fontName = fontName
        {
            self.inputFontName = _fontName
        }
        
        animationLayer = CALayer()
        animationLayer?.frame = CGRect(x: 0, y: 0, width: view.layer.bounds.width, height: view.layer.bounds.height)
        view.layer.addSublayer(animationLayer!)
        
        setupTextLayer(in: view)
        startAnimation()
    }
    
    
    func setupDrawingLayer(){
        clearLayer()
        
        if let _ = animationLayer
        {
            let pathRect: CGRect = animationLayer!.bounds.insetBy(dx: 100.0, dy: 100.0)
            
            let pathShapeLayer = CAShapeLayer()
            pathShapeLayer.frame = animationLayer!.bounds
            pathShapeLayer.bounds = pathRect
            pathShapeLayer.isGeometryFlipped = true
            pathShapeLayer.path = inputPath
            pathShapeLayer.strokeColor = inputLineColor.cgColor
            pathShapeLayer.fillColor = nil
            pathShapeLayer.lineWidth = inputLineWidth
            pathShapeLayer.lineJoin = CAShapeLayerLineJoin.bevel
            
            animationLayer!.addSublayer(pathShapeLayer)
            
            pathLayer = pathShapeLayer
        }
    }
    
    func setupTextLayer(in view: UIView){
        clearLayer()
        
        if let _ = animationLayer
        {
            let font = CTFontCreateWithName((inputFontName as CFString?)!, inputFontSize, nil)
            let attrStr = NSAttributedString(string: inputText, attributes: [kCTFontAttributeName as NSAttributedString.Key: font])
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
                    
                    if letter == nil {
                        continue
                    }
                    
                    letters.addPath(letter!, transform:t)
                }
            }
            
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.append(UIBezierPath(cgPath: letters))
            
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: view.layer.bounds.width, height: view.layer.bounds.height)
            layer.isGeometryFlipped = true
            layer.path = path.cgPath
            layer.strokeColor = inputLineColor.cgColor
            layer.fillColor = nil
            layer.lineWidth = inputLineWidth
            layer.lineJoin = CAShapeLayerLineJoin.bevel
            
            animationLayer!.addSublayer(layer)
            
            pathLayer = layer
        }
        
    }
    
    private func startAnimation(){
        pathLayer?.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue = 0.0
        animation.byValue = 1.0
        animation.toValue = 1.0
        animation.duration = inputDuration
        
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        pathLayer?.add(animation, forKey: "drawLineAnimation")

        
    }
    
        //freezes the animation until clearLayer() is called
    func stopAnimatingWithPause(){
        if let pausedTime = pathLayer?.convertTime(CACurrentMediaTime(), from: nil)
        {
            pathLayer?.speed = 0.0
            pathLayer?.timeOffset = pausedTime
        }
    }
    
        //clears the animation layers
    func stopAnimatingWithClear(){
        clearLayer()
    }
    
    func clearLayer(){
        if let _ = pathLayer
        {
            pathLayer?.removeFromSuperlayer()
            pathLayer = nil
        }
    }
    
    private func rectanglePath(view: UIView) -> CGPath{
            //start point - left-down corner
        var point = CGPoint(x: inputLineWidth/2, y: 0)
        let path = UIBezierPath()
        path.move(to: point)
            //left-up corner
        point = CGPoint(x: inputLineWidth/2, y: view.frame.height)
        path.addLine(to: point)
        path.move(to: CGPoint(x: inputLineWidth/2, y: view.frame.height - inputLineWidth/2))
            //right-up corner
        point = CGPoint(x: view.frame.width, y: view.frame.height - inputLineWidth/2)
        path.addLine(to: point)
        path.move(to: CGPoint(x: view.frame.width - inputLineWidth/2, y: view.frame.height - inputLineWidth/2))
            //right-down corner
        point = CGPoint(x: view.frame.width - inputLineWidth/2, y: 0)
        path.addLine(to: point)
        path.move(to: CGPoint(x: view.frame.width - inputLineWidth/2, y: inputLineWidth/2))
            //start point - left-down corner
        point = CGPoint(x: 0, y: inputLineWidth/2)
        path.addLine(to: point)
        
        path.close()
        
        return path.cgPath
    }
    
    private func polygonPath(view: UIView) -> CGPath{
        let path = UIBezierPath()
        
        let theta = Float(2.0 * .pi) / Float(inputPolygonSidesNumber)
        let offset = inputCornerRadius * tanf(theta / 2.0)
        let squareWidth = Float(min(view.frame.size.width, view.frame.size.height))
        
        var length = squareWidth - Float(inputLineWidth)
        
        if inputPolygonSidesNumber % 4 != 0{
            length = length * cosf(theta / 2.0) + offset / 2.0
        }
        
        let sideLength = length * tanf(theta / 2.0)
        
        var point = CGPoint(x: CGFloat((squareWidth / 2.0) + (sideLength / 2.0) - offset), y: CGFloat(squareWidth - (squareWidth - length) / 2.0))
        var angle = Float(Double.pi)
        path.move(to: point)
        
        for _ in 0 ..< inputPolygonSidesNumber{
            
            let x = Float(point.x) + (sideLength - offset * 2.0) * cosf(angle)
            let y = Float(point.y) + (sideLength - offset * 2.0) * sinf(angle)
            
            point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            path.addLine(to: point)
            
            let centerX = Float(point.x) + inputCornerRadius * cosf(angle + Float(Double.pi/2))
            let centerY = Float(point.y) + inputCornerRadius * sinf(angle + Float(Double.pi/2))
            
            let center = CGPoint(x: CGFloat(centerX), y: CGFloat(centerY))
            
            let startAngle = CGFloat(angle) - CGFloat(Double.pi/2)
            let endAngle = CGFloat(angle) + CGFloat(theta) - CGFloat(Double.pi/2)
            
            path.addArc(withCenter: center, radius: CGFloat(inputCornerRadius), startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            point = path.currentPoint
            angle += theta
        }
        
        path.close()
        
        
        // ROTATE
        //get the center and transform the path so it's centered at the origin
        let bounds = path.cgPath.boundingBox
        let center = CGPoint(x:bounds.midX, y:bounds.midY)
        
        let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
        path.apply(toOrigin)
        
        //rotate around the origin
        let rotAngle = inputRotationAngle * CGFloat(Double.pi) / 180
        let rotation = CGAffineTransform(rotationAngle: CGFloat(rotAngle))
        path.apply(rotation)
        
        //translate back to the origin
        let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)
        path.apply(fromOrigin)
        
        return path.cgPath
    }
    
}//end of class
