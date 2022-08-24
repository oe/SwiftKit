//
//  File.swift
//  
//
//  Created by Saiya Lee on 8/24/22.
//

import Foundation

/// enum for loading data status
///  T for loaded Data Type
public enum LoadingStatus<T> {
  case idle
  case loading
  case loaded(T)
  case error(String, Error? = nil)
}

