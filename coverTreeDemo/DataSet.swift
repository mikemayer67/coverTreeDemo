//
//  DataSet.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation

class Tuple : NSObject, NSCoding
{
  let coord : [Double]
  
  var dim : Int { return coord.count }
  
  init( _ x:Double... )
  {
    self.coord = x
  }
  
  init( coordinates : [Double])
  {
    self.coord = coordinates
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    guard aDecoder.containsValue(forKey: "coord") else { return nil }
    
    if let t1 = aDecoder.decodeObject(forKey: "coord") as? NSArray,
      let t2 = t1 as? Array<Double>
    {
      coord = t2
    }
    else
    {
      return nil
    }
  }
  
  func encode(with aCoder: NSCoder)
  {
    aCoder.encode(coord as NSArray, forKey: "coord")
  }
  
  
  func dist( x : Tuple ) -> Double
  {
    var rval = 0.0
    for (a,b) in zip(self.coord, x.coord)
    {
      let d = a - b
      rval += d * d
    }
    return rval
  }
}

class DataSet : NSObject, NSCoding
{
  private(set) var tuples : [Tuple]
  let dim : Int
  
  var count : Int { return tuples.count }
  
  convenience init?(_ tuples:Tuple... )
  {
    self.init(tuples:tuples)
  }
  
  init?( tuples : [Tuple])
  {
    if tuples.count == 0 { return nil }
    
    self.tuples = tuples
    
    let t1 = tuples[0]
    self.dim = t1.dim
    
    for t in tuples
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
      let t2 = t1 as? Array<Tuple>
    {
      self.tuples = t2
    }
    else
    {
      return nil
    }
  }
  
  func encode(with aCoder: NSCoder)
  {
    aCoder.encode(dim, forKey: "dim")
    aCoder.encode(tuples as NSArray, forKey: "data")
  }
  
  func randomize() -> Void
  {
    let n = tuples.count
    if n > 1
    {
      for i in 0...n-2
      {
        let j : Int = Int(arc4random_uniform(UInt32(n-i)))
        if i != j { swap( &(tuples[i]), &(tuples[j]) ) }
      }
    }
  }
}
