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

        private func makeLabeledStack(label labstr: String, contents conts: Array<MIInterfaceView>) -> MIStack {
                let newbox = MIStack()
                newbox.axis = .horizontal
                let label = MILabel()
                label.title = labstr
                newbox.addArrangedSubView(label)
                for cont in conts {
                        newbox.addArrangedSubView(cont)
                }
                return newbox
        }
}

