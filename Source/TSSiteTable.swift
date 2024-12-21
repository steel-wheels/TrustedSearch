/*
 * @file TSSiteTable.swift
 * @description Define TSSiteTable class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSSite {
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

        public func hasAllTags(tags srcs: Array<String>) -> Bool {
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

        private var mSiteTable: Dictionary<String, Array<TSSite>>

        private init() {
                mSiteTable  = [:]
        }

        public var categoryNames: Array<String> { get {
                return Array(mSiteTable.keys.sorted())
        }}

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
        }
}
