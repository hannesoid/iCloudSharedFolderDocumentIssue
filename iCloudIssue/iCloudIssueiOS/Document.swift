//
//  Document.swift
//  iCloudIssueiOS
//
//  Created by Hannes Oud on 19.10.20.
//  Copyright © 2020 IdeasOnCanvas GmbH. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

