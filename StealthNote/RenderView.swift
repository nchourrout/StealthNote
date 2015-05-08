//
//  RenderView.swift
//  StealthNote
//
//  Created by Nicolas on 07/05/2015.
//  Copyright (c) 2015 Nicolas Chourrout. All rights reserved.
//

import Foundation
import UIKit

protocol RenderViewDelegate {
    func analyzePath(path:Path)
}

class RenderView:UIView {
    
    var rawPoints:[Int] = []
    var path:UIBezierPath = UIBezierPath()
    var pts = [CGPoint](count:5, repeatedValue:CGPointMake(0,0))
    var ctr = 0
    var delegate: RenderViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.multipleTouchEnabled = false
        self.backgroundColor = UIColor.whiteColor()
        path.lineWidth = 10.0
    }
    
    override func drawRect(rect:CGRect) {
        path.stroke()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        ctr = 0
        rawPoints = []
        let touch = touches.first as? UITouch
        let location = touch!.locationInView(self)
        pts[0] = location
        rawPoints.append(Int(location.x))
        rawPoints.append(Int(location.y))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as? UITouch
        let location = touch!.locationInView(self)
        rawPoints.append(Int(location.x))
        rawPoints.append(Int(location.y))
        
        ctr++;
        pts[ctr] = location
        if (ctr == 4) {
            // Move endpoint to middle of line joining 2nd control point
            // of 1st Bezier segment and 1st control point of 2nd Bezier segment
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0)
            path.moveToPoint(pts[0])
            path.addCurveToPoint(pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
            setNeedsDisplay()
            pts[0] = pts[3]
            pts[1] = pts[4]
            ctr = 1
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var rawPath:Path = Path()
        rawPath.addPointFromRaw(rawPoints)
        path.removeAllPoints()

//        if let myDelegate = delegate {
            delegate!.analyzePath(rawPath)
//        }
        
        setNeedsDisplay()
        ctr = 0
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
}
