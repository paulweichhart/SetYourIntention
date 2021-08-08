//
//  ExtensionDelegate.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 24.10.20.
//

import ClockKit
import Foundation
import WatchKit
import HealthKit

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    private let mindfulTimeIntervalKey = "mindfulTimeInterval"
    private let store = Store.shared

    func applicationDidEnterBackground() {
        updateActiveComplications(shouldReload: true)
        Task {
            await store.dispatch(action: .requestHealthStorePermission)
            await store.dispatch(action: .fetchMindfulTimeInterval)
            switch store.state.mindfulState {
            case let .loaded(timeInterval):
                scheduleBackgroundRefresh(mindfulTimeInterval: timeInterval)
            case .loading, .error:
                scheduleBackgroundRefresh(mindfulTimeInterval: 0)
            }
            await store.dispatch(action: .startObservingMindfulStoreChanges({ [weak self] in
                await self?.updateActiveComplicationsIfNeeded()
            }))
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {

            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let userInfo = backgroundTask.userInfo as? NSDictionary
                let cachedTimeInterval = userInfo?[mindfulTimeIntervalKey] as? TimeInterval ?? 0
                Task {
                    await store.dispatch(action: .requestHealthStorePermission)
                    await store.dispatch(action: .fetchMindfulTimeInterval)
                    switch store.state.mindfulState {
                    case let .loaded(mindfulTimeInterval):
                        let shouldReload = mindfulTimeInterval != cachedTimeInterval
                        updateActiveComplications(shouldReload: shouldReload)
                        scheduleBackgroundRefresh(mindfulTimeInterval: mindfulTimeInterval)
                        backgroundTask.setTaskCompletedWithSnapshot(shouldReload)
                    case .loading, .error:
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

    private func updateActiveComplicationsIfNeeded() async {
        let currentState = store.state.mindfulState
        await store.dispatch(action: .requestHealthStorePermission)
        await store.dispatch(action: .fetchMindfulTimeInterval)
        if currentState != store.state.mindfulState {
            updateActiveComplications(shouldReload: true)
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

