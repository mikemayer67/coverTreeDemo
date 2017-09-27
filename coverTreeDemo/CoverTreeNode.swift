//
//  CoverTreeNode.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/25/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa


class CoverTreeNode : NSObject, NSCoding
{
  typealias NodeAndDist = (node:CoverTreeNode, dist:Double)

  static let BASE = 2.0
  static let logBase = log(BASE)
  
  private(set) var point : DataPoint
  private(set) var level : Int?
  private(set) var parent : NodeAndDist?
  private(set) var children = [CoverTreeNode]()
    
  var isRoot : Bool { return parent == nil }
  
  init(_ data:DataPoint)
  {
    self.point = data
  }
  
  convenience init(_ point:DataPoint, asChildOf parent:CoverTreeNode, atDistance distance:Double)
  {
    self.init(point)
    
    self.parent = (parent,distance)
    self.level  = parent.level! - 1
  }
  
  convenience init(_ point:DataPoint, parent:CoverTreeNode)
  {
    let dist = point.distance(from: parent.point)
    
    self.init(point, asChildOf: parent, atDistance: dist )
  }
  
  required init?(coder aDecoder: NSCoder)
  {    
    guard let point = aDecoder.decodeObject(forKey:"point")     as? DataPoint,
      let  children = aDecoder.decodeObject(forKey:"childrent") as? [CoverTreeNode]
    else { return nil }
    
    self.point    = point
    self.children = children
    
    if aDecoder.containsValue(forKey: "level")
    {
      self.level = aDecoder.decodeInteger(forKey: "level")
    }
    
    super.init()
    
    for q in children
    {
      let dist = point.distance(from: q.point)
      q.parent = (self,dist)
    }
  }
  
  func encode(with aCoder: NSCoder)
  {
    aCoder.encode(point,    forKey:"point")
    aCoder.encode(children, forKey:"children")
    
    if level != nil { aCoder.encode(level!, forKey:"level") }
  }
  
  func incrementCount()
  {
    point.incrementCount()
  }
  
  func addChild(_ p:DataPoint, atDistance dist:Double)
  {
    if level == nil
    {
      level = Int( ceil(log(dist)/CoverTreeNode.logBase) )
    }
    
    if children.isEmpty
    {
      children.append( CoverTreeNode(point, asChildOf:self, atDistance:0.0) )
    }
    else
    {
      children.append( CoverTreeNode(p, asChildOf:self, atDistance:dist) )
    }
  }
  
  func increaseLevel(toCover dist:Double) throws -> Bool
  {
    guard parent == nil, level != nil, dist != 0.0 else { throw NSError(domain: "Coding Error", code: 1) }
    
    let newLevel = Int( ceil(log(dist)/CoverTreeNode.logBase) )
    
    if level! >= newLevel { return false }
    
    while level! < newLevel
    {
      level = level! + 1
      
      let newNode = CoverTreeNode(point, asChildOf:self, atDistance:0.0)
      newNode.children = self.children
      self.children = [ newNode ]
    }
    
    return true
  }
  
  @discardableResult func insert(_ p:DataPoint, history : History? = nil) -> Bool
  {
    let dist  = p.distance(from:self.point)
    
    // Case 1: We've already added this point to the tree
    //    Simply increase its count
    
    if dist == 0.0
    {
      self.point.incrementCount()
      return true
    }
    
    // Case 2: The tree currently only contains the root node
    //   Set level of root and insert new node as child

    if level == nil // this is currently the only node in the tree... we are adding the second node
    {
      let level = Int( ceil(log(dist)/CoverTreeNode.logBase) )
      
      self.level = level
      
      children.append( CoverTreeNode(self.point, asChildOf:self, atDistance:0.0  ) )
      children.append( CoverTreeNode(         p, asChildOf:self, atDistance:dist ) )
      
      return true
    }
    
    let sep = exp( Double(level!) * CoverTreeNode.logBase )
    
    // Case 3: The distance between the current node and new node is too big for coverage
    
    if dist > sep
    {
      // Case 3a: Current node is not root
      
      if parent != nil { return false }
      
      // Case 3b: Current node is root
      //    Increase level of root node as necessary
      //    Insert chain of nodes between new and old root node
      
      let newLevel = Int( ceil(log(dist)/CoverTreeNode.logBase) )
      
      while self.level! < newLevel
      {
        self.level = self.level! + 1
        let newNode = CoverTreeNode(self.point, asChildOf:self, atDistance:0.0)
        newNode.children = self.children
        self.children = [ newNode ]
      }
      
      children.append( CoverTreeNode( p, asChildOf:self, atDistance:dist) )
      return true
    }
    
    // Case 4: "Normal" flow
    //   See if any children can cover the node
    //   If not, add it to the current node
    
    for child in children
    {
      if child.insert(p, history:history) { return true }
    }
    
    children.append( CoverTreeNode( p, asChildOf:self, atDistance:dist ) )
    return true
  }
}
 
