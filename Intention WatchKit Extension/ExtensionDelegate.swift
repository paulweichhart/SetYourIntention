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
    
    private enum UserInfoKey: String {
        case mindfulMinutes = "mindfulMinutes"
    }
    
    func applicationDidEnterBackground() {
        updateActiveComplications(shouldReload: true)
        if case let .mindfulMinutes(minutes) = Store.shared.state {
            scheduleBackgroundRefresh(minutes: minutes)
        } else {
            scheduleBackgroundRefresh(minutes: 0)
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                Store.shared.permission(completion: { [weak self] granted in
                     guard granted else {
                        return
                    }
                    Store.shared.mindfulMinutes(completion: { result in
                        let userInfo = backgroundTask.userInfo as? NSDictionary
                        let cachedMinutes = userInfo?[UserInfoKey.mindfulMinutes.rawValue] as? Double ?? 0
                        switch result {
                        case let .success(minutes):
                            let shouldReload = minutes != cachedMinutes
                            self?.updateActiveComplications(shouldReload: shouldReload)
                            self?.scheduleBackgroundRefresh(minutes: minutes)
                            backgroundTask.setTaskCompletedWithSnapshot(shouldReload)
                        
                        case .failure:
                            self?.updateActiveComplications(shouldReload: false)
                            self?.scheduleBackgroundRefresh(minutes: cachedMinutes)
                            backgroundTask.setTaskCompletedWithSnapshot(false)
                        }
                    })
                })
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    private func updateActiveComplications(shouldReload: Bool) {
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                if shouldReload {
                    complicationServer.reloadTimeline(for: complication)
                } else {
                    complicationServer.extendTimeline(for: complication)
                }
            }
        }
    }
    
    private func scheduleBackgroundRefresh(minutes: Double) {
        let scheduledDate = Date().addingTimeInterval(15 * 60)
        let userInfo: NSDictionary = [UserInfoKey.mindfulMinutes.rawValue: minutes]
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: scheduledDate, userInfo: userInfo, scheduledCompletion: { error in
            if error != nil {
                print("oh noes")
            }
        })
    }
}

