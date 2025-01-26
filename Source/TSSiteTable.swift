/*
 * @file TSSiteTable.swift
 * @description Define TSSiteTable class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSSite
{
        public var category:    String
        public var tags:        Array<String>
        public var URLs:        Array<URL>

        public init(category cat: String, tags tgs: Array<String>, URLs urls: Array<URL>) {
                self.category = cat
                self.tags     = tgs
                self.URLs     = urls
        }

        public func hasTag(tag src: String) -> Bool {
                for tag in tags {
                        if tag == src {
                                return true
                        }
                }
                return false
        }

        public func hasTags(tags srcs: Array<String>) -> Bool {
                for src in srcs {
                        if !hasTag(tag: src) {
                                return false
                        }
                }
                return true
        }
}

@globalActor public actor TSSiteTable
{
        private static let SiteFileName = "sites.json"

        public static let shared = TSSiteTable()

        private var mSiteTable:         Dictionary<String, Array<TSSite>>
        private var mAllCategoories:    Set<String>
        private var mCategorizedTags:   Dictionary<String, Set<String>>

        private init() {
                mSiteTable              = [:]
                mAllCategoories         = []
                mCategorizedTags        = [:]
        }

        public var allCategories: Set<String> { get {
                return mAllCategoories
        }}

        public func categorizedTags(inCategory cat: String) -> Set<String> {
                if let tags = mCategorizedTags[cat] {
                        return tags
                } else {
                        return []
                }
        }

        public func selectByCategory(category cat: String) -> Array<TSSite>? {
                return mSiteTable[cat]
        }

        private var resourceFile: URL? { get {
                if let resdir = FileManager.default.resourceDirectory {
                        return resdir.appendingPathComponent(TSSiteTable.SiteFileName)
                } else {
                        NSLog("[Error] No resoource directory")
                        return nil
                }
        }}

        public func load()  {
                guard let resfile = self.resourceFile else {
                        return
                }

                let cachefile: URL
                switch FileManager.default.createCacheFile(source: resfile) {
                case .success(let cfile):
                        NSLog("cache file = \(cfile.absoluteString)")
                        cachefile = cfile
                case .failure(let err):
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                        return
                }

                if let err = load(from: cachefile) {
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                }
                updateInfo()
        }

        public func reload() {
                guard let resfile = self.resourceFile else {
                        return
                }
                if let err = FileManager.default.cleanCacheFile(source: resfile) {
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                }
                mSiteTable = [:]
                if let err = load(from: resfile) {
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                }
                updateInfo()
        }

        private func load(from file: URL) -> NSError? {
                switch TSSiteLoader.load(file: file) {
                case .success(let newsites):
                        merge(sites: newsites)
                        return nil
                case .failure(let err):
                        return err
                }
        }

        private func merge(sites newsites: Array<TSSite>) {
                for newsite in newsites {
                        let catname = newsite.category
                        if var cursites = mSiteTable[catname] {
                                cursites.append(newsite)
                                mSiteTable[catname] = cursites
                        } else {
                                mSiteTable[catname] = [newsite]
                        }
                }
        }

        private func updateInfo() {
                mAllCategoories         = []
                mCategorizedTags        = [:]
                for (catname, sites) in mSiteTable {
                        mAllCategoories.insert(catname)
                        for site in sites {
                                for tag in site.tags {
                                        if var tags = mCategorizedTags[catname] {
                                                tags.insert(tag)
                                                mCategorizedTags[catname] = tags
                                        } else {
                                                mCategorizedTags[catname] = [tag]
                                        }
                                }
                        }
                }
        }

        public func search(category catp: String?, tags tgs: Array<String>) -> Array<TSSite> {
                var result: Array<TSSite> = []
                if let cat = catp {
                        if let sites = mSiteTable[cat] {
                                for site in sites {
                                        if site.hasTags(tags: tgs) {
                                                result.append(site)
                                        }
                                }
                        }
                } else {
                        for (_, sites) in mSiteTable {
                                for site in sites {
                                        if site.hasTags(tags: tgs) {
                                                result.append(site)
                                        }
                                }
                        }
                }
                return result
        }

        public func collectTags(category catp: String?, tags tgs: Array<String>) -> Set<String> {
                var result: Set<String> = []
                if let cat = catp {
                        if let sites = mSiteTable[cat] {
                                let res = collectTags(sites: sites, tags: tgs)
                                result = result.union(res)
                        } else {
                                NSLog("[Error] Unknown category")
                        }
                } else {
                        for sites in mSiteTable.values {
                                let res = collectTags(sites: sites, tags: tgs)
                                result = result.union(res)
                        }
                }
                /* remove tags given by parameter */
                for tag in tgs {
                        result.remove(tag)
                }
                return result
        }

        private func collectTags(sites sts: Array<TSSite>, tags tgs: Array<String>) -> Set<String> {
                var result: Set<String> = []
                for site in sts {
                        if site.hasTags(tags: tgs) {
                                for tag in site.tags {
                                        result.insert(tag)
                                }
                        }
                }
                return result
        }

        public func dump() {
                for (_, cats) in mSiteTable {
                        for cat in cats {
                                NSLog("site: {")
                                NSLog("  category: \(cat.category)")
                                for tag in cat.tags {
                                        NSLog("  tag:  \(tag)")
                                }
                                for url in cat.URLs {
                                        NSLog("  url: \(url.absoluteString)")
                                }
                                NSLog("}")
                        }
                }

                for cat in self.allCategories {
                        NSLog("category: \(cat) {")
                        let tags = self.categorizedTags(inCategory: cat)
                        for tag in tags {
                                NSLog("     tag: \(tag)")
                        }
                        NSLog("}")
                }
        }
}
