//
//  CoverTreeNode.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/25/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

typealias NodeAndDist      = (node:CoverTreeNode, dist:Double)
typealias NodesAndDists    = [NodeAndDist]
typealias CoverTreeNodes   = [CoverTreeNode]
typealias CoverTreeNodeMap = [Int:CoverTreeNode]
typealias CoverageMap      = [Int:CoverTreeNodes]

class CoverTreeNode : NSObject, NSCoding
{
  private(set) var ID       : Int
  private(set) var level    : Int
  private(set) var point    : DataPoint
  private(set) var parent   : NodeAndDist?
  private(set) var children = CoverageMap()
  
  var isRoot : Bool { return parent == nil }
  
  init(_ data:DataPoint, id:Int)
  {
    self.ID    = id
    self.point = data
    self.level = Int.min
  }
  
  convenience init(_ point:DataPoint, id:Int, asChildOf parent:CoverTreeNode, atDistance distance:Double)
  {
    self.init(point, id:id)
    
    let level = Int( ceil(log(distance)/CoverTree.logBase) ) // parent level
    
    self.parent = (parent,distance)
    self.level  = level - 1
  }
  
  convenience init(_ point:DataPoint, id:Int, parent:CoverTreeNode)
  {
    let dist = point.distance(from: parent.point)
    
    self.init(point, id:id, asChildOf: parent, atDistance: dist )
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    guard let point = aDecoder.decodeObject(forKey:"point")     as? DataPoint,
      let  children = aDecoder.decodeObject(forKey:"childrent") as? CoverageMap
      else { return nil }
    
    self.ID       = aDecoder.decodeInteger(forKey: "id")
    self.level    = aDecoder.decodeInteger(forKey: "level")
    self.point    = point
    self.children = children
    
    super.init()
    
    for (_,nodes) in children
    {
      for q in nodes
      {
        let dist = point.distance(from: q.point)
        q.parent = (self,dist)
      }
    }
  }
  
  func encode(with aCoder: NSCoder)
  {
    
    aCoder.encode(ID,       forKey:"id")
    aCoder.encode(level,    forKey:"level")
    aCoder.encode(point,    forKey:"point")
    aCoder.encode(children, forKey:"children")
  }
  
  func incrementCount()
  {
    point.incrementCount()
  }
  
  func addChild(_ p:DataPoint, id:Int, atDistance dist:Double) -> CoverTreeNode
  {
    let newNode = CoverTreeNode(p, id:id, asChildOf:self, atDistance:dist)
    
    guard ( (newNode.level < self.level) || self.isRoot ) else {
      NSLog("Attemped to add child node on level \(newNode.level) at a distance of \(dist) from the parent node")
      exit(1)
    }
    
    if self.level <= newNode.level  // must be root node based on guard test above
    {
      self.level = newNode.level + 1
    }
    
    if self.children[newNode.level] == nil
    {
      self.children[newNode.level] = [ newNode ]
    }
    else
    {
      self.children[newNode.level]!.append(newNode)
    }
    
    return newNode
  }
  
  func insert(into map:inout CoverTreeNodeMap) throws -> Void
  {
    guard map[self.ID] == nil else { throw CoverTreeError.fileContentError("Node <<\(self.ID)>> multiply defined") }
    
    map[self.ID] = self
    
    for (_,level_children) in self.children
    {
      for node in level_children
      {
        try node.insert(into:&map)
      }
    }
  }
}
