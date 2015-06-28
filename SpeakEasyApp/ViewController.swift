//
//  ViewController.swift
//  SpeakEasyApp
//
//  Created by Matt on 6/27/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, WitDelegate {

  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var overlay: UIView!
  @IBOutlet var webView: UIWebView!
  let wit: Wit = Wit.sharedInstance()
  var isRecording: Bool = false
  var isLoaded: Bool = true
  var numberOfWebViews: Int = 0
  var webActions: [String] = []
  var previousURL: String = ""
  var hasTriedAction: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.delegate = self
    webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://news.ycombinator.com")!))
    addMicButton()
    wit.delegate = self
    wit.setContext(["state" : "news.ycombinator.com"])
    overlay.alpha = 0.5
    overlay.hidden = true
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
    if numberOfWebViews > 0 {
      numberOfWebViews--
    }
    println("Number of views: \(numberOfWebViews)")
    if numberOfWebViews == 0 {
      if webActions.count > 0 {
        let currentAction = webActions[0]
        let currentURL = webView.request!.mainDocumentURL!.absoluteString!
        if previousURL != currentURL && hasTriedAction {
          webActions.removeAtIndex(0)
          hasTriedAction = false
          if webActions.count > 0 {
            webView.stringByEvaluatingJavaScriptFromString(webActions[0])
          }
        } else {
          webView.stringByEvaluatingJavaScriptFromString(currentAction)
          hasTriedAction = true
        }
        previousURL = currentURL
      }
    }
    println("Web Views: \(webActions)")
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    isLoaded = false
    numberOfWebViews++
    println("Number of views: \(numberOfWebViews)")
  }

  func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
    if numberOfWebViews > 0 {
      numberOfWebViews--
    }
    println("Number of views: \(numberOfWebViews)")
  }
  
  // MARK: WitDelegate
  func witDidGraspIntent(outcomes: [AnyObject]!, messageId: String!, customData: AnyObject!, error e: NSError!) {
    overlay.hidden = true
    activityIndicator.stopAnimating()
    if outcomes != nil {
      let outcome: NSDictionary = outcomes[0] as! NSDictionary
      println(outcome)
      // handleOutcome(outcome)
      
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
    overlay.hidden = true
    activityIndicator.stopAnimating()
  }
  
  func witDidStopRecording() {
    overlay.hidden = false
    activityIndicator.startAnimating()
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
    } else if intent == "news" {
      let search_query: NSString = outcome.valueForKeyPath("entities.search_query.value")![0] as! NSString
      let newURL: String = "http://mobile.nytimes.com/search?query=\(search_query)&sort=rel"
      webView.loadRequest(NSURLRequest(URL: NSURL(string: newURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!))
    } else if intent == "youtube" {
      let search_query: NSString = outcome.valueForKeyPath("entities.search_query.value")![0] as! NSString
      let newURL: String = "https://www.youtube.com/results?search_query=\(search_query)"
      webView.loadRequest(NSURLRequest(URL: NSURL(string: newURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!))
      let clickResult = "document.querySelector('a[aria-label*=\"\(search_query)\"]').click()"
      webActions.append(clickResult)
    } else if intent == "restaurants" {
      let location: NSString = outcome.valueForKeyPath("entities.location.value")![0] as! NSString
      let search_query: NSString = outcome.valueForKeyPath("entities.local_search_query.value")![0] as! NSString
      let newURL: String = "https://www.yelp.com/search?find_desc=\(search_query)&find_loc=\(location)"
      webView.loadRequest(NSURLRequest(URL: NSURL(string: newURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!))
    } else if intent == "navigate" {
      var site: NSString = outcome.valueForKeyPath("entities.url.value")![0] as! NSString
      if !site.containsString(".com") {
        site = (site as String) +  ".com"
      }
      let newURL: String = "http://\(site)"
      webView.loadRequest(NSURLRequest(URL: NSURL(string: newURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!))
    }
  }
}

