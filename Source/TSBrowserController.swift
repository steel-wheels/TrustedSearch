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
                var queries: Array<String> = []
                /* Add sites */
                for site in self.parameters.sites {
                        queries.append("q=site:\(site.absoluteString)")
                }
                /* Add keywords */
                queries.append("q=\"\(self.parameters.keyword)\"")
                /* make quesry string */
                let qstr   = queries.joined(separator: ",")
                let result = base.absoluteString + qstr
                NSLog("result=\(result)")
                return URL(string: result)
        }
}
