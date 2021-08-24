//
//  MindfulSession.swift
//  MindfulSessionState
//
//  Created by Paul Weichhart on 19.08.21.
//

import Foundation
import WatchKit

enum MindfulSessionState {
    case initial
    case meditating(Date)
    case error(HealthStoreError)
}

final class MindfulSession: NSObject, WKExtendedRuntimeSessionDelegate {

    private let session: WKExtendedRuntimeSession

    override init() {
        self.session = WKExtendedRuntimeSession()
        super.init()

        session.delegate = self
    }

    func startSession() -> Date {
        session.start()
        return Date()
    }

    func stopSession() -> Date {
        session.invalidate()
        return Date()
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        Task {
            await Store.shared.dispatch(action: .failedStoringMeditatingSession)
        }
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        session.notifyUser(hapticType: .failure,
                           repeatHandler: nil)
    }
}
