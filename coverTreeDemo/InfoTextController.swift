//
//  InfoTextController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/19/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class InfoTextController: NSObject, CoverTreeGenerationLogger, NSTextViewDelegate
{
  @IBOutlet weak var textView : NSTextView!
  
  private var infoStrings = [[NSAttributedString]]()
  
  func add(_ string: String, to level: Int)
  {
    while level >= infoStrings.count { infoStrings.append([]) }
    
    var raw  = string as NSString
    let info = NSMutableAttributedString()
    
    let regex = try! NSRegularExpression(pattern: "<<([0-9]+)>>", options: [])
    
    while let match = regex.firstMatch(in: raw as String, options: [], range: NSMakeRange(0, raw.length) )
    {
      let a = match.range.location
      let b = a + match.range.length
      
      if a > 0 { info.normal(raw.substring(with: NSMakeRange(0,a))) }
      if a < b { info.link(raw.substring(with:match.rangeAt(1)))    }
     
      if b < raw.length { raw = raw.substring(with: NSMakeRange(b,raw.length - b)) as NSString }
      else              { raw = "" }
    }
    
    if raw.length > 0 { info.normal(raw as String) }
    
    infoStrings[level].append(info)
  }
  
  func set(_ history: [[String]])
  {
    infoStrings.removeAll()
    guard history.count > 0 else { return }
    
    for level in 1...history.count
    {
      history[level-1].forEach { info in self.add(info, to:level) }
    }
  }
  
  var showing : Int = 0
  {
    didSet
    {
      let info = NSMutableAttributedString()
      
      for level in 1...showing
      {
        let head = NSMutableAttributedString()
        
        if level > 1 { head.newline() }
        head.bold("Node \(level)").newline()
        info.append(head)
        
        for s in infoStrings[level]
        {
          let line = NSMutableAttributedString(string:"    ")
          line.append(s)
          line.newline()
          info.append(line)
        }
      }
      textView.textStorage?.setAttributedString(info)
      textView.scrollToEndOfDocument(self)
    }
  }
  
  func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool
  {
    print("User clicked on \(link)")
    return true
  }
}
