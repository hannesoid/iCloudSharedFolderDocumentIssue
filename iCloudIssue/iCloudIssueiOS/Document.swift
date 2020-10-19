//
//  Document.swift
//  iCloudIssueiOS
//
//  Created by Hannes Oud on 19.10.20.
//  Copyright © 2020 IdeasOnCanvas GmbH. All rights reserved.
//

import UIKit

class Document: UIDocument {

    var model: Model = .init()
    var changeObserver: Any?

    override init(fileURL url: URL) {
        super.init(fileURL: url)
        self.changeObserver = self.model.$changeCount.sink { _ in
            self.updateChangeCount(.done)
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        self.model.writeCount += 1
        self.model.appendLog(.init(date: Date(), kind: .write(.init(string: self.model.contentString)), message: "Write Data", value: self.model.contentString, lastDocumentModifiedDate: self.fileModificationDate))
        return self.model.contentString.data(using: .utf8) ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        let data = contents as! Data
        self.model.readCount += 1
        let string = String(data: data, encoding: .utf8) ?? ""
        self.model.appendLog(.init(date: Date(), kind: .read, message: "Read Data", value: string))
        self.model.contentString = string
    }
}

