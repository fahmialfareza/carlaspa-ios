//
//  ViewController.swift
//  Carla Spa
//
//  Created by Fahmi Alfareza on 11/12/19.
//  Copyright © 2019 Karya Studio. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var webView: WKWebView!
    var manager: CLLocationManager!
    
    private var activityIndicatorContainer: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "locationHandler")
        
        let config = webView.configuration
        config.userContentController = contentController
        config.preferences.javaScriptEnabled = true
        
        let url = URL(string: "https://m.carlaspabali.com")
        let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(script)
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        self.refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.delegate = self
        webView.scrollView.addSubview(self.refreshControl)
        webView.customUserAgent = userAgent
        webView.load(URLRequest(url: url!))
    }

    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }

    fileprivate func setActivityIndicator() {
        // Configure the background containerView for the indicator
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = webView.center.x
        // Need to subtract 44 because WebKitView is pinned to SafeArea
        //   and we add the toolbar of height 44 programatically
        activityIndicatorContainer.center.y = webView.center.y - 44
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
      
        // Configure the activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        webView.addSubview(activityIndicatorContainer)
        
        // Constraints
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    fileprivate func showActivityIndicator(show: Bool) {
      if show {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
      }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.showActivityIndicator(show: false)
//        DispatchQueue.main.async {
//            self.loading.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Set the indicator everytime webView started loading
//        self.setActivityIndicator()
//        self.showActivityIndicator(show: true)
//        startAnimation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        self.showActivityIndicator(show: false)
//        DispatchQueue.main.async {
//            self.loading.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        self.showActivityIndicator(show: false)
//        DispatchQueue.main.async {
//            self.loading.stopAnimating()
//        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        if ((url?.contains("/downloadconfig/"))!)
        {
            // Do the downloading operation here
            let downloadUrl = navigationAction.request.url
            UIApplication.shared.canOpenURL(downloadUrl!)
            UIApplication.shared.open(downloadUrl!)
            // FileDownloader.loadFileSync(url: downloadUrl!) { (path, error) in
            //    print("PDF File downloaded to : \(path!)")
            // }
            
            // Block the webview to load a new url
            decisionHandler(.cancel);
            return;
        } else if ((url?.contains("/goo.gl/maps"))!)
        {
            // Do the downloading operation here
            let downloadUrl = navigationAction.request.url
            UIApplication.shared.canOpenURL(downloadUrl!)
            UIApplication.shared.open(downloadUrl!)
            // FileDownloader.loadFileSync(url: downloadUrl!) { (path, error) in
            //    print("PDF File downloaded to : \(path!)")
            // }
            
            // Block the webview to load a new url
            decisionHandler(.cancel);
            return;
        }
        decisionHandler(.allow);
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "locationHandler",let  messageBody = message.body as? String {
            if messageBody == "getCurrentPosition"{
                let script =
                    "getLocation(\(manager.location?.coordinate.latitude ?? 0) ,\(manager.location?.coordinate.longitude ?? 0))"
                webView?.evaluateJavaScript(script)
            }
        }
    }
}

