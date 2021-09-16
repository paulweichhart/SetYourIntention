//
//  MindfulSession.swift
//  MindfulSessionState
//
//  Created by Paul Weichhart on 19.08.21.
//

import Foundation
import WatchKit

enum MindfulSessionState: Equatable {
    case initial
    case meditating(Date)
    case error(HealthStoreError)
}

final class MindfulSession: NSObject, WKExtendedRuntimeSessionDelegate {

    private var session: WKExtendedRuntimeSession?
    private var timer: Timer?

    func startSession(with interval: TimeInterval) -> Date {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        let startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] _ in
            self?.notifyUser(success: true)
        })
        session?.start()
        return startDate
    }

    func stopSession() -> Date {
        session?.invalidate()
        timer?.invalidate()
        return Date()
    }

    func notifyUser(success: Bool) {
        WKInterfaceDevice.current().play(success ? .success : .failure)
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        Task {
            await Store.shared.dispatch(action: .failedStoringMeditatingSession)
        }
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        notifyUser(success: false)
    }
}
