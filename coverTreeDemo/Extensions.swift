//
//  Extensions.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/19/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation
import AppKit

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
  let result = NSMutableAttributedString()
  result.append(left)
  result.append(right)
  return result
}

extension NSMutableAttributedString
{
  @discardableResult func bold(_ text:String, at size:CGFloat = 0.0) -> NSMutableAttributedString
  {
    let t = NSAttributedString (
      string:text,
      attributes:[NSAttributedStringKey.font : NSFont.boldSystemFont(ofSize: size)]
    )
    self.append(t)
    
    return self
  }
  
  @discardableResult func normal(_ text:String, at size:CGFloat = 0.0) -> NSMutableAttributedString
  {
    self.append(
      NSAttributedString(
        string:text,
        attributes:[NSAttributedStringKey.font : NSFont.systemFont(ofSize: size)]
      )
    )
    return self
  }
  
  @discardableResult func link(_ text:String, at size:CGFloat = 0.0) -> NSMutableAttributedString
  {
    return link(text, for:text, at:size)
  }
  
  @discardableResult func link(_ text:String, for link:String, at size:CGFloat = 0.0) -> NSMutableAttributedString
  {
    self.append(
      NSAttributedString(
        string:text,
        attributes:[NSAttributedStringKey.font : NSFont.systemFont(ofSize: size),
                    NSAttributedStringKey.link : link ]
      )
    )
    return self
  }
  
  @discardableResult func newline() -> NSMutableAttributedString
  {
    self.append( NSAttributedString(string:"\n") )
    return self
  }
}

extension Double
{
  func to_string(maxDecimals n:Int) -> String
  {
    guard n>0 else { return "\(self)" }
    let fmt = "%.\(n)f"
    var rval = String(format:fmt, self)
    while rval.characters.last == "0"
    {
      rval.characters.removeLast()
    }
    if rval.characters.last == "."
    {
      rval.characters.removeLast()
    }
    return rval
  }
}

