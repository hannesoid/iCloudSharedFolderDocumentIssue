//
//  Model.swift
//  iCloudIssue
//
//  Created by Hannes Oud on 19.10.20.
//  Copyright © 2020 IdeasOnCanvas GmbH. All rights reserved.
//

import SwiftUI
import Combine

/// The model which has the contentString, a changeCount, and some logging.
/// Used as viewModel for ContentView
class Model: ObservableObject {

    /// The actual data, which shall also be persisted as document
    @Published var contentString: String = ""

    /// changecount, to be increased on each interactive edit
    @Published var changeCount: Int = 0

    // logging

    @Published var readCount: Int = 0
    @Published var writeCount: Int = 0
    @Published var logs: [LogEntry] = []

    func updateContentStringFromUI(_ newValue: String) {
        self.logs.append(.init(date: Date(), kind: .textfield(newValue), message: "Typed", value: newValue))
        self.contentString = newValue
        self.changeCount += 1
    }

    func appendLog(_ logEntry: LogEntry) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.logs.append(logEntry)
            }
        } else {
            self.logs.append(logEntry)
        }
    }
}

/// A log entry which can be shown and filtered in the UI
struct LogEntry: Equatable, Identifiable {

    var id: Date { return date }

    let date: Date
    let kind: Kind
    let message: String
    let value: String
    var lastDocumentModifiedDate: Date?

    enum Kind: Equatable {
        case read
        case revert
        case relinquishToReader
        case relinquishToWriter
        case write(Write)
        case textfield(String)
        case other
        case presentedItemDidChange
    }
    struct Read: Equatable {
        let string: String
    }
    struct Write: Equatable {
        let string: String
    }
}

extension LogEntry {
    
    func format(date: Date?) -> String {
        guard let date = date else { return "-" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        return dateFormatter.string(from: date)
    }

    var dateString: String {
        return format(date: self.date)
    }

    var fileModificationDateString: String {
        return format(date: self.lastDocumentModifiedDate)
    }

    func containsPhrase(_ phrase: String) -> Bool {
        if phrase.isEmpty { return true }

        return self.message.contains(phrase) || self.value.contains(phrase) || self.dateString.contains(phrase)
    }
}
