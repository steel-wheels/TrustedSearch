/*
 * @file TSPreferenceController.swift
 * @description Define TSPreferenceController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

public class PreferenceViewController: MIViewController
{
        public override func viewDidLoad() {
                super.viewDidLoad()

                let root = MIStack()
                root.axis = .vertical

                /* remove cache button */
                root.addArrangedSubView(allocateRemovePreferenceButton())

                self.view = root
        }

        private func removeCacheFile() {
                let table = TSSiteTable.shared
                Task {
                        await table.reload()
                }
        }

        private func allocateRemovePreferenceButton() -> MIStack {
                let button = MIButton()
                button.title = "Remove Cache file"
                button.setCallback({
                        () -> Void in self.removeCacheFile()
                })
                return makeLabeledStack(label: "Remove", contents: [button])
        }
}

