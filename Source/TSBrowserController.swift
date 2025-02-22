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
        private var mControlParameters: TSControlrameters

        public init(controlParameter param: TSControlrameters) {
                mControlParameters = param
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
                //NSLog("query string =\(result)")
                return URL(string: result)
        }

        private func keywordQueries() -> Array<TSQuery> {
                var result: Array<TSQuery> = []
                if !mControlParameters.allWordsKeyword.isEmpty {
                        result.append(.keyword(.allWords, mControlParameters.allWordsKeyword))
                }
                if !mControlParameters.entireTextKeyword.isEmpty {
                        result.append(.keyword(.entireText, mControlParameters.entireTextKeyword))
                }
                if !mControlParameters.someWordsKeyword.isEmpty {
                        result.append(.keyword(.someWords, mControlParameters.someWordsKeyword))
                }
                if !mControlParameters.notWordsKeyword.isEmpty {
                        result.append(.keyword(.notWords, mControlParameters.notWordsKeyword))
                }
                if result.count == 0 {
                        NSLog("[Error] No keyword at \(#function)")
                }
                return result
        }

        private func languageQuery() -> TSQuery? {
                if let targetlang = mControlParameters.language {
                        return .languate(targetlang)
                } else {
                        return nil
                }
        }

        private func limitDateQueries() -> TSQuery? {
                if let ldate = mControlParameters.limitDate {
                        return .limitedDate(ldate)
                } else {
                        return nil
                }
        }

        private func siteQueries() async -> TSQuery? {
                let urls = await siteURLs()
                if urls.count > 0 {
                        return .sites(urls)
                } else {
                        return nil
                }
        }

        public func siteURLs() async -> Array<URL> {
                var tags: Array<String> = []
                if let tag0 = mControlParameters.tag0Label { tags.append(tag0) }
                if let tag1 = mControlParameters.tag1Label { tags.append(tag1) }
                if let tag2 = mControlParameters.tag2Label { tags.append(tag2) }

                /* if category and all tags are not defined, return no site  */
                if mControlParameters.category == nil && tags.isEmpty {
                        return []
                }

                let sites = await TSSiteTable.shared.collectSites(category: mControlParameters.category, tags: tags)

                var URLs: Set<URL> = []
                for site in sites {
                        for url in site.URLs {
                                URLs.insert(url)
                        }
                }
                return Array(URLs)
        }
}
