//
//  ExtensionDelegate.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 24.10.20.
//

import ClockKit
import Foundation
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidEnterBackground() {
        updateActiveComplications()
        scheduleBackgroundRefresh()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let store = Store.shared
                store.permission(completion: { [weak self] granted in
                    guard granted else {
                        return
                    }
                    store.mindfulMinutes(completion: { _ in
                        self?.updateActiveComplications()
                        self?.scheduleBackgroundRefresh()
                        // TODO: Update UI
                        backgroundTask.setTaskCompletedWithSnapshot(true)
                    })
                })
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    private func updateActiveComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
    
    private func scheduleBackgroundRefresh() {
        let scheduledDate = Date().addingTimeInterval(15 * 60)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: scheduledDate, userInfo: nil, scheduledCompletion: { error in
            if error != nil {
                print("oh noes")
            }
        })
    }
}

