//
//  InfoTextView.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/20/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class InfoTextView: NSTextView
{
  override func keyDown(with event: NSEvent)
  {
    if event.modifierFlags.contains(.numericPad),
      let key = event.charactersIgnoringModifiers?.utf16.first
    {
      switch Int(key)
      {
      case NSRightArrowFunctionKey,NSLeftArrowFunctionKey:
        nextResponder?.keyDown(with: event)
        return
        
      default:
        break
      }
    }
    super.keyDown(with:event)
  }
}
