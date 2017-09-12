//
//  InputViewController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class InputViewController: NSViewController
{
  @IBOutlet weak var dataTypeTabView: NSTabView!
  @IBOutlet weak var demoDataSetField: NSPopUpButton!
  @IBOutlet weak var demoDataRandomizeCheckbox: NSButton!
  @IBOutlet weak var randDataDimField: NSTextField!
  @IBOutlet weak var randDataCountField: NSTextField!
  @IBOutlet weak var demoDataTab: NSTabViewItem!
  @IBOutlet weak var randDataTab: NSTabViewItem!
  
  let demos = [
    "Demo Set 1" : DataSet(Tuple(50), Tuple(25), Tuple(97), Tuple(32), Tuple(95), Tuple(8), Tuple(4), Tuple(12), Tuple(42), Tuple(60)),
    "Demo Set 2" : DataSet(Tuple(0,0), Tuple(1,0), Tuple(1,1), Tuple(2,3), Tuple(0.5,4.5), Tuple(-1.25, 3.0))
  ]
  
  var coverTree : CoverTree?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    demoDataSetField.removeAllItems()
    
    for (key,_) in demos
    {
      demoDataSetField.addItem(withTitle: key)
    }
  }
  
  @IBAction func cancel(_ sender: NSButton)
  {
    if let window = self.view.window
    {
      if let parent = window.sheetParent
      {
        parent.endSheet(window)
        if let wc = parent.windowController
        {
          wc.shouldCloseDocument = true
          wc.close()
        }
      }
    }
  }
  
  
  @IBAction func applyInputs(_ sender:NSButton)
  {
    
    var ds : DataSet!
    
    if dataTypeTabView.selectedTabViewItem == demoDataTab
    {
      let key = demoDataSetField.titleOfSelectedItem!
      ds = demos[key]!!
      
      if demoDataRandomizeCheckbox.state == NSOnState { ds.randomize() }
    }
    else
    {
      let dim = randDataDimField.integerValue
      let n   = randDataCountField.integerValue
      
      var tuples = [Tuple]()
      
      for _ in 0...n
      {
        var coord = [Double]()
        for _ in 1...dim
        {
          let x = 0.1 * Double( arc4random_uniform(2000) ) - 100.0
          coord.append(x)
        }
        let tuple = Tuple(coordinates:coord)
        tuples.append(tuple)
      }
      
      ds = DataSet(tuples:tuples)
    }
    
    coverTree?.generate(dataSet: ds)
    
    if let window = self.view.window
    {
      window.sheetParent?.endSheet(window)
    }
  }
}
