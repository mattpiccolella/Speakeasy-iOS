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
  var numberOfWebViews: Int = 0
  var webActions: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.delegate = self
    webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://wikipedia.com")!))
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
    webView.stringByEvaluatingJavaScriptFromString("document.getElementById('searchInput').value = 'Matt'")
    numberOfWebViews--
    println("Number of views: \(numberOfWebViews)")
    if numberOfWebViews == 0 {
      println("Web Actions: \(webActions)")
      if webActions.count > 0 {
        let currentAction = webActions[0]
        webView.stringByEvaluatingJavaScriptFromString(currentAction)
        webActions.removeAtIndex(0)
        println("Web Actions: \(webActions)")
      }
    }
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    isLoaded = false
    numberOfWebViews++
    println("Number of views: \(numberOfWebViews)")
  }

  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    numberOfWebViews--
    println("Number of views: \(numberOfWebViews)")
  }
  
  // MARK: WitDelegate
  func witDidGraspIntent(outcomes: [AnyObject]!, messageId: String!, customData: AnyObject!, error e: NSError!) {
    if outcomes != nil {
      let outcome: NSDictionary = outcomes[0] as! NSDictionary
      println(outcome)
      handleOutcome(outcome)
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

  // MARK: Link Handling
  func handleOutcome(outcome: NSDictionary) {
    let intent: NSString = outcome.valueForKeyPath("intent") as! NSString
    if intent == "google" {
      let search_query: NSString = outcome.valueForKeyPath("entities.search_query.value")![0] as! NSString
      let newURL: String = "https://www.google.com/search?q=\(search_query)"
      webView.loadRequest(NSURLRequest(URL: NSURL(string: newURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!))
    } else if intent == "rottentomatoes" {
      let search_query: NSString = outcome.valueForKeyPath("entities.search_query.value")![0] as! NSString
      let newURL: String = "http://www.rottentomatoes.com/search/?search=\(search_query)"
      webView.loadRequest(NSURLRequest(URL: NSURL(string: newURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!))
      let clickResult = "document.querySelectorAll('#movie_results_ul a')[0].click()"
      webActions.append(clickResult)
    }
    let search_query: NSString = outcome.valueForKeyPath("entities.search_query.value")![0] as! NSString
  }
}

