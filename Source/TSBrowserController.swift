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

        private var mEngineURL: URL?

        public init() {
                parameters      = TSSearchParameters()
                mEngineURL      = URL(string: "https://www.google.com/search?")
        }

        public func append(site path: String) -> NSError? {
                if let url = URL(string: path) {
                        self.parameters.sites.append(url)
                        return nil
                } else {
                        let err = MIError.error(errorCode: .urlError, message: "Invalid URL: \(path)")
                        return err
                }
        }

        public func URLToLaunchBrowser() -> URL? {
                guard let base = mEngineURL else {
                        return nil
                }
                var result = base.absoluteString
                for site in self.parameters.sites {
                        result += "q=site:\(site.absoluteString) "
                }
                result += self.parameters.keyword
                NSLog("result=\"\(result)\"")
                return URL(string: result)
        }
}
