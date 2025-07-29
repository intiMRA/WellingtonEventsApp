//
//  EkEventEditView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 29/07/2025.
//

import Foundation
import SwiftUI
import EventKitUI
import EventKit
import DesignLibrary

struct EkEventEditView: UIViewControllerRepresentable {
    let ekEvent: EKEvent
    let eventInfo: EventInfo
    let dismiss: (EKEventEditViewAction, EventInfo) -> Void
    
    @MainActor
    class Coordinator: NSObject, @preconcurrency EKEventEditViewDelegate {
        let eventInfo: EventInfo
        let dismiss: (EKEventEditViewAction, EventInfo) -> Void
        
        init(eventInfo: EventInfo, dismiss: @escaping (EKEventEditViewAction, EventInfo) -> Void) {
            self.eventInfo = eventInfo
            self.dismiss = dismiss
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            dismiss(action, eventInfo)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(eventInfo: eventInfo, dismiss: dismiss)
    }
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = CalendarManager.eventStore
        controller.editViewDelegate = context.coordinator
        controller.event = ekEvent
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // No updates needed typically
    }
}
