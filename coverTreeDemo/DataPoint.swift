//
//  DataPoint.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/25/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation

class DataPoint : NSObject, NSCoding
{
  let coord : [Double]
  
  var dim : Int { return coord.count }
  
  private(set) var count = 1
  
  private var _string : String!  
  var string : String
  {
    if _string == nil
    {
      for x in self.coord
      {
        if _string == nil { _string = "( " }
        else              { _string.append(", ") }
        _string.append( x.to_string(maxDecimals: 2))
      }
      _string.append(" )")
    }
    return _string
  }
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
  
  func incrementCount() { count += 1 }
  
  func distance(from x : DataPoint ) -> Double
  {
    var rval = 0.0
    for (a,b) in zip(self.coord, x.coord)
    {
      let d = a - b
      rval += d * d
    }
    return sqrt(rval)
  }
}
