//
//  CoverTree.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class CoverTree: NSObject, NSCoding
{
  private(set) var creationStamp = ""
  
  var generated : Bool
  {
    return creationStamp.isEmpty == false
  }
  
  override init()
  {
    super.init()
  }
  
  required init?(coder decoder:NSCoder)
  {
    if let cs = decoder.decodeObject(forKey: "creation") as? String
    {
      self.creationStamp = cs
    }
    else
    {
      NSLog("Failed to decode CoverTree:: invalid format")
      return nil
    }
  }
  
  func encode(with coder: NSCoder)
  {
    coder.encode(self.creationStamp, forKey:"creation")
  }
  
  func generate( dataSet : DataSet) -> Void
  {
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .full
    
    creationStamp = df.string(from: Date())
  }
}
