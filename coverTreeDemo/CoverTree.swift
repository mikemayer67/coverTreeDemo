//
//  CoverTree.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

typealias PointHistory = [String]
typealias TreeHistory  = [PointHistory]

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
  private(set) var nodes = CoverTreeNodes()
  
  var count : Int { return nodes.count }
  
  var generated  : Bool { return root != nil }
  
  private var treeHistory  = TreeHistory()
  private var pointHistory = PointHistory()
  
  private var _nextID = 1
  private var nextID : Int { let rval = _nextID; _nextID += 1; return rval }
  
  var logger : CoverTreeGenerationLogger?
  {
    didSet { logger?.set(self.treeHistory) }
  }
  
  override init()
  {
    super.init()
  }
  
  required init?(coder decoder:NSCoder)
  {
    super.init()
    
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
    
    if let hist = decoder.decodeObject(forKey:"history") as? [[String]]
    {
      treeHistory = hist
    }
    else
    {
      for i in 1...count
      {
        treeHistory.append(["No history info for <<\(i)>>"])
      }
    }
    
    if indexNodes() == false
    {
      self.root = nil
      return nil
    }
  }
  
  func encode(with coder: NSCoder)
  {
    if root != nil
    {
      coder.encode(self.root,        forKey:"root"  )
      coder.encode(self.dataSource,  forKey:"source")
      coder.encode(self.dim,         forKey:"dim")
      coder.encode(self.treeHistory, forKey:"history")
    }
  }
  
  func indexNodes() -> Bool
  {
    do
    {
      var nodeMap = CoverTreeNodeMap()
      try root.insert(into: &nodeMap)
      
      let n = nodeMap.count
      for i in 1...n
      {
        if let node = nodeMap[i]
        {
          nodes.append(node)
        }
        else
        {
          throw CoverTreeError.fileContentError("Missing node <<\(i)>>")
        }
      }
    }
    catch CoverTreeError.fileContentError(let reason)
    {
      NSLog("Invalid file content encountered: \(reason)")
      return false
    }
    catch CoverTreeError.codingError(let reason)
    {
      NSLog("Coding error: \(reason)")
      return false
    }
    catch
    {
      NSLog("Unknown error while attempting to decode file content")
      return false
    }
    return true
  }
  
  func generate( dataSet : DataSet, source : String) -> Bool
  {
    guard dataSet.count>1 else { return false }
    
    self.dataSource = source
    self.dim = dataSet.dim
    
    for p in dataSet.points
    {
      let pointInfo = "\(p.coord)"
      // Case 1: Empty Tree
      if root == nil
      {
        root = CoverTreeNode(p, id:self.nextID)
        treeHistory.append([pointInfo,"Adding <<\(root.ID)>> as root node"])
        
        continue // to next p
      }
      
      let rootDist = p.distance(from:root.point)
      
      // Case 2: p is redundant with root node
      if rootDist == 0.0
      {
        treeHistory.append([pointInfo,"Point is redundant with root node \(root.ID)"])
        root.incrementCount()
      }
        
        // Case 3: Tree only contains the root node
      else if root.children.isEmpty
      {
        let q = root.addChild(p, id:self.nextID, atDistance:rootDist)
        treeHistory.append([pointInfo,
          "Adding <<\(q.ID)>> as second node in tree  (root level = \(root.level),   node level = \(q.level),   distance = \(rootDist))" ] )
      }
        
        // Case 4: Tree contains at least two nodes
      else
      {
        pointHistory = [pointInfo,"Looking at root node (level \(root.level)) as parent node"]
        let Q = [(node:root!,dist:rootDist)]
        if insert(point:p, into:Q, at:root.level) == false
        {
          // Case 4b: root nodes must be raised to a higher level
          let q = root.addChild(p, id:self.nextID, atDistance:rootDist)
          pointHistory.append("Root level must be increased to \(root.level)")
          pointHistory.append("Adding <<\(q.ID)>> to root node at level \(q.level) based on distance of \(rootDist)")
        }
        treeHistory.append(pointHistory)
      }
    }
    
    if indexNodes() == false
    {
      root = nil
      return false
    }
    
    logger?.set(self.treeHistory)
    
    return true
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
          
          if d == 0.0
          {
            q.incrementCount()
          }
          
          if d <= sep { Qj.append( (node:q, dist:d) ) }
        }
      }
    }
    pointHistory.append("Looking for parent node at level \(level-1)  (\(Qj.count) candidates found)")
    
    if Qj.isEmpty { return false }
    
    for qj in Qj
    {
      pointHistory.append("    <<\(qj.node.ID)>> at distance \(qj.dist)")
    }
    
    if insert(point: p, into: Qj, at: level - 1) == true { return true }
    if candQi == nil { return false }
    
    let q = candQi!.node.addChild(p, id:self.nextID, atDistance: candQi!.dist)
    pointHistory.append("Adding <\(q.ID)> as level \(q.level) child of <\(candQi!.node.ID)> based on distance of \(candQi!.dist)")
    
    return true
  }
}

