//
//  DocumentView.swift
//  iCloudIssueiOS
//
//  Created by Hannes Oud on 19.10.20.
//  Copyright © 2020 IdeasOnCanvas GmbH. All rights reserved.
//

import SwiftUI

struct DocumentView: View {
    var document: UIDocument
    var dismiss: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("File Name")
                    .foregroundColor(.secondary)

                Text(document.fileURL.lastPathComponent)
            }

            Button("Done", action: dismiss)
        }
    }
}