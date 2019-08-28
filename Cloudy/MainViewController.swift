//
//  MainViewController.swift
//  Cloudy
//
//  Created by Greene, Carson on 8/14/19.
//  Copyright © 2019 Techsmith. All rights reserved.
//

import Cocoa
import CGiCloudSync

class MainViewController: NSViewController, NSDraggingDestination {
   let kExampleBoolSetting = "exampleBoolSetting"
   let kExampleStringSetting = "exampleStringSetting"
   let kExampleIntSetting = "exampleIntSetting"
   let kExampleDoubleSetting = "exampleDoubleSetting"
   
   @IBOutlet var imageWell: NSImageView?
   
   @objc var iCloudSyncEnabled: Bool {
      get {
         return CGiCloud.iCloudSyncEnabled
      }
      set {
         let watchedKeys = [kExampleBoolSetting,
                            kExampleStringSetting,
                            kExampleIntSetting,
                            kExampleDoubleSetting]
         
         keysWillChange(keys: watchedKeys)
         CGiCloudKVStore.syncFromCloud(keys: watchedKeys)
         keysDidChange(keys: watchedKeys)
        
        updateImageWell()
         
         CGiCloud.iCloudSyncEnabled = newValue
      }
   }
   
   @objc var exampleBoolSetting: Bool {
      get {
         return CGiCloudKVStore.bool(forKey: "exampleBoolSetting")
      }
      set {
         CGiCloudKVStore.set(bool:newValue, forKey: "exampleBoolSetting")
      }
   }

   @objc var exampleStringSetting: String? {
      get {
         return CGiCloudKVStore.string(forKey: "exampleStringSetting")
      }
      set {
         if let stringToSet = newValue {
            CGiCloudKVStore.set(string:stringToSet, forKey: "exampleStringSetting")
         }
      }
   }
   
   @objc var exampleIntSetting: Int {
      get {
         return CGiCloudKVStore.int(forKey: "exampleIntSetting")
      }
      set {
         CGiCloudKVStore.set(int: newValue, forKey: "exampleIntSetting")
      }
   }
   
   @objc var exampleDoubleSetting: Double {
      get {
         return CGiCloudKVStore.double(forKey: "exampleDoubleSetting")
      }
      set {
         CGiCloudKVStore.set(double: newValue, forKey: "exampleDoubleSetting")
      }
   }
   
   @objc func ubiquitousKeyStoreDidChange(notification: Notification) {
      if iCloudSyncEnabled {
         if let ubiquitousKVUserInfo = notification.userInfo,
            let changedKeys = ubiquitousKVUserInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as! [String]? {
            
            keysWillChange(keys: changedKeys)
            CGiCloudKVStore.syncFromCloud(keys: changedKeys)
            keysDidChange(keys: changedKeys)
         }
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousKeyStoreDidChange(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
      
      updateImageWell()
      
      if (!UserDefaults.standard.bool(forKey: "subscribed")) {
         CGCloudKit.subscribeToChanges(forFile: "image")
         UserDefaults.standard.set(true, forKey: "subscribed")
      }
   }
   
   override func viewDidAppear() {
      super.viewDidAppear()
      view.window?.title = "Cloudy"
   }
   
   public func updateImageWell() {
      CGCloudKit.loadFile(withName: "image", fromLocalPath: DraggableImageView.filePath, callback: {
         (data) in
         DispatchQueue.main.async {
            self.imageWell?.image = NSImage(data: data)
            self.imageWell?.needsDisplay = true
         }
      })
   }
   
   func keysWillChange(keys: [String]) {
      for key in keys {
         willChangeValue(forKey: key)
      }
   }
   
   func keysDidChange(keys: [String]) {
      for key in keys {
         didChangeValue(forKey: key)
      }
   }
}

