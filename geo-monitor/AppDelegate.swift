//
//  AppDelegate.swift
//  geo-monitor
//
//  Created by cybuhh on 17/03/2018.
//  Copyright © 2018 cybuhh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    @objc func changeAppDisplay(_ sender: Any?) {
        if (NSApp.isHidden) {
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.hide(nil);
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = #imageLiteral(resourceName: "insecure")
            button.action = #selector(changeAppDisplay(_:))
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

