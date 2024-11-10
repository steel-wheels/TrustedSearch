/*
 * @file TSViewCpntrpller.swift
 * @description Define TSViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSViewController: MIViewController
{
        private var mRootView:          MIStack? = nil
        private var mKeywordField:      MITextField? = nil
        private var mSearchButton:      MIButton? =  nil

        private var mBrowserController  = TSBrowserController()

        public func setRootView(_ root: MIStack) {
                mRootView = root
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                /* make contents */
                if let root = mRootView {
                        makeContents(rootView: root)
                }

                /* repeat tracking */
                self.tracking()
        }

        private func makeContents(rootView root: MIStack) {
                let keywordfield = MITextField()
                keywordfield.stringValue = "Keyword field"
                root.addArrangedSubView(keywordfield)
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.parameters.keyword = str
                })
                mKeywordField = keywordfield

                let searchbutton = MIButton()
                searchbutton.title = "Search"
                searchbutton.setCallback {
                        () -> Void in self.searchButtonPressed()
                }
                root.addArrangedSubView(searchbutton)
                mSearchButton = searchbutton
        }

        /* this operation is called in main thread*/
        private func tracking() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        self.keywordIsUpdated(self.mBrowserController.parameters.keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.tracking()
                        }
                }
        }

        private func keywordIsUpdated(_ str: String) {
                if let button = mSearchButton {
                        button.isEnabled = !str.isEmpty
                }
        }

        private func searchButtonPressed() {
                mBrowserController.start()
        }
}

