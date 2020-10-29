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
    
    func applicationDidBecomeActive() {
        Store.shared.mindfulMinutes()
    }
    
    func applicationDidEnterBackground() {
        scheduleBackgroundRefresh()
        updateActiveComplications()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                Store.shared.mindfulMinutes(completion: { [weak self] in
                    self?.updateActiveComplications()
                    self?.scheduleBackgroundRefresh()
                    backgroundTask.setTaskCompletedWithSnapshot(true)
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

