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
        public var controlParameters:   TSControlrameters

        private var mKeywords:          Dictionary<TSQuery.KeywordType, String>
        private var mLanguage:          TSLanguage?
        private var mLimitDate:         TSLimitedDate?
        private var mTags:              Array<String?>
        private var mCategory:          String?

        public init() {
                controlParameters       = TSControlrameters()

                mKeywords       = [:]
                mLanguage       = nil
                mLimitDate      = nil
                mCategory       = nil
                mTags           = Array(repeating: nil, count: TSControlrameters.MAX_TAG_NUM)
        }

        public func set(type ktype: TSQuery.KeywordType, keyword str: String) {
                mKeywords[ktype] = str
        }

        public func set(language lang: TSLanguage?) {
                mLanguage = lang
        }

        public func set(limitDate ldate: TSLimitedDate?){
                mLimitDate = ldate
        }

        public func set(category cat: String?) async {
                mCategory = cat

                /* update gag menus */
                if let cat = cat {
                        if let sites = await TSSiteTable.shared.selectByCategory(category: cat) {
                                controlParameters.tag0Labels = collectTags(inSites: sites, byCategory: cat, andTags: [])
                        } else {
                                controlParameters.tag0Labels = []
                        }
                        for i in 1..<TSControlrameters.MAX_TAG_NUM {
                                controlParameters.setTagLabels(index: i, labels: [])
                        }
                } else {
                        for i in 0..<TSControlrameters.MAX_TAG_NUM {
                                controlParameters.setTagLabels(index: i, labels: [])
                        }
                }
        }

        public func set(tag tg: String?, at index: Int) async {
                guard 0<=index && index<mTags.count else {
                        NSLog("[Error] invalid tag index: \(index)")
                        return
                }
                mTags[index] = tg

                let nextidx = index + 1
                guard nextidx < TSControlrameters.MAX_TAG_NUM  else {
                        return // needless opeate next tag
                }
                if let _ = tg {
                        if let cat = mCategory {
                                if let sites = await TSSiteTable.shared.selectByCategory(category: cat) {
                                        var curtags: Array<String> = []
                                        for i in 0..<nextidx {
                                                if let tag = mTags[i] {
                                                        curtags.append(tag)
                                                }
                                        }
                                        let labs = collectTags(inSites: sites, byCategory: cat, andTags: curtags)
                                        controlParameters.setTagLabels(index: nextidx, labels: labs)
                                } else {
                                        controlParameters.setTagLabels(index: nextidx, labels: [])
                                }
                        }
                } else {
                        /* clear next index */
                        controlParameters.setTagLabels(index: nextidx, labels: [])
                }
        }

        private func collectTags(inSites sites: Array<TSSite>, byCategory cat: String, andTags srctags: Array<String>) -> Array<String> {
                var result: Set<String> = []
                for site in sites {
                        if site.category == cat {
                                if site.hasAllTags(tags: srctags) {
                                        for tag in site.tags {
                                                result.insert(tag)
                                        }
                                }
                        }
                }
                for tag in srctags {
                        result.remove(tag)
                }
                return Array(result.sorted())
        }

        public func URLToLaunchBrowser() async -> URL? {
                var queries: Array<TSQuery> = []

                /* Add keywords */
                queries.append(contentsOf: keywordQueries())

                /* Add sites */
                if let q = await siteQueries() {
                        queries.append(q)
                }

                /* Add language */
                if let q = languageQuery() {
                        queries.append(q)
                }

                /* Add limit date */
                if let q = limitDateQueries() {
                        queries.append(q)
                }

                /* make quesry string */
                let result = TSQuery.queriesToString(queries: queries)
                NSLog("query string =\(result)")
                return URL(string: result)
        }

        private func queryString(operator op: String, contents cont: String) -> String {
                return "\(op)=\"" + cont + "\""
        }

        private func keywordQueries() -> Array<TSQuery> {
                var result: Array<TSQuery> = []
                for ktype in TSQuery.KeywordType.allCases {
                        if let keyword = mKeywords[ktype] {
                                if !keyword.isEmpty {
                                        result.append(.keyword(ktype, keyword))
                                }
                        }
                }
                return result
        }

        private func siteQueries() async -> TSQuery? {
                guard let cat = mCategory else {
                        return nil      // no sepecific site definition
                }
                guard let sites0 = await TSSiteTable.shared.selectByCategory(category: cat) else {
                        return nil      // no specific sites
                }

                var curtags: Array<String> = []
                for i in 0..<TSControlrameters.MAX_TAG_NUM {
                        if let tag = mTags[i] {
                                curtags.append(tag)
                        }
                }
                var sites1: Array<TSSite> = []
                for site in sites0 {
                        if site.hasAllTags(tags: curtags) {
                                sites1.append(site)
                        }
                }

                if sites1.count == 0 {
                        NSLog("[Error] No sites")
                }

                var URLs: Set<URL> = []
                for site in sites1 {
                        for url in site.URLs {
                                URLs.insert(url)
                        }
                }
                return .sites(Array(URLs))
        }

        private func languageQuery() -> TSQuery? {
                if let targetlang = mLanguage {
                        return .languate(targetlang)
                } else {
                        return nil
                }
        }

        private func limitDateQueries() -> TSQuery? {
                if let ldate = mLimitDate {
                        return .limitedDate(ldate)
                } else {
                        return nil
                }
        }
}
