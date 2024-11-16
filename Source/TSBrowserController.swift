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
        public var parameters:          TSSearchParameters
        private var mEngineURL:         URL?

        public init() {
                parameters              = TSSearchParameters()
                mEngineURL              = URL(string: "https://www.google.com/search?")
        }

        public func set(language lang: TSLanguage) {
                parameters.language = lang
        }

        public func set(sites sts: Array<URL>) {
                self.parameters.sites = sts
        }

        public func URLToLaunchBrowser() -> URL? {
                guard let base = mEngineURL else {
                        return nil
                }
                var queries: Array<String> = []

                /* Add keywords */
                if let query = keywordQueries() {
                        queries.append(query)
                }

                /* Add sites */
                if let siteq = siteQueries() {
                        queries.append(siteq)
                }

                /* Add language */
                if let langq = languageQueries() {
                        queries.append(langq)
                }

                /* make quesry string */
                let qstr   = queries.joined(separator: "&")
                let result = base.absoluteString + qstr
                NSLog("result=\(result)")
                return URL(string: result)
        }

        private func queryString(operator op: String, contents cont: String) -> String {
                return "\(op)=\"" + cont + "\""
        }

        private func keywordQueries() -> String? {
                return queryString(operator: "q", contents: self.parameters.keyword)
        }

        private func siteQueries() -> String?{
                guard self.parameters.sites.count > 0 else {
                        return nil
                }
                var result: String = ""
                var prefix: String = ""
                for site in self.parameters.sites {
                        result += prefix + "site:" + site.absoluteString
                        prefix = " OR "
                }
                return queryString(operator: "q", contents: result)
        }

        private func languageQueries() -> String? {
                let targetlang = self.parameters.language
                if targetlang != .all {
                        return "lr=lang_\(targetlang.query)"
                } else {
                        return nil
                }
        }
}
