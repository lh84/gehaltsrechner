//
//  AppDelegate.swift
//  Gehaltsrechner
//
//  Created by Lars Häuser on 15.10.15.
//  Copyright © 2015 Lars Häuser. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Insert code here to initialize your application
//        window.backgroundColor = NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }


}

class MainWindow: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        super.window?.backgroundColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    }
    
}

