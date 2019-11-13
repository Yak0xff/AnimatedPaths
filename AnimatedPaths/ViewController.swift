//
//  ViewController.swift
//  AnimatedPaths
//
//  Created by Robin on 16/2/23.
//  Copyright © 2016年 Robin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Segment: UISegmentedControl!
    
    lazy var targetView: UIView = {
        let sTargetView =  UIView(frame: CGRect(x: 0,
                                                y: 0,
                                                width: 360,
                                                height: 360))
        sTargetView.center = CGPoint(x: UIScreen.main.bounds.size.width/2,
                                     y: UIScreen.main.bounds.size.height/2)
//        sTargetView.backgroundColor = UIColor.red
        return sTargetView
    }()
    
    let animatedPath = RCAnimatedPath.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.addSubview(targetView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    @IBAction func drawingTypeSelector(_ sender: AnyObject) {

        animatedPath.stopAnimatingWithClear()
        
        switch sender.selectedSegmentIndex {
        case 0:
            animatedPath.drawAnimatedRectanglePath(in: targetView,
                                                            duration: 3,
                                                            lineWidth: 5,
                                                            lineColor: UIColor.red)
        case 1:
            animatedPath.drawAnimatedPolygonPath(in: targetView,
                                                          numberOfSides: 8,
                                                          rotationAngle: 10,
                                                          polygonCornerRadius: 4,
                                                          duration: 3,
                                                          lineWidth: 5,
                                                          lineColor: UIColor.gray)
        case 2:
            animatedPath.drawAnimatedText(in: targetView,
                                                   with: "Hello Swift!",
                                                   duration: 3,
                                                   lineWidth: 2,
                                                   textColor: UIColor.purple,
                                                   fontName: "PingFangSC-Bold",
                                                   fontSize: 50)
        case 3:
            animatedPath.drawAnimatedCustomPath(in: targetView,
                                                path: ringPath.cgPath,
                                                         duration: 3,
                                                         lineWidth: 2,
                                                         lineColor: UIColor.black)
        default:
            break
        }
    }
    
    var ringPath: UIBezierPath{
        let bezierPath = UIBezierPath()
        let arcCenter = CGPoint(x: 185, y: 110)
        bezierPath.addArc(withCenter: arcCenter, radius: 66.0, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        return bezierPath
    }
    
}


