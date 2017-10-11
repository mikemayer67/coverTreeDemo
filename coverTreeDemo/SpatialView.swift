//
//  SpatialView.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/14/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class SpatialView: CoverTreeView
{
  
  override func draw(_ dirtyRect: NSRect)
  {
    super.draw(dirtyRect)
    
    NSColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0).setFill()
    bounds.fill()
    
    let path = CGMutablePath()
    path.move   (to: CGPoint(x: bounds.maxX, y: bounds.maxY))
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
    path.move   (to: CGPoint(x: bounds.maxX, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
    
    let context = NSGraphicsContext.current?.cgContext;
    
    context?.setLineWidth(2.0)
    context?.setStrokeColor(NSColor.purple.cgColor)
    context?.addPath(path)
    context?.drawPath(using: .stroke)
  }
  
  override func focus(on node: Int)
  {
    Swift.print("Focus SpatialView on node \(node)")
  }

  
}
