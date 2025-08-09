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

protocol EventEditProtocol { }
extension EventInfo: EventEditProtocol {}
extension BurgerModel: EventEditProtocol {}

struct EkEventEditView: UIViewControllerRepresentable {
    let ekEvent: EKEvent?
    let eventEditModel: EventEditProtocol
    let dismiss: (EKEventEditViewAction, EventEditProtocol) -> Void
    
    @MainActor
    class Coordinator: NSObject, @preconcurrency EKEventEditViewDelegate {
        let eventEditModel: EventEditProtocol
        let dismiss: (EKEventEditViewAction, EventEditProtocol) -> Void
        
        init(eventEditModel: EventEditProtocol, dismiss: @escaping (EKEventEditViewAction, EventEditProtocol) -> Void) {
            self.eventEditModel = eventEditModel
            self.dismiss = dismiss
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            dismiss(action, eventEditModel)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(eventEditModel: eventEditModel, dismiss: dismiss)
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
