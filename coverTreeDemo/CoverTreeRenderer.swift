//
//  CoverTreeRenderer.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 10/15/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class CoverTreeRenderer
{
  let view : CoverTreeView
  
  init(_ view : CoverTreeView)
  {
    self.view = view
  }
  
  func draw(_ dirtyRect:NSRect)
  {
    print("Must override draw(:) for \(String(describing: type(of: self)))")
  }
}
