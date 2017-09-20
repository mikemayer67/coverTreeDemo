//
//  ViewController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate
{
  // MARK: - Shared Attributes
  
  var document : Document!
  
  dynamic              var randomizeDemoData = true
  dynamic              var dataDimension = 2
  dynamic              var dataCount = 20
  dynamic              var animationStep = 20
  
  let demos = [
    "Demo Set 1" : DataSet(Tuple(50), Tuple(25), Tuple(97), Tuple(32), Tuple(95), Tuple(8), Tuple(4), Tuple(12), Tuple(42), Tuple(60)),
    "Demo Set 2" : DataSet(Tuple(0,0), Tuple(1,0), Tuple(1,1), Tuple(2,3), Tuple(0.5,4.5), Tuple(-1.25, 3.0))
  ]
  
  // MARK: - Bindings/Outlets
  
  dynamic private(set) var generated = false
  dynamic private(set) var randomData = true
  dynamic private(set) var generateButtonEnabled = true
  
  @IBOutlet weak var dataSourcePopup: NSPopUpButton!
  @IBOutlet weak var dataSourceFinal: NSTextField!
  @IBOutlet weak var dataDimensionText: NSTextField!
  @IBOutlet weak var dataCountText: NSTextField!
  @IBOutlet weak var animationSlider: NSSlider!
  
  @IBOutlet weak var nodeTableController : NodeTableController!
  @IBOutlet weak var infoTextController  : InfoTextController!
  
  // MARK: - Input View Methods
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear()
  {
    super.viewWillAppear()
    guard document == nil else { return }  // only do the rest of the setup if this is first pass
    
    document = view.window?.windowController?.document as? Document!
    
    let ct = document.coverTree
    
    ct.logger = infoTextController
    
    generated = ct.generated
    if generated
    {
      dataSourceFinal.stringValue = ct.dataSource ?? "unknown"
      dataDimension = ct.dim
      dataCount     = ct.count
      
      animationSlider.maxValue = Double(dataCount)
      animationSlider.numberOfTickMarks = dataCount
      animationStep = dataCount
      
      nodeTableController.coverTree = ct
      nodeTableController.rows      = dataCount
      
      infoTextController.showing    = dataCount
    }
    else
    {
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
      
      randomData = ( dataSourcePopup.indexOfSelectedItem == 0 )
    }
  }
  
  @IBAction func handleDataSource(_ sender: NSPopUpButton)
  {
    randomData = ( dataSourcePopup.indexOfSelectedItem == 0 )
  }
  
  
  @IBAction func handleGenerate(_ sender: NSButton)
  {
    generateButtonEnabled = false
    
    // update user defaults
    
    let defaults = UserDefaults.standard
    defaults.set(true, forKey: "initialized")
    defaults.set(dataSourcePopup.indexOfSelectedItem, forKey: "dataSource")
    defaults.set(randomizeDemoData, forKey: "randomizeDemoData")
    defaults.set(dataDimension, forKey: "dataDimension")
    defaults.set(dataCount, forKey:"dataCount")
    
    // compute/lookup data sample
    
    let dataSource      = dataSourcePopup.titleOfSelectedItem!
    
    dataSourceFinal.stringValue = dataSource
    
    var data : DataSet!
    
    switch dataSourcePopup.indexOfSelectedItem
    {
    case 0:
      
      var tuples = [Tuple]()
      
      for _ in 1...dataCount
      {
        var coord = [Double]()
        for _ in 1...dataDimension
        {
          let x = 0.1 * Double( arc4random_uniform(2000) ) - 100.0
          coord.append(x)
        }
        let tuple = Tuple(coordinates:coord)
        tuples.append(tuple)
      }
      
      data = DataSet(tuples:tuples)
      
    default:
      
      data = demos[ dataSource ]!
      dataCount     = data.tuples.count
      dataDimension = data.dim
      
      if randomizeDemoData
      {
        data.randomize()
        dataSourceFinal.stringValue = "\(dataSource) [randomized]"
      }
    }
    
    // do the work
    
    document.coverTree.generate(dataSet:data, source:dataSourceFinal.stringValue)
    document.updateChangeCount(.changeDone)
    
    // update views
    
    animationSlider.maxValue = Double(dataCount)
    animationSlider.numberOfTickMarks = dataCount
    animationStep = dataCount
    
    nodeTableController.coverTree = document.coverTree
    nodeTableController.rows      = dataCount
    
    infoTextController.showing    = dataCount
    
    generated = true
  }
  
  override func controlTextDidEndEditing  (_ obj: Notification) { generateButtonEnabled = true }
  override func controlTextDidBeginEditing(_ obj: Notification) { generateButtonEnabled = false  }
  
  func control(_ control: NSControl, isValidObject obj: Any?) -> Bool { return obj != nil }
  
  @IBAction func handleAnimationSlider(_ sender: NSSlider)
  {
    nodeTableController.rows   = animationStep
    infoTextController.showing = animationStep
  }
  
}
