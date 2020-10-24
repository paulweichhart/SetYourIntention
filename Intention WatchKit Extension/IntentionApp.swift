//
//  IntentionApp.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import SwiftUI
import WatchKit

@main
struct IntentionApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    private let intention = Intention()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                let coordinator = Coordinator()
                
                coordinator.navigate(to: .intentionView)
                coordinator.navigate(to: .editIntentionView)
            }
            .tabViewStyle(PageTabViewStyle())
            .environmentObject(intention)
        }
//        }.onChange(of: scenePhase, perform: { newScenePhase in
//            if newScenePhase == .background {
//                let watchExtension = WKExtension.shared()
//                let targetDate = Date().addingTimeInterval(15.0 * 60.0)
//                watchExtension.scheduleBackgroundRefresh(withPreferredDate: targetDate, userInfo: nil) { error in
//                    if let error = error {
//                        print("*** An background refresh error occurred: \(error.localizedDescription) ***")
//                        return
//                    }
//                    print("*** Background Task Completed Successfully! ***")
//                }
//            }
//        })
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

//class ExtensionDelegate: NSObject, WKExtensionDelegate {
//    
//    func applicationDidEnterBackground() {
//        scheduleBackgroundRefreshTasks()
//    }
//
//    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
//        for task in backgroundTasks {
//            
//            switch task {
//            case let backgroundTask as WKApplicationRefreshBackgroundTask:
//                Store.shared.mindfulMinutes(completion: { [weak self] in
//                    self?.scheduleBackgroundRefreshTasks()
//                    backgroundTask.setTaskCompletedWithSnapshot(true)
//                })
//                
//            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
//                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
//            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
//                connectivityTask.setTaskCompletedWithSnapshot(false)
//            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
//                urlSessionTask.setTaskCompletedWithSnapshot(false)
//            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
//                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
//            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
//                intentDidRunTask.setTaskCompletedWithSnapshot(false)
//            default:
//                task.setTaskCompletedWithSnapshot(false)
//            }
//        }
//    }
//    
//    private func scheduleBackgroundRefreshTasks() {
//        
//        let watchExtension = WKExtension.shared()
//        let targetDate = Date().addingTimeInterval(15.0 * 60.0)
//        watchExtension.scheduleBackgroundRefresh(withPreferredDate: targetDate, userInfo: nil) { (error) in
//            if let error = error {
//                print("*** An background refresh error occurred: \(error.localizedDescription) ***")
//                return
//            }
//            print("*** Background Task Completed Successfully! ***")
//        }
//    }
//}
