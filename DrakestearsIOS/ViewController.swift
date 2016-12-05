//
//  ViewController.swift
//  DrakestearsIOS
//
//  Created by Dinh, Liem on 5/15/16.
//  Copyright © 2016 Dinh, Liem. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController, WKScriptMessageHandler, GCKDeviceScannerListener, GCKLoggerDelegate {

    @IBOutlet var containerView: UIView!
    var webView: WKWebView?
    
    //private let kReceiverAppID = "A9350595"
    private let kReceiverAppID = "794B7BBF"
    
    
    override func loadView() {
        super.loadView()
        GCKLogger.sharedInstance().delegate = self
        getChromecastList(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var contentController = WKUserContentController();
        var userScript = WKUserScript(
            source: "webkitLoaded()",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame: self.containerView.bounds,
            configuration: config
        )
        self.view = webView;
        
        //self.webView!.UIDelegate = self
        //self.webView!.navigationDelegate = self
        
        
        var url = NSURL(string:"http://192.168.1.125/v1/home.php")
        var req = NSURLRequest(URL:url!)
        self.webView!.loadRequest(req)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userContentController(userContentController: WKUserContentController!, didReceiveScriptMessage message: WKScriptMessage!) {
        if(message.name == "callbackHandler") {
            // print("JavaScript is sending a message \(message.body)")
            //getChromecastList(false)
            self.webView!.evaluateJavaScript("window.setChromecasts(\(1 + 1))") { (result, error) in
                if error == nil {
                    // print(result)
                } else {
                    print(error)
                }
            }
        }
    }
    
    func getChromecastList(shouldStart: Bool) {
        //print("Start scanning for chomecasts")
        // Establish filter criteria.
        
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID: kReceiverAppID)
     
        // Initialize device scanner.
        let deviceScanner = GCKDeviceScanner(filterCriteria: filterCriteria)
        //deviceScanner.passiveScan = false
        //deviceScanner.startScan()
        //print("foundDevice: \(deviceScanner.hasDiscoveredDevices) isScanning: \(deviceScanner.scanning)")
        //deviceScanner.addListener(self)
        
        if let deviceScanner = deviceScanner {
            // print("starting to scan")
            if (shouldStart) {
                deviceScanner.addListener(self)
                deviceScanner.startScan()
                deviceScanner.passiveScan = true
            } else {
                deviceScanner.passiveScan = false
            }
            //print("foundDevice: \(deviceScanner.hasDiscoveredDevices) isScanning: \(deviceScanner.scanning)")
            //for device in deviceScanner.devices  {
            //    print(device.friendlyName)
            //}
        }
    }
    
    func deviceDidComeOnline(device: GCKDevice!) {
        print("Device found: \(device.friendlyName)");
        //for device in deviceScanner.devices  {
        //    print(device.friendlyName)
        //}
    }
    
    func deviceDidChange(device: GCKDevice!) {
        print("Device found: \(device.friendlyName)");
    }
    
    /**
     *
     * Start of all our logging of navigation
     */
    
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        print("webView:\(webView) didStartProvisionalNavigation:\(navigation)")
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation) {
        print("webView:\(webView) didCommitNavigation:\(navigation)")
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        
        let url = navigationAction.request.URL
        
        switch navigationAction.navigationType {
        case .LinkActivated:
            if navigationAction.targetFrame == nil {
                self.webView?.loadRequest(navigationAction.request)
            }
        default:
            break
        }
        
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: ((WKNavigationResponsePolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationResponse:\(navigationResponse) decisionHandler:\(decisionHandler)")
        
        decisionHandler(.Allow)
    }
    
    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
        print("webView:\(webView) didReceiveServerRedirectForProvisionalNavigation:\(navigation)")
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        print("webView:\(webView) didFinishNavigation:\(navigation)")
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation, withError error: NSError) {
        print("webView:\(webView) didFailNavigation:\(navigation) withError:\(error)")
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: NSError) {
        print("webView:\(webView) didFailProvisionalNavigation:\(navigation) withError:\(error)")
    }
    
    // LOGGER
    func logFromFunction(function: UnsafePointer<Int8>, message: String!) {
        let functionName = String.fromCString(function)
        print(functionName! + " - " + message);
    }


}

