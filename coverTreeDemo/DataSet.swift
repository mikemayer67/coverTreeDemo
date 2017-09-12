//
//  DataSet.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation

class Tuple
{
  let coord : [Double]
  
  init( _ x:Double... )
  {
    self.coord = x
  }
  
  init( coordinates : [Double])
  {
    self.coord = coordinates
  }
  
  var dim : Int { return coord.count }
  
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

class DataSet
{
  private(set) var tuples : [Tuple]
  let dim : Int
  
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
