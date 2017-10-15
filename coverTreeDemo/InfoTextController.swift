//
//  InfoTextController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/19/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

protocol InfoTextControllerDelegate
{
  func selectedNode(didChangeTo node:Int, sender:Any)
}

class InfoTextController: NSObject, CoverTreeGenerationLogger, NSTextViewDelegate
{
  @IBOutlet weak var textView : NSTextView!
  var delegate : InfoTextControllerDelegate?
  
  private var infoStrings = [[NSAttributedString]]()
  
  func add(_ string: String, to node: Int)
  {
    while node >= infoStrings.count { infoStrings.append([]) }

    var raw  = string as NSString
    let info = NSMutableAttributedString()
    
    let regex = try! NSRegularExpression(pattern: "<<([0-9]+)>>", options: [])
    
    while let match = regex.firstMatch(in: raw as String, options: [], range: NSMakeRange(0, raw.length) )
    {
      let a = match.range.location
      let b = a + match.range.length
      
      if a > 0 { info.normal(raw.substring(with: NSMakeRange(0,a))) }
      if a < b { info.normal("<"); info.link(raw.substring(with:match.range(at: 1))); info.normal(">") }
      
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
      
      info.bold("Node \(showing)").newline()
      
      for s in infoStrings[showing]
      {
        let line = NSMutableAttributedString(string:"    ")
        line.append(s)
        line.newline()
        info.append(line)
      }
      textView.textStorage?.setAttributedString(info)
      textView.scrollToBeginningOfDocument(self)
    }
  }
  
  func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool
  {
    if let linkString = link as? String, let linkID = Int(linkString)
    {
      delegate?.selectedNode(didChangeTo: linkID, sender: self)
    }
    return true
  }
  
  func select(node:Int)
  {
    self.showing = node;
  }
}
