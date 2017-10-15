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
  enum ViewType : Int {
    case treeView    = 0
    case polarView   = 1
    case spatialView = 2
  }
  
  @IBOutlet var zoomSlider       : NSSlider!
  @IBOutlet var viewTypeSelector : NSSegmentedControl!
  
  // MARK: - Initialization
  
  var renderers = [ViewType:CoverTreeRenderer]()
  
  override func awakeFromNib()
  {
    renderers[.treeView]    = TreeViewRenderer(self)
    renderers[.polarView]   = PolarViewRenderer(self)
    renderers[.spatialView] = SpatialViewRenderer(self)
  }

  var coverTree : CoverTree!
  {
    didSet {
      if coverTree.dim > 3
      {
        viewTypeSelector.segmentCount = 2
        if viewType == .spatialView
        {
          viewType = .treeView
          viewTypeIndex = viewType.rawValue
        }
      }
      else
      {
        viewTypeSelector.segmentCount = 3
      }
    }
  }
  
  // MARK: - Zoom/Redraw methods
  
  private var redrawTimer : Timer?
  private var needsRedraw = true
  
  override var isOpaque : Bool { return true }
  
  private(set) var viewType = ViewType.treeView
  
  @objc dynamic var viewTypeIndex : Int = 0
  {
    didSet {
      if viewTypeIndex != oldValue
      {
        viewType = ViewType(rawValue: viewTypeIndex)!
        redraw()
      }
    }
  }
  
  @objc dynamic var zoom : Double = 0.0
  {
    didSet {
      if zoom != oldValue
      {
        Swift.print("Change zoom from \(oldValue) to \(zoom) for \(self.className)")
        needsRedraw = true
        if self.isHidden == false
        {

          redrawTimer?.invalidate()
          redrawTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false)
          {
            (Timer)->Void in
            self.redrawTimer = nil
            Swift.print("Redraw callback... New scale:\(self.zoom)")
            self.redraw();
            
            self.needsRedraw = false
          }
        }
      }
    }
  }
  
  func focus(on node:Int)
  {
    Swift.print("Need to implement focus() for \(viewType)")
  }
  
  func redraw()
  {
    Swift.print("Redraw \(viewType)")

    self.setNeedsDisplay(bounds)
  }
  
  override func draw(_ dirtyRect: NSRect)
  {
    super.draw(dirtyRect)
    Swift.print("Render \(viewType)")
    renderers[viewType]?.draw(dirtyRect)
  }
}
