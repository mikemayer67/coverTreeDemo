//
//  DataSet.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation


class DataSet : NSObject, NSCoding
{
  private(set) var points : [DataPoint]
  let dim : Int
  
  var count : Int { return points.count }
  
  subscript(_ i:Int) -> DataPoint?
  {
    guard i>=0, i<count else { return nil }
    return points[i]
  }
  
  convenience init?(_ points:DataPoint... )
  {
    self.init(points:points)
  }
  
  init?( points : [DataPoint])
  {
    if points.count == 0 { return nil }
    
    self.points = points
    
    let t1 = points[0]
    self.dim = t1.dim
    
    for t in points
    {
      if t.dim != self.dim { return nil }
    }
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    guard aDecoder.containsValue(forKey: "dim")  else { return nil }
    guard aDecoder.containsValue(forKey: "data") else { return nil }
    
    dim = aDecoder.decodeInteger(forKey: "dim")
    
    if let t1 = aDecoder.decodeObject(forKey: "data") as? NSArray,
      let t2 = t1 as? Array<DataPoint>
    {
      self.points = t2
    }
    else
    {
      return nil
    }
  }
  
  func encode(with aCoder: NSCoder)
  {
    aCoder.encode(dim, forKey: "dim")
    aCoder.encode(points as NSArray, forKey: "data")
  }
  
  func randomize() -> Void
  {
    let n = points.count
    if n > 1
    {
      for i in 0...n-2
      {
        let j : Int = Int(arc4random_uniform(UInt32(n-i)))
        if i != j { swap( &(points[i]), &(points[j]) ) }
      }
    }
  }
}
