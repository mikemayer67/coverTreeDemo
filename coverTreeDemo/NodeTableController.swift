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
      print("Show \(newValue) rows (was \(visibleRows))")
      
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

  
}
