//
//  CoverTreeViewController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class CoverTreeViewController: NSViewController
{
  var document : Document?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewDidAppear()
  {
    super.viewDidAppear()

    if document == nil { document = self.view.window?.windowController?.document as? Document }
    if document == nil { return }
    
    if document!.coverTree.generated == false
    {
      let sb = NSStoryboard(name: "Main", bundle: nil)
      let iwc = sb.instantiateController(withIdentifier: "InputWindowController") as! NSWindowController
      let ivc = iwc.contentViewController as! InputViewController
      
      ivc.coverTree = document!.coverTree
      
      view.window?.beginSheet(iwc.window!)
      {
        response in
        print("Setup complete \(response)")
      }
    }
  }
}
