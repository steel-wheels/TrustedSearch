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
        public var keyword: String

        public init() {
                keyword = ""
        }

        public func start() {
                NSLog("search start: \(keyword)")
        }
}
