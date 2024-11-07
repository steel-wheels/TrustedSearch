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

        public func setRootView(_ root: MIStack) {
                mRootView = root
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                /* make contents */
                if let root = mRootView {
                        let keywordfield = MITextField()
                        keywordfield.stringValue = "Keyword field"
                        root.addArrangedSubView(keywordfield)
                        mKeywordField = keywordfield
                }
        }
}

