//
//  Document.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/6/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class Document: NSDocument
{
  private(set) var coverTree = CoverTree()
  
  override init() {
    super.init()
  }
  
  override class func autosavesInPlace() -> Bool {
    return false
  }
  
  override func makeWindowControllers() {
    // Returns the Storyboard that contains your Document window.
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
    self.addWindowController(windowController)
  }
  
  override func data(ofType typeName: String) throws -> Data
  {
    return NSKeyedArchiver.archivedData(withRootObject: coverTree)
  }
  
  override func read(from data: Data, ofType typeName: String) throws
  {
    guard let ct = (NSKeyedUnarchiver.unarchiveObject(with: data) as? CoverTree) else
    {
      throw NSError(domain: "FileContent", code: 0, userInfo: nil)
    }
    self.coverTree = ct
  }
}

