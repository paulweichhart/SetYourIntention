//
//  ExtensionDelegate.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 24.10.20.
//

import Combine
import ClockKit
import Foundation
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    private static let mindfulMinutesKey = "mindfulMinutes"
    private var cancellable = Set<AnyCancellable>()
    
    func applicationDidEnterBackground() {
        updateActiveComplications(shouldReload: true)
        Store.shared.mindfulMinutes()
            .sink(receiveCompletion: { [weak self] storeState in
                if case .failure = storeState {
                    self?.scheduleBackgroundRefresh(minutes: 0)
                }
            }, receiveValue: { [weak self] mindfulMinutes in
                self?.scheduleBackgroundRefresh(minutes: mindfulMinutes)
            })
            .store(in: &cancellable)
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let userInfo = backgroundTask.userInfo as? NSDictionary
                let cachedMinutes = userInfo?[Self.mindfulMinutesKey] as? Double ?? 0

                Store.shared.mindfulMinutes()
                    .sink(receiveCompletion: { [weak self] storeState in
                        if case .failure = storeState {
                            self?.updateActiveComplications(shouldReload: false)
                            self?.scheduleBackgroundRefresh(minutes: cachedMinutes)
                            backgroundTask.setTaskCompletedWithSnapshot(false)
                        }
                    }, receiveValue: { [weak self] mindfulMinutes in
                        let shouldReload = mindfulMinutes != cachedMinutes
                        self?.updateActiveComplications(shouldReload: shouldReload)
                        self?.scheduleBackgroundRefresh(minutes: mindfulMinutes)
                        backgroundTask.setTaskCompletedWithSnapshot(shouldReload)
                    })
                    .store(in: &cancellable)
                
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
        let userInfo: NSDictionary = [Self.mindfulMinutesKey: minutes]
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: scheduledDate,
                                                       userInfo: userInfo,
                                                       scheduledCompletion: { _ in })
    }
}

