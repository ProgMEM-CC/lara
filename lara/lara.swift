//
//  lara.swift
//  lara
//
//  Created by ruter on 23.03.26.
//

import SwiftUI

@main
struct lara: App {
    @Environment(\.scenePhase) private var scenePhase
    @State var showunsupported: Bool = false
    private let keepalivekey = "keepalive"

    init() {
        if isunsupported() {
            showunsupported = true
        }
        
        if UserDefaults.standard.bool(forKey: keepalivekey) {
            if !kaenabled {
                toggleka()
            }
        }
        
        globallogger.capture()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("lara", systemImage: "ant.fill")
                    }

                LogsView(logger: globallogger)
                    .tabItem {
                        Label("Logs", systemImage: "text.document.fill")
                    }
            }
            .onAppear {
                init_offsets()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .background {
                    globallogger.stopcapture()
                } else if phase == .active {
                    globallogger.capture()
                }
            }
            .alert(isPresented: $showunsupported) {
                .init(title: Text("Unsupported"), message: Text("Lara is currently not supported on this device. Possible reasons:\nYour device is iOS newer than ios 26.0.1\nYour device is older than iOS 17.0\nYour device has MIE\n\nIt probably wont work."))
            }
        }
    }
}
