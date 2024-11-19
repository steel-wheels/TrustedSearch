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

        public func set(limitDate ldate: TSLimitedDate){
                self.parameters.limitDate = ldate
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
                if let query = siteQueries() {
                        queries.append(query)
                }

                /* Add language */
                if let query = languageQueries() {
                        queries.append(query)
                }

                /* Add limit date */
                if let query = limitDateQueries() {
                        queries.append(query)
                }

                /* make quesry string */
                let qstr   = queries.joined(separator: "&")
                let result = base.absoluteString + qstr
                NSLog("query string =\(result)")
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
                if let targetlang = self.parameters.language {
                        return "lr=lang_\(targetlang.query)"
                } else {
                        return nil
                }
        }

        private func limitDateQueries() -> String? {
                let result: String?
                let calendar = Calendar.current
                let today    = Date()
                switch self.parameters.limitDate {
                case .none:
                        result = nil
                case .before1day:
                        let targ = calendar.date(byAdding: .day, value: -1, to: today)
                        result = dateToString(date: targ, calendar: calendar)
                case .before1month:
                        let targ = calendar.date(byAdding: .month, value: -1, to: today)
                        result = dateToString(date: targ, calendar: calendar)
                case .before1year:
                        let targ = calendar.date(byAdding: .year, value: -1, to: today)
                        result = dateToString(date: targ, calendar: calendar)
                }
                return result
        }

        private func dateToString(date dt: Date?, calendar cal: Calendar) -> String? {
                if let date = dt {
                        let year  = cal.component(.year,  from: date)
                        let month = cal.component(.month, from: date)
                        let day   = cal.component(.day,   from: date)
                        let str   = "after:\"\(year)/\(month)/\(day)\""
                        return str
                } else {
                        return nil
                }
        }
}
