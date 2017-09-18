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
  
  override class func autosavesInPlace() -> Bool {
    return true
  }
  
  override func makeWindowControllers()
  {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
    self.addWindowController(windowController)
  }
  
  override func data(ofType typeName: String) throws -> Data
  {
    Swift.print("\(self)::data(ofType:\(typeName)")
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
  
//  override func encodeRestorableState(with coder: NSCoder)
//  {
//    if self.coverTree.generated
//    {
//      coder.encode(self.coverTree, forKey:"coverTree")
//    }
//    super.encodeRestorableState(with: coder)
//  }
  
  override func restoreWindow(withIdentifier identifier: String, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void)
  {
    if coverTree.generated
    {
      super.restoreWindow(withIdentifier: identifier, state: state, completionHandler: completionHandler)
    }
    else
    {
      completionHandler(nil, NSError(domain: "Ungenerated Tree", code: 1, userInfo: nil))
    }
  }
  
}

