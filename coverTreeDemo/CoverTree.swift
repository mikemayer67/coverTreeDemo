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
  private(set) var dataSet    : DataSet?
  private(set) var dataSource : String?
  
  var dim   : Int  { return dataSet?.dim   ?? 0 }
  var count : Int  { return dataSet?.count ?? 0 }
  
  var generated   : Bool { return dataSet != nil }
  
  override init()
  {
    super.init()
    print("CoverTree::init")
  }
  
  required init?(coder decoder:NSCoder)
  {
    if let data = decoder.decodeObject(forKey: "data"  ) as? DataSet,
      let  src  = decoder.decodeObject(forKey: "source") as? String
    {
      self.dataSet    = data
      self.dataSource = src
    }
    else
    {
      NSLog("Failed to decode CoverTree:: invalid format")
      return nil
    }
    
    print("CoverTree::init(coder)")
  }
  
  func encode(with coder: NSCoder)
  {
    coder.encode(self.dataSet,    forKey:"data"  )
    coder.encode(self.dataSource, forKey:"source")
    
    print("CoverTree::encode")
  }
  
  func generate( dataSet : DataSet, source : String? = nil) -> Void
  {
    self.dataSet    = dataSet
    self.dataSource = source ?? "unknown"
  }
}
