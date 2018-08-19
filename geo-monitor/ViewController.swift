//
//  ViewController.swift
//  geo-monitor
//
//  Created by cybuhh on 17/03/2018.
//  Copyright © 2018 cybuhh. All rights reserved.
//

// https://digitalleaves.com/complete-guide-networking-in-swift/

import Cocoa

func geoIP(forAddress address: String = "",
           cbFn: @escaping (_ error: Error?, _ result: NSDictionary?)->Void) {
    
    let urlStr = "https://geoip.nekudo.com/api/\(address)"
    let url = URL(string: urlStr)!
    let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: TimeInterval(2))
    
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = TimeInterval(5)
    config.timeoutIntervalForResource = TimeInterval(5)
    
    let urlSession = URLSession(configuration: config)

    let dataTask = urlSession.dataTask(with: request) {
        (data, response, error) in
        DispatchQueue.main.async {
            if (error != nil) {
                return cbFn(error!, nil)
            }
            do {
                if let result = try JSONSerialization.jsonObject(with: data!) as? NSDictionary {
                    cbFn(nil, result)
                }
            } catch let error as NSError {
                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                return cbFn(error, nil)
            }

        }
    }
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
        dataTask.resume()
    })
}

func getDnsIp() -> String {
    let dnsCmd = "host -a google.com | grep Received | tr '#' ' ' | cut -d ' ' -f 5"
    let processTask = Process()
    let pipe = Pipe()
    processTask.launchPath = "/usr/bin/env"
    processTask.arguments = ["bash", "-c", dnsCmd]
    processTask.standardOutput = pipe
    processTask.launch()
    processTask.waitUntilExit()
    if processTask.terminationStatus == 0 {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let dnsIp = (NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
            .replacingOccurrences(of: "\n", with: "")
        return dnsIp
    }
    return ""
}

class ViewController: NSViewController {
    @IBOutlet weak var ipAddressResultTextField: NSTextField!
    @IBOutlet weak var ipGeoResultTextField: NSTextField!
    @IBOutlet weak var dnsAddressResultTextField: NSTextField!
    @IBOutlet weak var dnsGeoResultTextField: NSTextField!

    var statusItemButton: NSButton?

    var location = [
        "ip": "",
        "ip-geo": "",
        "dns": "",
        "dns-geo": ""
        ]{
        didSet {
            ipAddressResultTextField.stringValue = location["ip"]!
            ipGeoResultTextField.stringValue = location["ip-geo"]!
            dnsAddressResultTextField.stringValue = location["dns"]!
            dnsGeoResultTextField.stringValue = location["dns-geo"]!

            if (location["ip-geo"]?.count == 2 && location["dns-geo"]?.count == 2 &&
                location["ip-geo"] != "PL" && location["dns-geo"] != "PL") {
                statusItemButton?.image = #imageLiteral(resourceName: "secure")
            } else {
                statusItemButton?.image = #imageLiteral(resourceName: "insecure")
            }
        }
    }
    
    func checkStatus() {
        geoIP(forAddress: getDnsIp(),
              cbFn: {(error, result) -> Void in
                if (error == nil) {
                    self.location["ip"] = result?["ip"] as? String
                    let country = result?["country"] as? NSDictionary
                    self.location["ip-geo"] = country?["code"] as? String
                } else {
                    self.location["ip"] = ""
                    self.location["ip-geo"] = ""
                }
        })
        geoIP(cbFn: {(error, result) -> Void in
            if (error == nil) {
                self.location["dns"] = result?["ip"] as? String
                let country = result?["country"] as? NSDictionary
                self.location["dns-geo"] = country?["code"] as? String
            } else {
                self.location["dns"] = ""
                self.location["dns-geo"] = ""
            }
        })
    }
    
    @IBAction func refreshButtonClicked(_ sender: NSButton) {
        checkStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        statusItemButton = appDelegate.statusItem.button!
        Timer.scheduledTimer(withTimeInterval: 5,
                             repeats: true,
                             block: { (_) -> Void in self.checkStatus() })
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

