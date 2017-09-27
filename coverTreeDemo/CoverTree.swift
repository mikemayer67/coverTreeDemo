//
//  CoverTree.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

typealias History = [[String]]

protocol CoverTreeGenerationLogger
{
  func add(_ string:String, to level:Int) -> Void
  func set(_ history:[[String]]) -> Void
}

class CoverTree: NSObject, NSCoding
{
  private(set) var dataSource : String!
  
  private(set) var root  : CoverTreeNode!
  private(set) var dim   = 0
  private(set) var count = 0
  
  var generated   : Bool { return root != nil }
  
  private var history = History()
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
    guard let root    = decoder.decodeObject( forKey: "tree"  ) as? CoverTreeNode,
      let  dataSource = decoder.decodeObject( forKey: "source") as? String
      else
    {
      NSLog("Failed to decode CoverTree:: invalid format")
      return nil
    }
    
    self.dataSource = dataSource
    self.root       = root
    self.dim        = decoder.decodeInteger(forKey: "dim")
    self.count      = decoder.decodeInteger(forKey: "count")
    
    if let hist = decoder.decodeObject(forKey:"history") as? [[String]]
    {
      history = hist
    }
    else
    {
      for i in 1...count
      {
        history.append(["Missing info for <<\(i)>>"])
      }
    }
  }
  
  func encode(with coder: NSCoder)
  {
    coder.encode(self.root,       forKey:"root"  )
    coder.encode(self.dataSource, forKey:"source")
    coder.encode(self.dim,        forKey:"dim")
    coder.encode(self.count,      forKey:"count")
    coder.encode(self.history,    forKey:"history")
  }
  
  func generate( dataSet : DataSet, source : String) -> Void
  {
    guard dataSet.count>1 else { return }
    
    self.dataSource = source
    
    for p in dataSet.points
    {
      // Case 1: Empty Tree
      if root == nil
      {
        history.append(["Constructing root node"])
        root = CoverTreeNode(p)
        
        continue // to next p
      }
      
      let rootDist = p.distance(from:root.point)
      
      // Case 2: p is redundant with root node
      if rootDist == 0.0
      {
        history.append(["Point is redundant with root node"])
        root.incrementCount()
        continue // to next p
      }
        
      // Case 3: Tree only contains the root node
      if root.children.isEmpty
      {
        root.addChild(p, atDistance:rootDist)
        continue // to next p
      }
        
      // Case 4: Root node is not at high enough level to cover new point
      if try! root.increaseLevel(toCover: rootDist)
      {
        root.addChild(p, atDistance:rootDist)
        continue // to next p
      }

      
       // tree contains at least two nodes
      {
        root!.insert(p,history:history)
      }
    }
  }
}
