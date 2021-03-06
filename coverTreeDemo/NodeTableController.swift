//
//  NodeTableController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/19/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

let kColumnPad : CGFloat = 10.0

protocol NodeTableControllerDelegate
{
  func selectedNode(didChangeTo node:Int, sender:Any)
}

class NodeTableController: NSObject, NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate
{
  var coverTree : CoverTree!
  
  @IBOutlet weak var tableView : NSTableView!
  var delegate : NodeTableControllerDelegate?
  
  func numberOfRows(in tableView: NSTableView) -> Int
  {
    return coverTree==nil ? 0 : coverTree.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
  {
    guard tableColumn != nil else { return nil }
    let column = tableColumn!.identifier
        
    let cell = tableView.make(withIdentifier: column, owner: self) as! NSTableCellView
    
    guard cell.textField != nil else { print("Null textField... returning \(cell)"); return cell }
    
    let node = coverTree.nodes[row]
    
    var value : String?
    
    switch column
    {
    case "NodeColumn":
      value = "\(node.ID)"
      
    case "LevelColumn":
      value = "\(node.level)"
      
    case "DataPointColumn":
      value = node.point.string
      
    case "ParentColumn":
      if let id = node.parent?.node.ID
      {
        value =  "\(id)"
      }
      
    case "DistanceColumn":
      if let dist = node.parent?.dist
      {
        value = dist.to_string(maxDecimals: 2)
      }
      
    case "ChildrenColumn":
      value = ""
      let levels = node.children.keys.sorted().reversed()
      var levelSep = ""
      for level in levels
      {
        value!.append("\(levelSep)\(level)(")
        var sep = ""
        for child in node.children[level]!
        {
          value!.append("\(sep)\(child.ID)")
          sep = " "
        }
        value!.append(")")
        levelSep = ", "
      }
      
    default:
      value = "\(column)"
    }
    
    if value != nil
    {
      let cs = NSAttributedString(string: value!)
      let r = cs.boundingRect(with: NSMakeSize(2000, 100), options: [])
      if r.size.width > tableColumn!.width
      {
        tableColumn!.width = r.size.width + kColumnPad
      }
    }
    
    cell.textField?.stringValue = value ?? ""
    
    return cell
  }

  
  func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool
  {
    print("User clicked on \(link)")
    return true
  }
  
  func tableViewColumnDidResize(_ notification: Notification)
  {
    self.tableView.reloadData()
  }
  
  func tableViewSelectionDidChange(_ notification: Notification)
  {
    let node = 1 + self.tableView.selectedRow
    delegate?.selectedNode(didChangeTo: node, sender: self)
  }
  
  func select(node:Int)
  {
    let row = node - 1
    if tableView.selectedRow != row
    {
      tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
      tableView.scrollRowToVisible(row)
    }
  }
}
