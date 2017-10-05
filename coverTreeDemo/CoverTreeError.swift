//
//  CoverTreeError.swift
//  coverTreeDemo
//
//  Created by Mike Mayer on 10/3/17.
//  Copyright © 2017 VMWishes. All rights reserved.
//

import Foundation

enum CoverTreeError : Error
{
  case codingError(String)
  case fileContentError(String)
}
