//
//  CoverTreeView.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 10/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class CoverTreeView : NSView
{
  private var redrawTimer : Timer?
  
  var active = false
  {
    didSet
    {
      if active
      {
        if needsRedraw, oldValue == false { redraw() }
      }
      else
      {
        redrawTimer?.invalidate()
        redrawTimer = nil
      }
    }
  }
  
  private var needsRedraw = true
  
  var zoom : CGFloat = 0.0
  {
    didSet {
      if zoom != oldValue
      {
        needsRedraw = true
        if active { zoom(from:oldValue, to:zoom) }
      }
    }
  }
  
  func focus(on node:Int)
  {
    print("Need to implement focus() for \(String(describing: type(of: self)))")
  }
  
  func redraw()
  {
    print("Need to implement redraw() for \(String(describing: type(of: self)))")
    needsRedraw = false
    
  }
  
  func zoom(from:CGFloat, to:CGFloat)
  {
    print("Zoom(from:\(from), to:\(to))")
    redrawTimer?.invalidate()
    redrawTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false)
    {
      (Timer)->Void in
      self.redrawTimer = nil
      print("Redraw callback... New scale:\(self.zoom)")
      self.redraw();
    }
  }
}
