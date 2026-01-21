//
//  InstallScripts.swift
//  iOSpice
//
//  Created by Devin R Cohen on 1/18/26.
//

import Foundation

    // Files you have already added to Copy Bundle Resources
    // (top-level resources in the .app bundle).
private let scriptNames: [String] = [
    "spinit",
    "devload",
    "devaxis",
    "setplot",
    "spectrum",
    "ciderinit"
    // Add "tclspinit" if you have it in the bundle:
    // "tclspinit"
]

/// Copies ngspice scripts from the app bundle into a writable location with no spaces
/// and returns the destination directory path. Safe to call multiple times.
func installIfNeeded() -> String? {
    let fm = FileManager.default

    // Use Caches to avoid spaces in the path (Application Support has a space).
    guard let caches = try? fm.url(for: .cachesDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil,
                                   create: true) else {
        print("NgspiceScripts: failed to locate cachesDirectory")
        return nil
    }

    let dstDir = caches.appendingPathComponent("ngspice_scripts", isDirectory: true)

    do {
        if !fm.fileExists(atPath: dstDir.path) {
            try fm.createDirectory(at: dstDir, withIntermediateDirectories: true)
        }

        for name in scriptNames {
            guard let src = Bundle.main.url(forResource: name, withExtension: nil) else {
                print("NgspiceScripts: missing resource in bundle:", name)
                return nil
            }

            let dst = dstDir.appendingPathComponent(name, isDirectory: false)

            // Overwrite if needed (useful during development when scripts change).
            if fm.fileExists(atPath: dst.path) {
                try fm.removeItem(at: dst)
            }

            try fm.copyItem(at: src, to: dst)
        }

        // Final sanity check: spinit must exist.
        let spinitPath = dstDir.appendingPathComponent("spinit").path
        guard fm.fileExists(atPath: spinitPath) else {
            print("NgspiceScripts: spinit missing after install:", spinitPath)
            return nil
        }

        return dstDir.path

    } catch {
        print("NgspiceScripts: install error:", error)
        return nil
    }
}

/// Debug helper: prints where the scripts are in the bundle and where they are staged.
func debugScripts() {
    let fm = FileManager.default
    print("NgspiceScripts: resourceURL:", Bundle.main.resourceURL?.path ?? "nil")

    for name in scriptNames {
        let url = Bundle.main.url(forResource: name, withExtension: nil)
        print("NgspiceScripts: bundle \(name):", url?.path ?? "nil",
              "exists:", url.map { fm.fileExists(atPath: $0.path) } ?? false)
    }

    if let installed = installIfNeeded() {
        print("NgspiceScripts: installedDir:", installed,
              "spinitExists:", fm.fileExists(atPath: (installed as NSString).appendingPathComponent("spinit")))
    } else {
        print("NgspiceScripts: installIfNeeded returned nil")
    }
}

