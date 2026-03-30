//
//  FontPicker.swift
//  lara
//
//  Created by ruter on 27.03.26.
//

import SwiftUI

struct EditorView: View {
    @ObservedObject private var mgr = laramgr.shared
    
    private let path = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    private let modurl: URL

    @State private var mgXML: String = ""
    @State private var status: String?

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        modurl = docs.appendingPathComponent("MobileGestalt.plist")
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView {
                        Text(mgXML)
                            .font(.system(size: 13, design: .monospaced))
                            .lineSpacing(1)
                            .frame(height: 250)
                            .truncationMode(.tail)
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        Text("View")
                    }
                } header: {
                    Text("com.apple.MobileGestalt.plist")
                }
            }
            .navigationTitle("MobileGestalt")
            .alert("Status", isPresented: .constant(status != nil)) {
                Button("OK") { status = nil }
            } message: {
                Text(status ?? "")
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        let fm = FileManager.default
        let sysURL = URL(fileURLWithPath: path)

        if !fm.fileExists(atPath: modurl.path) {
            do {
                try fm.copyItem(at: sysURL, to: modurl)
            } catch {
                status = "failed to copy plist: \(error.localizedDescription)"
                return
            }
        }

        do {
            let data = try Data(contentsOf: modurl)
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            let xmlData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            mgXML = String(data: xmlData, encoding: .utf8) ?? "failed to encode XML"
        } catch {
            status = "failed to load plist: \(error.localizedDescription)"
        }
    }
}
