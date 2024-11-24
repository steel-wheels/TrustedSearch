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
        public static let MAX_TAG_NUM = TSSearchParameters.MAX_TAG_NUM

        public var siteTable:           TSSiteTable
        public var parameters:          TSSearchParameters

        private var mEngineURL:         URL?
        private var mTagLabels:         Array<Array<String>>

        public init() {
                siteTable       = TSSiteTable()
                parameters      = TSSearchParameters()
                mEngineURL      = URL(string: "https://www.google.com/search?")

                mTagLabels = []
                for _ in 0..<TSBrowserController.MAX_TAG_NUM {
                        mTagLabels.append([])
                }
        }

        public func set(keyword str: String) {
                if self.parameters.keyword != str {
                        parameters.keyword = str
                }
        }

        public func set(language lang: TSLanguage?) {
                if self.parameters.language != lang {
                        parameters.language = lang
                }
        }

        public func set(limitDate ldate: TSLimitedDate?){
                if self.parameters.limitDate != ldate {
                        self.parameters.limitDate = ldate
                }
        }

        public func set(category cat: String?){
                if self.parameters.category != cat {
                        collectTagLabels(category: cat)
                        self.parameters.category = cat  // send notification
                }
        }

        public func set(level lvl: Int, tag t: String?) {
                NSLog("set tag \(String(describing: t)) for level \(lvl)")
        }

        public func tagLabels(level lvl: Int) -> Array<String>? {
                if 0<=lvl && lvl < mTagLabels.count {
                        if mTagLabels[lvl].count > 0 {
                                return mTagLabels[lvl]
                        } else {
                                return nil
                        }
                } else {
                        return nil
                }
        }

        private func collectTagLabels(category cat: String?) {
                /* Update tag 0 */
                if let str = cat {
                        if let sites = siteTable.selectByCategory(category: str) {
                                mTagLabels[0] = collectTags(in: sites)
                        } else {
                                mTagLabels[0] = []
                        }
                } else {
                        mTagLabels[0] = []
                }
        }

        private func collectTags(in sites: Array<TSSite>) -> Array<String> {
                var result: Set<String> = []
                for site in sites {
                        for tag in site.tags {
                                result.insert(tag)
                        }
                }
                return Array(result.sorted())
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
                guard let cat = self.parameters.category else {
                        return nil      // no sepecific site definition
                }
                guard let sites = siteTable.selectByCategory(category: cat) else {
                        return nil      // no specific sites

                }

                var URLs: Set<URL> = []
                for site in sites {
                        for url in site.URLs {
                                URLs.insert(url)
                        }
                }

                var result: String = ""
                var prefix: String = ""
                for url in URLs {
                        result += prefix + "site:" + url.absoluteString
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
