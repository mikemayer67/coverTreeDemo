//
//  ViewController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/8/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate, NSWindowDelegate, InfoTextControllerDelegate, NodeTableControllerDelegate
{
  // MARK: - Shared Attributes
  
  var document : Document!
  
  @objc dynamic var randomizeDemoData = true
  @objc dynamic var dataDimension     = 2
  @objc dynamic var dataCount         = 20
  @objc dynamic var animationStep     = 20
  
  let demos = [
    "Demo Set 1" : DataSet(DataPoint(50), DataPoint(25), DataPoint(97), DataPoint(32), DataPoint(95), DataPoint(8), DataPoint(4), DataPoint(12), DataPoint(42), DataPoint(60)),
    "Demo Set 2" : DataSet(DataPoint(0,0), DataPoint(1,0), DataPoint(1,1), DataPoint(2,3), DataPoint(0.5,4.5), DataPoint(-1.25, 3.0))
  ]
  
  // MARK: - Bindings/Outlets
  
  @objc dynamic private(set) var generated = false
  @objc dynamic private(set) var randomData = true
  @objc dynamic private(set) var generateButtonEnabled = true
  
  @IBOutlet weak var dataSourcePopup: NSPopUpButton!
  @IBOutlet weak var dataSourceFinal: NSTextField!
  @IBOutlet weak var dataInfoFinal: NSTextField!
  @IBOutlet weak var dataDimensionText: NSTextField!
  @IBOutlet weak var dataCountText: NSTextField!
  @IBOutlet weak var animationSlider: NSSlider!
//  @IBOutlet weak var viewTypeControl: NSSegmentedControl!
//  @IBOutlet weak var zoomSlider: NSSlider!
  
  @IBOutlet weak var nodeTableController : NodeTableController!
  @IBOutlet weak var infoTextController  : InfoTextController!
  @IBOutlet weak var coverTreeView       : CoverTreeView!
  
  //
  // MARK: - Loading View Controller
  //
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    nodeTableController.delegate = self
    infoTextController.delegate = self
  }
  
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
    
    let ct    = document.coverTree
    ct.logger = infoTextController
    
    if ct.generated { configureToShowTree() }
    else            { configureForInput()   }
  }
  
  //
  // MARK: - Tree Not Yet Generated
  //
  
  func configureForInput()
  {
    for (key,_) in demos { dataSourcePopup.addItem(withTitle: key) }
    
    let defaults = UserDefaults.standard
    if defaults.bool(forKey: "initialized")
    {
      var dataSourceSelection = defaults.integer( forKey: "dataSource"        )
      randomizeDemoData       = defaults.bool(    forKey: "randomizeDemoData" )
      dataDimension           = defaults.integer( forKey: "dataDimension"     )
      dataCount               = defaults.integer( forKey: "dataCount"         )
      
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
    dataInfoFinal.stringValue = "Dimension: \(dataDimension)  Samples: \(dataCount)"

    
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
    
    self.configureToShowTree()
  }
  
  override func controlTextDidEndEditing  (_ obj: Notification) { generateButtonEnabled = true }
  override func controlTextDidBeginEditing(_ obj: Notification) { generateButtonEnabled = false  }
  
  func control(_ control: NSControl, isValidObject obj: Any?) -> Bool { return obj != nil }
  
  //
  // MARK: - Generated Tree Being Shown
  //
  
//  @objc dynamic var zoom : CGFloat = 0.0
//  
//  private var activeView  : CoverTreeView?
//
//  
////  private(set) var viewType : ViewType?
//  {
//    didSet
//    {
//      if viewType != oldValue
//      {
//        let oldView = activeView
//        switch viewType!
//        {
//        case .treeView:     activeView = treeView
//        case .polarView:    activeView = polarView
//        case .spatialView:  activeView = spatialView
//        }
//        activeView?.isHidden = false
//        oldView?.isHidden = true
//        
//        zoom = activeView?.zoom ?? 0.0
//      }
//    }
//  }
  
  func configureToShowTree()
  {
    let ct    = document.coverTree

    dataSourceFinal.stringValue = ct.dataSource ?? "unknown"
    dataInfoFinal.stringValue = "Dimension: \(ct.dim)  Samples: \(ct.count)"
    dataDimension = ct.dim
    dataCount     = ct.count
    
    animationSlider.maxValue = Double(dataCount)
    animationSlider.numberOfTickMarks = dataCount
    animationStep = dataCount
    
    nodeTableController.coverTree = ct
    nodeTableController.tableView.reloadData()
    nodeTableController.select(node: dataCount)
    
    infoTextController.showing    = dataCount
    
    coverTreeView.coverTree = ct
    
    generated = true
  }
  
  @IBAction func handleAnimationSlider(_ sender: NSSlider)
  {
    set(animationStep:animationStep)
  }
  
//  @IBAction func handleViewTypeControl(_ sender: NSSegmentedControl)
//  {
//    viewType = ViewType(rawValue: viewTypeControl.selectedSegment)
//  }
//  
  func set(animationStep newValue:Int)
  {
    guard (newValue >= 1) && (newValue <= dataCount) else { return }
    
    if animationStep != newValue { animationStep = newValue }
    
    nodeTableController.select(node:animationStep)
    infoTextController.showing = animationStep
  }
  
  override func keyDown(with event: NSEvent)
  {
    if event.modifierFlags.contains(.numericPad)
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
  
  // MARK :- Cross view methods
  
  func selectedNode(didChangeTo node: Int, sender: Any)
  {
    if (sender as? NodeTableController) != nodeTableController { nodeTableController.select(node:node) }
    if (sender as? InfoTextController)  != infoTextController  { infoTextController.select(node:node)  }
    
    if node > animationStep { animationStep = node }
  }
//  
//  @IBAction func handleZoomSlider(_ sender: NSSlider)
//  {
//    activeView?.zoom = zoom
//  }
}
