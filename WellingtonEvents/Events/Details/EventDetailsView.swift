//
//  EventDetailsView.swift
//  WellingtonEvents
//
//  Created by Inti Albuquerque on 18/07/2025.
//

import Foundation
import SwiftUI
import DesignLibrary
import SwiftUINavigation
import EventKitUI

struct EventDetailsView: View {
    @State var viewModel: EventDetailsViewModel
    @EnvironmentObject var actionsManager: ActionsManager
    
    init(viewModel: EventDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            switch viewModel.route {
            case .alert(let toastStyle):
                ToastView(model: .init(style: toastStyle, shouldDismiss: { [weak viewModel] in viewModel?.resetRoute() }))
            default:
                EmptyView()
            }
        }
        .task {
            await viewModel.generateSnapshot()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showWebView()
                }
                label: {
                    Text("View Event")
                        .bold()
                }
            }
        }
        .sheet(item: $viewModel.route.webView, id: \.self) { url in
            NavigationView {
                WebView(url: url)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewModel.resetRoute()
                            }
                            label: {
                                Text("Close")
                            }
                        }
                        ToolbarItem(placement: .automatic) {
                            Button {
                                UIApplication.shared.open(url)
                            }
                            label: {
                                Text("Open In Browser")
                            }
                        }
                    }
            }
        }
        .sheet(item: $viewModel.route.calendar) { event in
            NavigationView {
                DatePickerView(viewModel: .init(
                    event: viewModel.event,
                    repository: viewModel.repository,
                    dismiss: { [weak viewModel] style in
                        viewModel?.dissmissCalendar(style)
                    }))
                .environmentObject(actionsManager)
            }
        }
        .sheet(item: $viewModel.route.editEvent, id: \.eventInfo) { info in
            EkEventEditView(ekEvent: info.ekEvent, eventEditModel: info.eventInfo, dismiss: didDismissEditCalanderView)
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: .small) {
                imageView
                if #available(iOS 26.0, *) {
                    actionIconsView26
                } else {
                    actionIconsView
                }
                Divider()
                    .foregroundStyle(.text)
                
                infoView
                
                Divider()
                    .foregroundStyle(.text)
                ForEach(viewModel.event.description.replacingOccurrences(of: "!\n", with: ".\n").split(separator: ".\n"), id: \.self) { line in
                    Text(line.description.contains(".") || line.description.contains("!") ? line : "\(line).")
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.leading)
                }
                
                Divider()
                    .foregroundStyle(.text)
                
                mapImage
                
                Divider()
                    .foregroundStyle(.text)
                
                StyledButtonView(type: .openWebView) {
                    viewModel.showWebView()
                }
                .padding(.bottom, .medium)
            }
        }
        .padding(.horizontal, .medium)
    }
    
    func saveTocalendar(event: EventInfo) async {
        if event.dates.count > 1 {
            viewModel.route = .calendar(event: event)
        }
        else {
            if await actionsManager.addToCalendar(event: event, date: event.dates.firstValidDate, errorHandler: viewModel.showErrorAlert) {
                viewModel.route = .alert(.success(title: AlertMessages.addCalendarSuccess.title, message: AlertMessages.addCalendarSuccess.message))
            }
        }
    }
}

extension EventDetailsView {
    @ViewBuilder
    var infoView: some View {
        Text(viewModel.event.name)
            .font(.title)
            .foregroundStyle(.text)
            .multilineTextAlignment(.leading)
        VStack(alignment: .leading, spacing: .xxSmall) {
            if viewModel.happeningSoon {
                Text("Happening soon!")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if viewModel.happeningNow {
                Text("Happening now!")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            else {
                HStack(alignment: .top) {
                    Text("Date:")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                    if let eventDate = viewModel.eventDate {
                        Text(eventDate)
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            if viewModel.multipleDates {
                Text("multiple dates")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

extension EventDetailsView {
    @ViewBuilder
    var imageView: some View {
        ZStack(alignment: .bottomLeading) {
            DetailImageView(url: viewModel.event.imageUrl ?? "")
            Text(viewModel.event.source)
                .imageOverlay()
                .padding(.all, .xSmall)
        }
    }
}

extension EventDetailsView {
    @ViewBuilder
    var actionIconsView: some View {
        let isFavourited = actionsManager.isEventFavourited(id: viewModel.event.id)
        let isInCalendar = actionsManager.isEventInCalendar(id: viewModel.event.id)
        HStack(alignment: .top, spacing: .xSmall) {
            Button {
                Task {
                    if isFavourited {
                        await actionsManager.deleteFromFavorites(event: viewModel.event, errorHandler: viewModel.showErrorAlert)
                    }
                    else {
                        await actionsManager.saveToFavorites(event: viewModel.event, errorHandler: viewModel.showErrorAlert)
                    }
                }
            } label: {
                (isFavourited ? Image(.heartFill) : Image(.heart))
                    .resizable()
                    .squareFrame(size: 36)
            }
            
            Button {
                Task {
                    if isInCalendar {
                        await viewModel.presentEditCalendar()
                    }
                    else {
                        await saveTocalendar(event: viewModel.event)
                    }
                }
            } label: {
                VStack {
                    (isInCalendar ? Image(.calendarTick) : Image(.calendar))
                        .resizable()
                        .squareFrame(size: 36)
                    if isInCalendar {
                        Text("Edit")
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
                }
            }
            .foregroundStyle(.text)
            
            
            if let url = URL(string: viewModel.event.url) {
                ShareLink(item: url) {
                    Image(.share)
                        .squareFrame(size: 36)
                }
            }
        }
        .padding(.all, .medium)
    }
    
    @available(iOS 26.0, *)
    @ViewBuilder
    var actionIconsView26: some View {
        let isFavourited = actionsManager.isEventFavourited(id: viewModel.event.id)
        let isInCalendar = actionsManager.isEventInCalendar(id: viewModel.event.id)
        HStack(alignment: .top, spacing: .xSmall) {
            Button {
                Task {
                    if isFavourited {
                        await actionsManager.deleteFromFavorites(event: viewModel.event, errorHandler: viewModel.showErrorAlert)
                    }
                    else {
                        await actionsManager.saveToFavorites(event: viewModel.event, errorHandler: viewModel.showErrorAlert)
                    }
                }
            } label: {
                (isFavourited ? Image(.heartFillClear) : Image(.heartClear))
                    .resizable()
                    .squareFrame(size: 36)
                    .glassEffect()
            }
            
            Button {
                Task {
                    if isInCalendar {
                        await viewModel.presentEditCalendar()
                    }
                    else {
                        await saveTocalendar(event: viewModel.event)
                    }
                }
            } label: {
                VStack {
                    (isInCalendar ? Image(.calendarTickClear) : Image(.calendarClear))
                        .resizable()
                        .squareFrame(size: 36)
                        .glassEffect()
                    if isInCalendar {
                        Text("Edit")
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
                }
            }
            
            
            if let url = URL(string: viewModel.event.url) {
                ShareLink(item: url) {
                    Image(.shareClear)
                        .squareFrame(size: 36)
                        .glassEffect()
                }
            }
        }
        .padding(.all, .medium)
    }
}

extension EventDetailsView {
    @ViewBuilder
    var mapImage: some View {
        MapSnapshotView(
            image: viewModel.image,
            location: viewModel.location,
            venue: viewModel.event.venue,
            loadingImage: viewModel.loadingImage
        )
    }
}


extension EventDetailsView {
    func didDismissEditCalanderView(action: EKEventEditViewAction, eventEditModel: EventEditProtocol) {
        guard let eventInfo = eventEditModel as? EventInfo else { return }
        
        switch action {
        case .saved:
            viewModel.route = .alert(.success(title: AlertMessages.editCalendarSuccess.title, message: AlertMessages.editCalendarSuccess.message))
        case .canceled:
            viewModel.resetRoute()
        case .deleted:
            Task {
                do {
                    try await viewModel.repository?.didDeleteFromCalendar(event: eventInfo)
                    await actionsManager.didDeleteFromCalendar(event: eventInfo)
                    viewModel.route = .alert(.success(title: AlertMessages.deleteCalendarSuccess.title, message: AlertMessages.deleteCalendarSuccess.message))
                }
                catch {
                    viewModel.route = .alert(.success(title: AlertMessages.deleteCalendarFail.title, message: AlertMessages.deleteCalendarFail.message))
                }
            }
        @unknown default:
            fatalError("Unknown EKEventEditViewAction")
        }
    }
}
