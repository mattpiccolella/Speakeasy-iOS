//
//  ViewController.swift
//  SpeakEasyApp
//
//  Created by Matt on 6/27/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, WitDelegate {

  @IBOutlet var webView: UIWebView!
  let wit: Wit = Wit.sharedInstance()
  var isRecording: Bool = false
  var isLoaded: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://news.ycombinator.com")!))
    addMicButton()
    wit.delegate = self
    wit.setContext(["state" : "news.ycombinator.com"])
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func addMicButton() {
    let size: CGSize = view.frame.size
    let buttonFrame: CGRect = CGRectMake((size.width / 2.0) - 25.0, size.height - 70.0, 50.0, 50.0)
    let micButton: WITMicButton = WITMicButton(frame: buttonFrame)
    view.addSubview(micButton)
  }

  // MARK: UIWebViewDelegate
  func webViewDidFinishLoad(webView: UIWebView) {
    isLoaded = true
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    isLoaded = false
  }
  
  // MARK: WitDelegate
  func witDidGraspIntent(outcomes: [AnyObject]!, messageId: String!, customData: AnyObject!, error e: NSError!) {
    if outcomes != nil {
      let outcome: NSDictionary = outcomes[0] as! NSDictionary
      let response: NSString = outcome.valueForKeyPath("intent") as! NSString
      let sampleResponse: NSString = deserialize(response as String)
      println(sampleResponse)
      let resultData: NSData = sampleResponse.dataUsingEncoding(NSUTF8StringEncoding)!
      var result: NSDictionary = NSJSONSerialization.JSONObjectWithData(resultData, options: nil, error: nil) as! NSDictionary
      let selectors = result.valueForKeyPath("data")! as! NSArray
      for index in 0...selectors.count-1 {
        let selector = selectors[index] as! NSDictionary
        let selectorName: String = selector.valueForKeyPath("data.selector")! as! String
        println(selectorName)
        while !isLoaded {}
        handleResponse(selectorName)
      }
    } else {
      println("BALLS")
    }
  }
  
  func handleResponse(selector: String) {
    let formFill: String = "document.querySelector('\(selector)').click();"
    println(formFill)
    webView.stringByEvaluatingJavaScriptFromString(formFill)
  }
  
  func witDidStartRecording() {
    println("Weeeee")
  }
  
  func witDidStopRecording() {
    println("Aweeee")
  }
  
  func startRecord() {
    wit.start()
  }
}

