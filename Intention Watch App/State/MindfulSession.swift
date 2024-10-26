//
//  MindfulSession.swift
//  MindfulSessionState
//
//  Created by Paul Weichhart on 19.08.21.
//

import Foundation
import WatchKit

final class MindfulSession: NSObject, WKExtendedRuntimeSessionDelegate {

    private var session: WKExtendedRuntimeSession?

    func startSession() -> Date {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        return Date()
    }

    func stopSession() -> Date {
        session?.invalidate()
        return Date()
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        Task { @MainActor in
            await Store.shared.dispatch(action: .failedStoringMeditatingSession)
        }
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        Task { @MainActor in
            await Store.shared.dispatch(action: .stopMeditatingAndFetchMindfulTimeInterval)
        }
    }
}
