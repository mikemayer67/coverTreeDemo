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
  @IBOutlet weak var viewController : ViewController!
  
  private var infoStrings = [[NSAttributedString]]()
  private var infoRanges  = [NSRange]()
  
  func add(_ string: String, to node: Int)
  {
    while node >= infoStrings.count { infoStrings.append([]) }
    while node >= infoRanges.count  { infoRanges.append(NSMakeRange(0, 0)) }
    
    var raw  = string as NSString
    let info = NSMutableAttributedString()
    
    let regex = try! NSRegularExpression(pattern: "<<([0-9]+)>>", options: [])
    
    while let match = regex.firstMatch(in: raw as String, options: [], range: NSMakeRange(0, raw.length) )
    {
      let a = match.range.location
      let b = a + match.range.length
      
      if a > 0 { info.normal(raw.substring(with: NSMakeRange(0,a))) }
      if a < b { info.normal("<"); info.link(raw.substring(with:match.rangeAt(1))); info.normal(">") }
      
      if b < raw.length { raw = raw.substring(with: NSMakeRange(b,raw.length - b)) as NSString }
      else              { raw = "" }
    }
    
    if raw.length > 0 { info.normal(raw as String) }
    
    infoStrings[node].append(info)
  }
  
  func set(_ history: [[String]])
  {
    infoStrings.removeAll()
    guard history.count > 0 else { return }
    
    for node in 1...history.count
    {

      history[node-1].forEach { info in self.add(info, to:node) }

    }
  }
  
  var showing : Int = 0
  {
    didSet
    {
      let info = NSMutableAttributedString()
      
      for node in 1...showing
      {
        let startOfRange = info.length;

        let head = NSMutableAttributedString()
        
        if node > 1 { head.newline() }
        head.bold("Node \(node)").newline()
        info.append(head)
        
        for s in infoStrings[node]
        {
          let line = NSMutableAttributedString(string:"    ")
          line.append(s)
          line.newline()
          info.append(line)
        }
        let endOfRange = info.length
        
        infoRanges[node] = NSMakeRange(startOfRange, endOfRange-startOfRange)
        
        print("End of info for node \(node) = \(info.length)")
      }
      textView.textStorage?.setAttributedString(info)
      textView.scrollToEndOfDocument(self)
    }
  }
  
  func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool
  {
    if let linkString = link as? String,
      let linkID = Int(linkString)
    {
      viewController.select(node: linkID)
    }
    return true
  }
  
  func select(node:Int)
  {
    print("Show inof for node \(node)")
    textView.scrollRangeToVisible(infoRanges[node])
  }
}
