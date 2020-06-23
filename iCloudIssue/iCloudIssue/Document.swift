//
//  Document.swift
//  iCloudIssue
//
//  Created by Hannes Oud on 23.06.20.
//  Copyright © 2020 IdeasOnCanvas GmbH. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

class Model: ObservableObject {

    @Published var contentString: String = ""
    @Published var changeCount: Int = 0

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

struct LogEntry: Equatable, Identifiable {

    var id: Date { return date }

    let date: Date
    let kind: Kind
    let message: String
    let value: String

    enum Kind: Equatable {
        case read(Read)
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

class Document: NSDocument {

    var model: Model = .init()
    var changeObserver: Any?

    override init() {
        super.init()
        self.changeObserver = self.model.$changeCount.sink { _ in
            self.updateChangeCount(.changeDone)
        }
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(model: self.model)

        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        self.model.writeCount += 1
        self.model.appendLog(.init(date: Date(), kind: .write(.init(string: self.model.contentString)), message: "Write Data", value: self.model.contentString))
        return self.model.contentString.data(using: .utf8) ?? Data()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        self.model.readCount += 1
        let string = String(data: data, encoding: .utf8) ?? ""
        self.model.appendLog(.init(date: Date(), kind: .read(.init(string: string)), message: "Read Data", value: string))
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        self.model.contentString = string
    }
}

extension Document {

    override func presentedItemDidChange() {
        self.model.appendLog(.init(date: Date(), kind: .presentedItemDidChange, message: "Presented Item Did Change", value: self.model.contentString))
        super.presentedItemDidChange()
    }

    override func relinquishPresentedItem(toReader reader: @escaping ((() -> Void)?) -> Void) {
        self.model.appendLog(.init(date: Date(), kind: .relinquishToReader, message: "Relinquish to Reader BEGIN", value: self.model.contentString))
        super.relinquishPresentedItem(toReader: { reaquirer in
            reader({
                reaquirer?()
                self.model.appendLog(.init(date: Date(), kind: .relinquishToWriter, message: "Relinquish to Reader END", value: self.model.contentString))
            })
        })
    }

    override func relinquishPresentedItem(toWriter writer: @escaping ((() -> Void)?) -> Void) {
        self.model.appendLog(.init(date: Date(), kind: .relinquishToWriter, message: "Relinquish to Writer BEGIN", value: self.model.contentString))
        super.relinquishPresentedItem(toWriter: { reaquirer in
            writer({
                reaquirer?()
                self.model.appendLog(.init(date: Date(), kind: .relinquishToWriter, message: "Relinquish to Writer END", value: self.model.contentString))
            })
        })
    }
}

