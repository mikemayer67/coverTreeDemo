//
//  Statics.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 10/11/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation

class Statics
{
  static let factory : [ String : AnyObject ] =
  {
    let fd = Bundle.main.path(forResource: "FactoryStatics", ofType: "plist")
    return NSDictionary(contentsOfFile:fd!) as! [String : AnyObject]
  }()
  
  static let minNodeDiameter = factory["MinNodeDiameter"] as! CGFloat
  static let maxNodeDiameter = factory["MaxNodeDiameter"] as! CGFloat
  static let minLinkSep      = factory["MinLinkSep"]      as! CGFloat
  static let nodeFontSize    = factory["NodeFontSize"]    as! Int
  static let linkFontSize    = factory["LinkFontSize"]    as! Int
}
