//
//  FontPicker.swift
//  lara
//
//  Created by ruter on 27.03.26.
//

import SwiftUI
import Darwin

struct AppsView: View {
    @ObservedObject var mgr: laramgr
    
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "Unknown App"
    }
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    var appIcon: UIImage {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let last = files.last,
           let image = UIImage(named: last) {
            return image
        }
        
        return UIImage(named: "unknown") ?? UIImage()
    }
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Image(uiImage: appIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading) {
                        Text(appName)
                            .font(.headline)
                        
                        Text("Version \(appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                }
            } header: {
                Text("Apps")
            } footer: {
                Text("Currently only shows lara, if you know how to enumerate sideloaded apps on the device (excluding like idevice), let me know via a GitHub issue or something.")
            }
            
            Section {
                Button {
                    let bundlePath = Bundle.main.bundlePath
                    let key = "com.apple.installd.validatedByFreeProfile"
                    var value: [UInt8] = [0, 0, 0]
                    let rc = setxattr(bundlePath, key, &value, value.count, 0, 0)
                    if rc == 0 {
                        mgr.logmsg("set \(key) on app bundle")
                    } else {
                        mgr.logmsg("failed to set \(key): \(String(cString: strerror(errno)))")
                    }
                } label: {
                    Text("Bypass 3 App Limit")
                }
            } footer: {
                Text("This will set the validatedByFreeProfile xattr on the app bundle. As currently only lara will be listed, that means only one app slot will be freed.")
            }
        }
        .navigationTitle("Sideloaded Apps")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reload") {
                }
            }
        }
    }
}
