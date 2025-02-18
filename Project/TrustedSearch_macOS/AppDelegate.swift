//
//  AppDelegate.swift
//  TrustedSearch
//
//  Created by Tomoo Hamada on 2024/11/06.
//

import MultiUIKit
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate
{
        func applicationDidFinishLaunching(_ aNotification: Notification) {
                // Insert code here to initialize your application
        }

        private var mDidSaved = false

        /* see https://hitorigoto.zumuya.com/240802_applicationShouldTerminate */
        func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
                if !mDidSaved {
                        Task {
                                await TSApplication.terminate()
                                mDidSaved = true
                                sender.reply(toApplicationShouldTerminate: true)
                        }
                        return .terminateLater
                } else {
                        return .terminateNow
                }
        }

        func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
                return true
        }

        private var mDidPreferenceWindowOpended  = false
        private var mPreferenceWindow: MIWindow? = nil

        @IBAction func openPreferenceWindow(_ sender: NSMenuItem) {
                if mDidPreferenceWindowOpended {
                        return
                }

                let controller = PreferenceViewController()
                let config = MIWindow.WindowConfig(size: NSSize(width: 640, height: 480), title: "Preference", closeable: true, resizable: false)
                let window = MIWindow.open(viewController: controller, condfig: config)
                window.setCallback(windowWillClose: {
                        () -> Void in
                        self.mDidPreferenceWindowOpended = false
                })
                mPreferenceWindow = window
                mDidPreferenceWindowOpended = true
        }
}

