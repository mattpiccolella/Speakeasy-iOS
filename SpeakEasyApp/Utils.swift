//
//  Utils.swift
//  SpeakEasyApp
//
//  Created by Matt on 6/27/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import Foundation

let SERIALIZE_MAP: Dictionary<String, String> = [
  "_70" : "\"",
  "_71" : "\"",
  "_72" : " ",
  "_73" : "-",
  "_74" : "#",
  "_75" : ".",
  "_76" : ",",
  "_77" : ":",
  "_78" : "{",
  "_79" : "}",
  "_80" : "[",
  "_81" : "]",
  "_82" : "(",
  "_83" : ")",
  "_84" : "<",
  "_85" : ">",
  "_86" : "/",
  "_87" : "\\",
  "_88" : "$",
  "_89" : "@",
  "_90" : "!",
  "_91" : "=",
  "_92" : "+",
  "_93" : "*",
  "_94" : "?",
  "_95" : "~",
]

func deserialize(string: String) -> NSString {
  var newString: NSString = string
  for (pattern, replace) in SERIALIZE_MAP {
    newString = newString.stringByReplacingOccurrencesOfString(pattern, withString: replace)
  }
  return newString.substringFromIndex(3)
}