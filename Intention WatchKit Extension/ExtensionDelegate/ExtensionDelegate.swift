//
//  ExtensionDelegate.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 24.10.20.
//

import ClockKit
import Foundation
import WatchKit

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    private let mindfulTimeIntervalKey = "mindfulTimeInterval"
    private let healthStore = HealthStore()
    
    func applicationDidEnterBackground() {
        updateActiveComplications(shouldReload: true)
        Task {
            do {
                try await healthStore.requestPermission()
                let mindfulTimeInterval = try await healthStore.fetchMindfulTimeInterval()
                scheduleBackgroundRefresh(mindfulTimeInterval: mindfulTimeInterval)
            } catch {
                scheduleBackgroundRefresh(mindfulTimeInterval: 0)
            }
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let userInfo = backgroundTask.userInfo as? NSDictionary
                let cachedTimeInterval = userInfo?[mindfulTimeIntervalKey] as? TimeInterval ?? 0
                Task {
                    do {
                        try await healthStore.requestPermission()
                        let mindfulTimeInterval = try await healthStore.fetchMindfulTimeInterval()
                        let shouldReload = mindfulTimeInterval != cachedTimeInterval
                        updateActiveComplications(shouldReload: shouldReload)
                        scheduleBackgroundRefresh(mindfulTimeInterval: mindfulTimeInterval)
                        backgroundTask.setTaskCompletedWithSnapshot(shouldReload)
                    } catch {
                        updateActiveComplications(shouldReload: false)
                        scheduleBackgroundRefresh(mindfulTimeInterval: cachedTimeInterval)
                        backgroundTask.setTaskCompletedWithSnapshot(false)
                    }
                }

            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(restoredDefaultState: true,
                                              estimatedSnapshotExpiration: Date.distantFuture,
                                              userInfo: nil)
                
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
    
    private func scheduleBackgroundRefresh(mindfulTimeInterval: TimeInterval) {
        let scheduledDate = Date().addingTimeInterval(Converter.timeInterval(from: 15))
        let userInfo: NSDictionary = [mindfulTimeIntervalKey: mindfulTimeInterval]
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: scheduledDate,
                                                       userInfo: userInfo,
                                                       scheduledCompletion: { _ in })
    }
}

