//
//  DraggableImageView.swift
//  Cloudy
//
//  Created by Greene, Carson on 8/20/19.
//  Copyright © 2019 Techsmith. All rights reserved.
//

import Foundation
import Cocoa
import CGiCloudSync

class DraggableImageView: NSImageView {
   let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: NSImage.imageTypes]
   
   var isReceivingDrag = false {
      didSet {
         needsDisplay = true
      }
   }
   
   static var filePath: URL {
      get {
         return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Pictures").appendingPathComponent("image").appendingPathExtension(UserDefaults.standard.string(forKey: "imageExtension") ?? "")
      }
   }
   
   func setup() {
      registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
   }
   
   override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)
      
      if isReceivingDrag {
         NSColor.selectedControlColor.set()
         
         let path = NSBezierPath(rect:bounds)
         path.lineWidth = 3
         path.stroke()
      }
   }
   
   func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
      var canAccept = false
      
      let pasteBoard = draggingInfo.draggingPasteboard
      if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
         canAccept = true
      }
      
      return canAccept
   }
   
   override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
      let allow = shouldAllowDrag(sender)
      isReceivingDrag = allow
      return allow ? .copy : NSDragOperation()
   }
   
   override func draggingExited(_ sender: NSDraggingInfo?) {
      isReceivingDrag = false
   }
   
   override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
      let allow = shouldAllowDrag(sender)
      return allow
   }
   
   override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
      isReceivingDrag = false
      let pasteBoard = draggingInfo.draggingPasteboard
      
      if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
         UserDefaults.standard.set(urls[0].pathExtension, forKey: "imageExtension")
         
         DispatchQueue.main.async {
            do {
               try CGCloudKit.saveFile(file: Data(contentsOf: urls[0]), withName: "image", toLocalPath: DraggableImageView.filePath)
            }
            catch {
               print(error.localizedDescription)
            }
         }

         return true
      }
      return false
   }
}
