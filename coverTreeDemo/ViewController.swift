//
//  ViewController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate, NSWindowDelegate
{
  
  enum ViewType : Int {
    case treeView    = 0
    case polarView   = 1
    case spatialView = 2
  }
  // MARK: - Shared Attributes
  
  var document : Document!
  
  dynamic var randomizeDemoData = true
  dynamic var dataDimension     = 2
  dynamic var dataCount         = 20
  dynamic var animationStep     = 20
  
  let demos = [
    "Demo Set 1" : DataSet(DataPoint(50), DataPoint(25), DataPoint(97), DataPoint(32), DataPoint(95), DataPoint(8), DataPoint(4), DataPoint(12), DataPoint(42), DataPoint(60)),
    "Demo Set 2" : DataSet(DataPoint(0,0), DataPoint(1,0), DataPoint(1,1), DataPoint(2,3), DataPoint(0.5,4.5), DataPoint(-1.25, 3.0))
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
  @IBOutlet weak var viewTypeControl: NSSegmentedControl!
  
  @IBOutlet weak var nodeTableController : NodeTableController!
  @IBOutlet weak var infoTextController  : InfoTextController!
  
  private(set) var viewType : ViewType?
  {
    didSet
    {
      if viewType == oldValue { print("No change in view type: \(viewType)") }
      else                    { print("View changed from \(oldValue) to \(viewType)") }
    }
  }
  
  // MARK: - Input View Methods
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    view.window?.delegate = self
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
      nodeTableController.tableView.reloadData()
      
      infoTextController.showing    = dataCount
      
      viewTypeControl.segmentCount = ( dataDimension > 3 ? 2 : 3 )
      viewType = .treeView
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
    
    let dataSource = dataSourcePopup.titleOfSelectedItem!
    
    dataSourceFinal.stringValue = dataSource
    
    var data : DataSet!
    
    switch dataSourcePopup.indexOfSelectedItem
    {
    case 0:
      
      var points = [DataPoint]()
      
      for _ in 1...dataCount
      {
        var coord = [Double]()
        for _ in 1...dataDimension
        {
          let x = 0.1 * Double( arc4random_uniform(2000) ) - 100.0
          coord.append(x)
        }
        let point = DataPoint(coordinates:coord)
        points.append(point)
      }
      
      data = DataSet(points:points)
      
    default:
      
      data = demos[ dataSource ]!
      dataCount     = data.points.count
      dataDimension = data.dim
      
      if randomizeDemoData
      {
        data.randomize()
        dataSourceFinal.stringValue = "\(dataSource) [randomized]"
      }
    }
    
    // do the work
    
    guard document.coverTree.generate(dataSet:data, source:dataSourceFinal.stringValue) else { return }
    
    document.updateChangeCount(.changeDone)
    
    // update views
    
    animationSlider.maxValue = Double(dataCount)
    animationSlider.numberOfTickMarks = dataCount
    animationStep = dataCount
    
    nodeTableController.coverTree = document.coverTree
    nodeTableController.rows      = dataCount
    
    infoTextController.showing    = dataCount
    
    viewTypeControl.segmentCount = ( dataDimension > 3 ? 2 : 3 )
    viewType = .treeView
    
    generated = true
  }
  
  override func controlTextDidEndEditing  (_ obj: Notification) { generateButtonEnabled = true }
  override func controlTextDidBeginEditing(_ obj: Notification) { generateButtonEnabled = false  }
  
  func control(_ control: NSControl, isValidObject obj: Any?) -> Bool { return obj != nil }
  
  @IBAction func handleAnimationSlider(_ sender: NSSlider)
  {
    set(animationStep:animationStep)
  }
  
  @IBAction func handleViewTypeControl(_ sender: NSSegmentedControl)
  {
    viewType = ViewType(rawValue: viewTypeControl.selectedSegment)
  }
  
  func set(animationStep newValue:Int)
  {
    guard (newValue >= 1) && (newValue <= dataCount) else { return }
    
    if animationStep != newValue { animationStep = newValue }
    
    nodeTableController.rows   = animationStep
    infoTextController.showing = animationStep
  }
  
  override func keyDown(with event: NSEvent)
  {
    if event.modifierFlags.contains(NSNumericPadKeyMask)
    {
      if let key = event.charactersIgnoringModifiers?.utf16.first
      {
        switch Int(key)
        {
        case NSRightArrowFunctionKey: set(animationStep: animationStep + 1); return
        case NSLeftArrowFunctionKey:  set(animationStep: animationStep - 1); return
        default: break;
        }
      }
    }
    super.keyDown(with:event)
  }
}
