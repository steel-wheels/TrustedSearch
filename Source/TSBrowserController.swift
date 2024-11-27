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
        public static let MAX_TAG_NUM = TSControlrameters.MAX_TAG_NUM

        public var siteTable:           TSSiteTable
        public var controlParameters:   TSControlrameters

        private var mKeyword:           String
        private var mLanguage:          TSLanguage?
        private var mLimitDate:         TSLimitedDate?
        private var mTags:              Array<String?>
        private var mCategory:          String?

        private var mEngineURL:         URL?

        public init() {
                siteTable               = TSSiteTable()
                controlParameters       = TSControlrameters()
                mEngineURL              = URL(string: "https://www.google.com/search?")

                mKeyword        = ""
                mLanguage       = nil
                mLimitDate      = nil
                mCategory       = nil
                mTags           = Array(repeating: nil, count: TSBrowserController.MAX_TAG_NUM)
        }

        public func set(keyword str: String) {
                mKeyword = str
        }

        public func set(language lang: TSLanguage?) {
                mLanguage = lang
        }

        public func set(limitDate ldate: TSLimitedDate?){
                mLimitDate = ldate
        }

        public func set(category cat: String?){
                mCategory = cat

                /* set tag0 menu */
                if let cat = cat {
                        if let sites = siteTable.selectByCategory(category: cat) {
                                controlParameters.tag0Labels = collectTags(inSites: sites, byCategory: cat)
                        } else {
                                controlParameters.tag0Labels = []
                        }
                } else {
                        controlParameters.tag0Labels = []
                }
        }

        public func set(tag tg: String?, at index: Int){
                if 0<=index && index<mTags.count {
                        mTags[index] = tg
                } else {
                        NSLog("[Error] invalid tag index: \(index)")
                }
        }

        private func collectTags(inSites sites: Array<TSSite>, byCategory cat: String) -> Array<String> {
                var result: Set<String> = []
                for site in sites {
                        if site.category == cat {
                                for tag in site.tags {
                                        result.insert(tag)
                                }
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
                return queryString(operator: "q", contents: mKeyword)
        }

        private func siteQueries() -> String?{
                guard let cat = mCategory else {
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
                if let targetlang = mLanguage {
                        return "lr=lang_\(targetlang.query)"
                } else {
                        return nil
                }
        }

        private func limitDateQueries() -> String? {
                guard let limitdate = mLimitDate else {
                        return nil
                }
                let result: String?
                let calendar = Calendar.current
                let today    = Date()
                switch limitdate {
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
