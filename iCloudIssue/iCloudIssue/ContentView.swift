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

    var body: some View {
        VStack {
            TextField("content", text: Binding<String>(get: {
                return self.model.contentString },
                                                       set: { newValue in
                                                        self.model.updateContentStringFromUI(newValue)

            })).padding()
            Text("writeCount: \(model.writeCount)")
            Text("readCount: \(model.readCount)")
            List {
                ForEach(model.logs.reversed()) { log in
                    HStack {
                    Text("\(log.dateString)")
                    Text(log.message + ":")
                        Text(log.value).background(Color.gray.opacity(0.1))
                    }
                }
            }.frame(minHeight: 600)
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
    var dateString: String {
        func format(date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
            return dateFormatter.string(from: date)
        }
        return format(date: self.date)
    }
}
