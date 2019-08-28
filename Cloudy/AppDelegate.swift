//
//  AppDelegate.swift
//  Cloudy
//
//  Created by Greene, Carson on 8/14/19.
//  Copyright © 2019 Techsmith. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

   func applicationDidFinishLaunching(_ aNotification: Notification) {
      NSApplication.shared.registerForRemoteNotifications()
   }

   func applicationWillTerminate(_ aNotification: Notification) {
      // Insert code here to tear down your application
   }

   func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
      if let mvc = application.mainWindow?.contentViewController as! MainViewController? {
         mvc.updateImageWell()
      }
   }
}

