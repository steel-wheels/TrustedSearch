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

        private var mBrowserController = TSBrowserController()

        public func setRootView(_ root: MIStack) {
                mRootView = root
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                /* make contents */
                if let root = mRootView {
                        makeContents(rootView: root)
                }
        }

        private func makeContents(rootView root: MIStack) {
                let keywordfield = MITextField()
                keywordfield.stringValue = "Keyword field"
                root.addArrangedSubView(keywordfield)
                mKeywordField = keywordfield

                let searchbutton = MIButton()
                searchbutton.title = "Search"
                searchbutton.setCallback {
                        () -> Void in self.searchButtonPressed()
                }
                root.addArrangedSubView(searchbutton)
        }

        private func searchButtonPressed() {
                if let field = mKeywordField {
                        mBrowserController.keyword = field.stringValue
                }
                mBrowserController.start()
        }
}

