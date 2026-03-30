//
//  FontPicker.swift
//  lara
//
//  Created by ruter on 28.03.26.
//

import SwiftUI
import CoreText
import UIKit
import UniformTypeIdentifiers

struct importedfont: Identifiable, Codable {
    var id: String { name }
    let name: String
    let path: String
}

struct FontPicker: View {
    @ObservedObject var mgr: laramgr
    @State private var showimporter = false
    @State private var customfonts: [importedfont] = load()

    private func applyfont(_ resource: String, label: String) {
        let success = mgr.vfsoverwrite(target: laramgr.fontpath, withBundledFont: resource)
        success ? mgr.logmsg("font changed to \(label)") : mgr.logmsg("failed to change font")
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        applyfont("SFUI", label: "SFUI")
                    } label: {
                        Text("SFUI (Normal Font)")
                            .font(viewfont(resource: "SFUI", size: 17))
                    }
                    
                    Button {
                        applyfont("Comic Sans MS", label: "Comic Sans MS")
                    } label: {
                        Text("Comic Sans MS")
                            .font(viewfont(resource: "Comic Sans MS", size: 17))
                    }

                    Button {
                        applyfont("Chococooky", label: "Chococooky")
                    } label: {
                        Text("Chococooky")
                            .font(viewfont(resource: "Chococooky", size: 17))
                    }

                    Button {
                        applyfont("DejaVuSansMono", label: "DejaVuSansMono")
                    } label: {
                        Text("DejaVu Sans Mono")
                            .font(viewfont(resource: "DejaVuSansMono", size: 17))
                    }

                    Button {
                        applyfont("DejaVuSansCondensed", label: "DejaVuSansCondensed")
                    } label: {
                        Text("DejaVu Sans Condensed")
                            .font(viewfont(resource: "DejaVuSansCondensed", size: 17))
                    }

                    Button {
                        applyfont("DejaVuSerif", label: "DejaVuSerif")
                    } label: {
                        Text("DejaVu Serif")
                            .font(viewfont(resource: "DejaVuSerif", size: 17))
                    }

                    Button {
                        applyfont("FiraSans-Regular", label: "FiraSans")
                    } label: {
                        Text("Fira Sans")
                            .font(viewfont(resource: "FiraSans-Regular", size: 17))
                    }

                    Button {
                        applyfont("Go-Mono", label: "Go-Mono")
                    } label: {
                        Text("Go Mono")
                            .font(viewfont(resource: "Go-Mono", size: 17))
                    }

                    Button {
                        applyfont("Go-Regular", label: "Go-Regular")
                    } label: {
                        Text("Go Regular")
                            .font(viewfont(resource: "Go-Regular", size: 17))
                    }

                    Button {
                        applyfont("segoeui", label: "Segoe UI")
                    } label: {
                        Text("Segoe UI")
                            .font(viewfont(resource: "segoeui", size: 17))
                    }
                    
                    Button {
                        applyfont("QuickSand", label: "QuickSand")
                    } label: {
                        Text("QuickSand")
                            .font(viewfont(resource: "QuickSand", size: 17))
                    }
                } header: {
                    Text("Fonts")
                } footer: {
                    Text("Fira Sans currently broken. If you want to fix it, create a pull request or something.")
                }
                
                Section {
                    if !customfonts.isEmpty {
                        ForEach(customfonts) { font in
                            Button {
                                if !FileManager.default.fileExists(atPath: font.path) {
                                    mgr.logmsg("custom font missing: \(font.name)")
                                    customfonts.removeAll { $0.name == font.name }
                                    save(customfonts)
                                    return
                                }
                                let success = mgr.vfsoverwritefromlocalpath(target: laramgr.fontpath, source: font.path)
                                success ? mgr.logmsg("font changed to \(font.name)") : mgr.logmsg("failed to change font")
                            } label: {
                                Text(font.name)
                                    .font(viewfontfile(path: font.path, size: 17))
                            }
                        }
                    }
                    
                    Button("Import Font") {
                        showimporter = true
                    }
                } header: {
                    Text("Custom Fonts")
                } footer: {
                    Text("Some custom fonts will not work for app icons and other stuff, some will not work at all. If you want them to work, patch the normal SFUI.ttf to use your fonts glyph symbols and use that as your custom font.")
                }
                
                Section {
                    Text(globallogger.logs.last ?? "No logs yet")
                        .font(.system(size: 13, design: .monospaced))
                    
                    if #unavailable(iOS 18.2) {
                        Button("Respring") {
                            mgr.respring()
                        }
                    }
                }
            }
            .navigationTitle("Font Overwrite")
            .fileImporter(
                isPresented: $showimporter,
                allowedContentTypes: [.font],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    importfont(url)
                }
            }
        }
    }
    
    func importfont(_ url: URL) {
        let fm = FileManager.default
        
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Custom")

        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)

        let dest = dir.appendingPathComponent(url.lastPathComponent)

        do {
            if !fm.fileExists(atPath: dest.path) {
                try fm.copyItem(at: url, to: dest)
            }

            let name = url.deletingPathExtension().lastPathComponent
            let font = importedfont(name: name, path: dest.path)

            if !customfonts.contains(where: {$0.name == name}) {
                customfonts.append(font)
                save(customfonts)
            }

        } catch {
            print("font import failed:", error)
        }
    }
}

private func viewfont(resource: String, size: CGFloat) -> Font {
    if let url = Bundle.main.url(forResource: resource, withExtension: "ttf", subdirectory: "fonts")
        ?? Bundle.main.url(forResource: resource, withExtension: "ttf", subdirectory: "Fonts")
        ?? Bundle.main.url(forResource: resource, withExtension: "ttf") {
        if let data = try? Data(contentsOf: url) as CFData,
           let provider = CGDataProvider(data: data),
           let cgFont = CGFont(provider) {
            let ctFont = CTFontCreateWithGraphicsFont(cgFont, size, nil, nil)
            let uiFont = ctFont as UIFont
            return Font(uiFont)
        }
    }
    return .system(size: size)
}

private func viewfontfile(path: String, size: CGFloat) -> Font {
    let url = URL(fileURLWithPath: path)

    if let data = try? Data(contentsOf: url) as CFData,
       let provider = CGDataProvider(data: data),
       let cgFont = CGFont(provider) {

        let ctFont = CTFontCreateWithGraphicsFont(cgFont, size, nil, nil)
        let uiFont = ctFont as UIFont
        return Font(uiFont)
    }

    return .system(size: size)
}

private let fontkey = "customfonts"

private func load() -> [importedfont] {
    guard let data = UserDefaults.standard.data(forKey: fontkey),
          let fonts = try? JSONDecoder().decode([importedfont].self, from: data)
    else { return [] }
    let fm = FileManager.default
    let filtered = fonts.filter { fm.fileExists(atPath: $0.path) }
    if filtered.count != fonts.count {
        save(filtered)
    }
    return filtered
}

private func save(_ fonts: [importedfont]) {
    if let data = try? JSONEncoder().encode(fonts) {
        UserDefaults.standard.set(data, forKey: fontkey)
    }
}
