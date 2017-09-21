//
//  NodeTableController.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 9/19/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Cocoa

class NodeTableController: NSObject, NSTableViewDelegate, NSTableViewDataSource
{
  var coverTree : CoverTree!
  
  @IBOutlet weak var tableView : NSTableView!
  
  private var visibleRows = 0
  
  var rows : Int
  {
    get { return visibleRows }
    set
    {      
      let newCount = max( 1, min( newValue, coverTree.count ) )
      
      if newCount > visibleRows
      {
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet(visibleRows ... newCount-1), withAnimation: [])
        tableView.endUpdates()
      }
      else if newCount < visibleRows
      {
        tableView.beginUpdates()
        tableView.removeRows(at: IndexSet(newCount ... visibleRows-1), withAnimation: [])
        tableView.endUpdates()
      }
      visibleRows = newCount
    }
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int
  {
    return visibleRows
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
  {
    guard tableColumn != nil else { return nil }
    let column = tableColumn!.identifier
        
    let cell = tableView.make(withIdentifier: column, owner: self) as! NSTableCellView
    let node = row + 1
    
    switch column
    {
      case "NodeColumn":
      cell.textField?.stringValue = "\(node)"
      
      case "LevelColumn":
        cell.textField?.stringValue = "\(10*row+2)"

      case "TupleColumn":
      cell.textField?.stringValue = "[\(0.1 * Double(row)), \(0.0 * Double(row)), \(10.01 * Double(row))])"
    default:
      cell.textField?.stringValue = "? \(column)"
    }
    
    return cell
  }

  
}
