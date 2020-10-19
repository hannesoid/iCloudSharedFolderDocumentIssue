//
//  ContentView.swift
//  iCloudIssue
//
//  Created by Hannes Oud on 23.06.20.
//  Copyright © 2020 IdeasOnCanvas GmbH. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var model: Model
    @State var filterPhrase: String = ""
    var filteredSortedLogs: [LogEntry] {
        model.logs
        .filter({ $0.containsPhrase(self.filterPhrase)})
        .sorted(by: { $0.date > $1.date })
    }
    var contentStringBinding: Binding<String> {
        return Binding<String>(get: { self.model.contentString }, set: { newValue in self.model.updateContentStringFromUI(newValue) })
    }

    var body: some View {
        VStack {
            TextField("content", text: contentStringBinding).padding()
            Text("writeCount: \(model.writeCount)")
            Text("readCount: \(model.readCount)")
            List {
                ForEach(filteredSortedLogs) { log in
                    HStack {
                        Text("\(log.dateString)")
                        Text(log.message + ":")
                        Text(log.value).background(Color.gray.opacity(0.1))
                        Spacer()
                        Text(log.fileModificationDateString)
                    }

                }
            }.frame(minWidth: 700, minHeight: 700)
            TextField("Filter", text: $filterPhrase).padding()
        }.padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView(model: .init())
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
