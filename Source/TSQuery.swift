/*
 * @file TSQuery.swift
 * @description Define TSQuery class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Foundation

public enum TSQuery {
        case keyword(String)
        case sites(Array<URL>)
        case languate(TSLanguage)
        case limitedDate(TSLimitedDate)

        public func toString() -> String {
                let result: String
                switch self {
                case .keyword(let str):
                        result = self.keywordToString(keyword: str)
                case .sites(let sites):
                        result = self.sitesToString(URLs: sites)
                case .languate(let lang):
                        result = self.languageToString(language: lang)
                case .limitedDate(let ldate):
                        result = self.limitDateToString(limitDate: ldate)
                }
                return result
        }

        private func keywordToString(keyword: String) -> String {
                return queryString(contents: "\"" + keyword + "\"")
        }

        private func sitesToString(URLs: Array<URL>) -> String {
                let result: String
                switch URLs.count {
                case 0: return ""
                case 1: result = URLs[0].absoluteString
                default: /* count > 2*/
                        var str    = "\""
                        var prefix = ""
                        for url in URLs {
                                str += prefix + url.absoluteString
                                prefix = " OR "
                        }
                        str += "\""
                        result = str
                }
                return queryString(contents: "site:" + result)
        }

        private func languageToString(language lang: TSLanguage) -> String {
                return "lr=lang_\(lang.query)"
        }

        private func limitDateToString(limitDate ldate: TSLimitedDate) -> String {
                let result: String
                let calendar = Calendar.current
                let today    = Date()
                switch ldate {
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

        private func dateToString(date dt: Date?, calendar cal: Calendar) -> String {
                let result: String
                if let date = dt {
                        let year  = cal.component(.year,  from: date)
                        let month = cal.component(.month, from: date)
                        let day   = cal.component(.day,   from: date)
                        result = "after:\"\(year)/\(month)/\(day)\""
                } else {
                        result = ""
                }
                return result
        }

        private func queryString(contents cont: String) -> String {
                return "q=\(cont)"
        }

        public static func queriesToString(queries: Array<TSQuery>) -> String {
                let engineurl =  "https://www.google.com/search?"
                let qstrs = queries.map{ $0.toString() }
                return engineurl + qstrs.joined(separator: "&")
        }
}
