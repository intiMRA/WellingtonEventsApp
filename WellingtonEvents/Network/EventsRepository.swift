//
//  EventsRepository.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 25/02/2025.
//

import Foundation
import NetworkLayerSPM

protocol EventsRepository: AnyObject, Actor {
    func fetchEvents() async throws -> EventsResponse?
    func report(category report: CategoryReport) async throws
    func saveToFavorites(event: EventInfo) throws
    func retrieveFavorites() throws -> [EventInfo]
    func deleteFromFavorites(event: EventInfo) throws
    func deleteFromFavorites(eventIds: [String]) throws
    func didSaveToCalendar(event: EventInfo) throws
    func retrieveSavedToCalendar() throws -> [EventInfo]
    func didDeleteFromCalendar(event: EventInfo) throws
    func didDeleteFromCalendar(eventIds: [String]) throws
    func canFetchFromCache() -> Bool
}

enum CategoryReportError: Error {
    case failed
}

private struct ReportEnvelope: Encodable {
    let token: String
    let report: CategoryReport
}

private struct ReportResponse: Decodable {
    let ok: Bool
}

private enum ReportURLBuilder: NetworkLayerURLBuilder {
    case categoryReport
    func url() -> URL? {
        URL(string: Secrets.categoryReportURL)
    }
}

extension EventsRepository {
    func report(category report: CategoryReport) async throws {
        let response: ReportResponse = try await NetworkLayer.defaultNetworkLayer.request(
            .init(
                urlBuilder: ReportURLBuilder.categoryReport,
                reqBody: ReportEnvelope(token: Secrets.categoryReportToken, report: report),
                httpMethod: .POST))
        guard response.ok else {
            throw CategoryReportError.failed
        }
    }
}
