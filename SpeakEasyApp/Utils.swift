//
//  Utils.swift
//  SpeakEasyApp
//
//  Created by Matt on 6/27/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import Foundation

let SERIALIZE_MAP: Dictionary<String, String> = [
  "_9470" : "\"",
  "_9471" : "\"",
  "_9472" : " ",
  "_9473" : "-",
  "_9474" : "#",
  "_9475" : ".",
  "_9476" : ",",
  "_9477" : ":",
  "_9478" : "{",
    "_9479" : "}",
  "_9480" : "[",
  "_9481" : "]",
  "_9482" : "(",
  "_9483" : ")",
  "_9484" : "<",
  "_9485" : ">",
  "_9486" : "/",
  "_9487" : "\\",
  "_9488" : "$",
  "_9489" : "@",
  "_9490" : "!",
  "_9491" : "=",
  "_9492" : "+",
  "_9493" : "*",
  "_9494" : "?",
  "_9495" : "~",
]

func deserialize(string: String) -> NSString {
  var newString: NSString = string
  for (pattern, replace) in SERIALIZE_MAP {
    newString = newString.stringByReplacingOccurrencesOfString(pattern, withString: replace)
  }
  return newString.substringFromIndex(3)
}