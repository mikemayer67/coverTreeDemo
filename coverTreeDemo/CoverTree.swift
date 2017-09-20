//
//  CoverTree.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

protocol CoverTreeGenerationLogger
{
  func add(_ string:String, to level:Int) -> Void
  func set(_ history:[[String]]) -> Void
}

class CoverTree: NSObject, NSCoding
{
  
  private(set) var dataSet    : DataSet!
  private(set) var dataSource : String!
  
  var dim   : Int  { return dataSet?.dim   ?? 0 }
  var count : Int  { return dataSet?.count ?? 0 }
  
  var generated   : Bool { return dataSet != nil }
  
  private var history = [[String]]()
  var logger : CoverTreeGenerationLogger?
  {
    didSet { logger?.set(self.history) }
  }
  
  override init()
  {
    super.init()
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
    
    if let hist = decoder.decodeObject(forKey:"history") as? [[String]]
    {
      history = hist
    }
    else
    {
      for i in 1...dataSet.count
      {
        history.append(["Missing info for <<\(i)>>"])
      }
    }
  }
  
  func encode(with coder: NSCoder)
  {
    coder.encode(self.dataSet,    forKey:"data"  )
    coder.encode(self.dataSource, forKey:"source")
    coder.encode(self.history,    forKey:"history")
  }
  
  func generate( dataSet : DataSet, source : String? = nil) -> Void
  {
    self.dataSet    = dataSet
    self.dataSource = source ?? "unknown"
    
    for i in 1...count
    {
      let steps = [ "Construction of <<\(i)>>", "Parent is <<\(i-1)>>", "Children are <<\(i+1)>>, <<\(i+3)>>, and <<\(2*i+5)>>" ]
      for step in steps
      {
        logger?.add(step, to: i)
      }
      history.append(steps)
    }
  }
}
