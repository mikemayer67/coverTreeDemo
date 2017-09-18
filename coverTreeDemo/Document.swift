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
    Swift.print("\(self)::init")
  }
  
  override class func autosavesInPlace() -> Bool {
    return true
  }
  
  override func makeWindowControllers() {
    Swift.print("\(self)::makeWindowControllers (enter)")
    // Returns the Storyboard that contains your Document window.
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
    self.addWindowController(windowController)
    Swift.print("\(self)::makeWindowControllers (exit)")

  }
  
  override func data(ofType typeName: String) throws -> Data
  {
    Swift.print("\(self)::data(ofType:\(typeName)")
    return NSKeyedArchiver.archivedData(withRootObject: coverTree)
  }
  
  override func read(from data: Data, ofType typeName: String) throws
  {
    Swift.print("\(self)::read(from:data, ofType:\(typeName))")
    guard let ct = (NSKeyedUnarchiver.unarchiveObject(with: data) as? CoverTree) else
    {
      throw NSError(domain: "FileContent", code: 0, userInfo: nil)
    }
    self.coverTree = ct
    Swift.print("\(self)::read(from:data) (end)")
  }
  
  override func restoreState(with coder: NSCoder)
  {
    let url = coder.decodeObject(forKey: "file") as? String
    
    Swift.print("Document::restoreState from: \(url)")
    super.restoreState(with: coder)
  }
  
  override func encodeRestorableState(with coder: NSCoder)
  {
    if self.hasUnautosavedChanges
    {
      Swift.print("encodeRestorableState: \(self.fileURL?.absoluteString ?? "nil")")
    
      if self.fileURL != nil
      {
        coder.encode(self.fileURL!, forKey:"file")
      }
    }
    
    if self.coverTree.dataSource != nil
    {
      Swift.print("encodeRestorableState: \(self.coverTree.dataSource!)")
      coder.encode(self.coverTree.dataSource!, forKey:"dataSource")
    }
    super.encodeRestorableState(with: coder)
  }
  
  override func restoreWindow(withIdentifier identifier: String, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void)
  {
    Swift.print("\(self)::resstoreWindow(withIdentifier:\(identifier), state:\(state)")
    let data = state.decodeObject(forKey: "dataSource")
    Swift.print("   data = \(data)")
    if data == nil
    {
      let err = NSError(domain: "Autosave duplicte", code: 0, userInfo: nil)
      completionHandler(nil,err)
    }
    else
    {
      super.restoreWindow(withIdentifier: identifier, state: state, completionHandler: completionHandler)
    }
  }
  
  override func read(from url: URL, ofType typeName: String) throws
  {
    Swift.print("\(self)::read(from:\(url), ofType:\(typeName))")
    try super.read(from:url, ofType: typeName)
    Swift.print("\(self)::read(from:url) (end)")
  }
  
  override func write(to url: URL, ofType typeName: String) throws {
    Swift.print("\(self)::write(to:\(url), ofType:\(typeName))")
    try super.write(to:url, ofType:typeName)
    Swift.print("\(self)::write(to:url) (end)  [\(self.fileURL)]")
  }
  
}

