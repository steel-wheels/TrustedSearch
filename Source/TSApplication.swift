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
                Task { @MainActor in
                        #if os(OSX)
                        let fexts: Array<String> = [ "json" ]
                        MIPanel.openPanel(title: "Hello", type: .file, fileExtensions: fexts, callback: {
                                (urlp: URL?) -> Void in
                                if let url = urlp {
                                        NSLog("URL: \(url.absoluteString)")
                                } else {
                                        NSLog("URL: nil")
                                }
                        })
                        #endif
                }
                NSLog("application.export")
        }

        public static func transition() async {
                NSLog("application.transition")
                await TSSiteTable.shared.save()
        }

        public static func terminate() async {
                NSLog("application.terminate")
                await TSSiteTable.shared.save()
        }
}

