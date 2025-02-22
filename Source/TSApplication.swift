/*
 * @file TSApplication.swift
 * @description Define TSApplication class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

public class TSApplication
{
        /* must be executed in main thread */
        public static func export() {
                //NSLog("application.export")
                Task { @MainActor in
                        #if os(OSX)
                        let home = FileManager.default.homeDirectoryForCurrentUser
                        MIPanel.savePanel(title: "Save Site Table", outputDirectory: home, callback: {
                                (urlp: URL?) -> Void in
                                if let url = urlp {
                                        export(to: url)
                                }
                        })
                        #endif
                }
        }

        public static func transition() async {
                //NSLog("application.transition")
                //await TSSiteTable.shared.save()
        }

        public static func terminate() async {
                //NSLog("application.terminate")
                //await TSSiteTable.shared.save()
        }

        private static func export(to url: URL) {
                //NSLog("application.export \(url.absoluteString)")
                Task { await TSSiteTable.shared.save(to: url) }
        }
}

