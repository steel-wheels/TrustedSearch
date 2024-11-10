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

        public init() {
                parameters = TSSearchParameters()
        }

        public func start() {
                NSLog("search start: \(parameters.keyword)")
        }
}
