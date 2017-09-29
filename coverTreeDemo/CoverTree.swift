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
  static let BASE = 2.0
  static let logBase = log(BASE)

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
    if root != nil
    {
      coder.encode(self.root,       forKey:"root"  )
      coder.encode(self.dataSource, forKey:"source")
      coder.encode(self.dim,        forKey:"dim")
      coder.encode(self.count,      forKey:"count")
      coder.encode(self.history,    forKey:"history")
    }
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
      }
        
        // Case 3: Tree only contains the root node
      else if root.children.isEmpty
      {
        root.addChild(p, atDistance:rootDist)
      }
        
        // Case 4: Tree contains at least two nodes
      else
      {
        let Q = [(node:root!,dist:rootDist)]
        if insert(point:p, into:Q, at:root.level) == false
        {
          // Case 4b: root nodes must be raised to a higher level
          root.addChild(p,atDistance: rootDist)
        }
      }
    }
  }

  @discardableResult func insert(point p:DataPoint, into Qi:NodesAndDists, at level:Int) -> Bool
  {
    let sep = exp( Double(level) * CoverTree.logBase )
    
    var candQi : NodeAndDist?
    
    var Qj = NodesAndDists()
    for qi in Qi
    {
      if qi.dist <= sep
      {
        if ( candQi == nil ) || (qi.dist < candQi!.dist) { candQi = qi }
        Qj.append(qi)
      }
      
      if let children = qi.node.children[level - 1]
      {
        for q in children
        {
          let d = q.point.distance(from: p)
          if d <= sep { Qj.append( (node:q, dist:d) ) }
        }
      }
    }
    
    if Qj.isEmpty { return false }
    
    if insert(point: p, into: Qj, at: level - 1) == true { return true }
    if candQi == nil { return false }
    
    candQi!.node.addChild(p, atDistance: candQi!.dist)
    
    return true
  }
}

