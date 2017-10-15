//
//  TreeViewRenderer.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 10/15/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class TreeViewRenderer : CoverTreeRenderer
{
  override init(_ view:CoverTreeView)
  {
    super.init(view)
  }
  
  override func draw(_ dirtyRect: NSRect)
  {
    Swift.print("Draw \(dirtyRect) using \(self)")
    let bounds = view.bounds
    
    NSColor.white.setFill()
    NSRectFill(bounds)
    
    let path = CGMutablePath()
    path.move   (to: CGPoint(x: bounds.maxX, y: bounds.maxY))
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
    path.move   (to: CGPoint(x: bounds.maxX, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
    
    let context = NSGraphicsContext.current()?.cgContext;
    
    context?.setLineWidth(3.0)
    context?.addPath(path)
    context?.drawPath(using: .stroke)
  }
}
