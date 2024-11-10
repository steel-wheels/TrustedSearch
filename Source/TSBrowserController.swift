/*
 * @file TSBrowserCpntrpller.swift
 * @description Define TSBrowserController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

public class TSBrowserController
{
        public var parameters: TSSearchParameters

        private var mEngineURL: URL? = nil

        public init() {
                parameters = TSSearchParameters()
                mEngineURL = URL(string: "https://www.google.com/")
        }

        public func URLToLaunchBrowser() -> URL? {
                return mEngineURL
        }
}
