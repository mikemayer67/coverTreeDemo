//
//  CoverTreeViewController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class CoverTreeViewController: NSViewController, NSTextFieldDelegate
{
  var document : Document?
  
  dynamic private(set) var generated = false
  dynamic private(set) var randomData = true
  dynamic private(set) var editingText = false
  dynamic              var randomizeDemoData = true
  dynamic              var dataDimension = 2
  dynamic              var dataCount = 20
  dynamic              var animationStep = 20
  
  @IBOutlet weak var dataSourcePopup: NSPopUpButton!
  @IBOutlet weak var dataSourceFinal: NSTextField!
  @IBOutlet weak var dataDimensionText: NSTextField!
  @IBOutlet weak var dataCountText: NSTextField!
  @IBOutlet weak var animationSlider: NSSlider!
  
  let demos = [
    "Demo Set 1" : DataSet(Tuple(50), Tuple(25), Tuple(97), Tuple(32), Tuple(95), Tuple(8), Tuple(4), Tuple(12), Tuple(42), Tuple(60)),
    "Demo Set 2" : DataSet(Tuple(0,0), Tuple(1,0), Tuple(1,1), Tuple(2,3), Tuple(0.5,4.5), Tuple(-1.25, 3.0))
  ]
  
  private(set) var dataDimensionToolTip : String?
  private(set) var dataCountToolTip     : String?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    for (key,_) in demos
    {
      dataSourcePopup.addItem(withTitle: key)
    }
    
    let defaults = UserDefaults.standard
    if defaults.bool(forKey: "initialized")
    {
      var dataSourceSelection = defaults.integer(forKey: "dataSource")
      randomizeDemoData       = defaults.bool(forKey: "randomizeDemoData")
      dataDimension           = defaults.integer(forKey: "dataDimension")
      dataCount               = defaults.integer(forKey:"dataCount")
      
      if dataDimension < 1 { dataDimension = 1 }
      if dataCount     < 1 { dataCount     = 1 }
      
      if dataSourceSelection < 0           { dataSourceSelection = 0 }
      if dataSourceSelection > demos.count { dataSourceSelection = 0 }
      
      dataSourcePopup.selectItem(at: dataSourceSelection)
    }
    
    if let minDim = (dataDimensionText.formatter as! NumberFormatter).minimum,
      let maxDim = (dataDimensionText.formatter as! NumberFormatter).maximum
    {
      dataDimensionText.toolTip = "Valid range: \(minDim)-\(maxDim)"
    }
    if let minCount = (dataCountText.formatter as! NumberFormatter).minimum,
      let maxCount = (dataCountText.formatter as! NumberFormatter).maximum
    {
      dataCountText.toolTip     = "Valid range: \(minCount)-\(maxCount)"
    }
    
    generated  = false
    randomData = ( dataSourcePopup.indexOfSelectedItem == 0 )
  }
  
  @IBAction func handleDataSource(_ sender: NSPopUpButton)
  {
    randomData = ( dataSourcePopup.indexOfSelectedItem == 0 )
  }
  
  @IBAction func handleGenerate(_ sender: NSButton)
  {
    let defaults = UserDefaults.standard
    defaults.set(true, forKey: "initialized")
    defaults.set(dataSourcePopup.indexOfSelectedItem, forKey: "dataSource")
    defaults.set(randomizeDemoData, forKey: "randomizeDemoData")
    defaults.set(dataDimension, forKey: "dataDimension")
    defaults.set(dataCount, forKey:"dataCount")
    
    let dataSource = dataSourcePopup.titleOfSelectedItem!
    
    if dataSourcePopup.indexOfSelectedItem > 0,
      randomizeDemoData
    {
      dataSourceFinal.stringValue = "\(dataSource) [randomized]"
    }
    else
    {
      dataSourceFinal.stringValue = dataSource
    }
    
    animationSlider.maxValue = Double(dataCount)
    animationSlider.numberOfTickMarks = dataCount
    animationStep = dataCount
    generated = true
  }
  
  override func controlTextDidEndEditing(_ obj: Notification) {
    editingText = false
  }
  
  override func controlTextDidBeginEditing(_ obj: Notification) {
    editingText = true
  }
  
  func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
    //    guard obj != nil else { return false }
    if obj == nil
    {
      let textField = control as! NSTextField
      textField.stringValue = "0"
      return false
    }
    return true
  }
  
  
}
