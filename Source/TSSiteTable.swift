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

        static let CategoryIdentifier  = "category"
        static let TagsIdentifier      = "tags"
        static let SitesIdentifier     = "sites"

        public static var valueType: MIValueType { get {
                let types: Dictionary<String, MIValueType> = [
                        TSSite.CategoryIdentifier:      .string,
                        TSSite.TagsIdentifier:          .array(.string),
                        TSSite.SitesIdentifier:         .array(.string)
                ]
                return .interface(nil, types)
        }}

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

        public func toValue() -> MIValue {
                var result: Dictionary<String, MIValue> = [:]

                /* category */
                result[TSSite.CategoryIdentifier] = MIValue(type: .string, value: .string(self.category))

                /* tags */
                var tagvals: Array<MIValue> = [] // array of tag string
                for tag in self.tags {
                        tagvals.append(MIValue(type: .string, value: .string(tag)))
                }
                result[TSSite.TagsIdentifier] = MIValue(type: .array(.string), value: .array(tagvals))

                /* URLs */
                var urlvals: Array<MIValue> = [] // array of url string
                for url in self.URLs {
                        urlvals.append(MIValue(type: .array(.string), value: .string(url.absoluteString)))
                }
                result[TSSite.SitesIdentifier] = MIValue(type: .array(.string), value: .array(urlvals))

                return MIValue(type: TSSite.valueType, value: .interface(result))
        }

        public static func fromValue(_ src: Dictionary<String, MIValue>) -> Result<TSSite, NSError> {
                /* category */
                let category: String
                guard let catval = src[CategoryIdentifier] else {
                        return .failure(MIError.error(errorCode: .parseError, message: "No \(CategoryIdentifier) property"))
                }
                if let str = catval.stringValue {
                        category = str
                } else {
                        return .failure(MIError.error(errorCode: .parseError, message: "\(CategoryIdentifier) property must have strings"))
                }
                /* tags */
                let tags: Array<String>
                guard let tagsval = src[TagsIdentifier] else {
                        return .failure(MIError.error(errorCode: .parseError, message: "No \(TagsIdentifier) property"))
                }
                if let arr = tagsval.arrayValue {
                        var ltags: Array<String> = []
                        for elm in arr {
                                if let str = elm.stringValue {
                                        ltags.append(str)
                                } else {
                                        return .failure(MIError.error(errorCode: .parseError, message: "String property is required for \(TagsIdentifier)"))
                                }
                        }
                        tags = ltags
                } else {
                        return .failure(MIError.error(errorCode: .parseError, message: "\(TagsIdentifier) property must have array of URL strings"))
                }
                /* URLs */
                let urls: Array<URL>
                guard let sitesval = src[SitesIdentifier] else {
                        return .failure(MIError.error(errorCode: .parseError, message: "No \(SitesIdentifier) property"))
                }
                if let arr = sitesval.arrayValue {
                        var lurls: Array<URL> = []
                        for elm in arr {
                                if let str = elm.stringValue {
                                        if let url = URL(string: str) {
                                                lurls.append(url)
                                        } else {
                                                return .failure(MIError.error(errorCode: .parseError, message: "Failed to convert string \"\(str)\" to URL"))
                                        }
                                } else {
                                        return .failure(MIError.error(errorCode: .parseError, message: "String property is required for \(SitesIdentifier)"))
                                }
                        }
                        urls = lurls
                } else {
                        return .failure(MIError.error(errorCode: .parseError, message: "\(SitesIdentifier) property must have array of URL strings"))
                }

                let site = TSSite(category: category, tags: tags, URLs: urls)
                return .success(site)
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
                guard let cachefile = cacheFile() else {
                        return
                }
                if let err = load(from: cachefile) {
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                }
                updateInfo()
        }

        private func cacheFile() -> URL? {
                guard let resfile = self.resourceFile else {
                        return nil
                }

                switch FileManager.default.createCacheFile(source: resfile) {
                case .success(let cfile):
                        NSLog("cache file = \(cfile.absoluteString)")
                        return cfile
                case .failure(let err):
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                        return nil
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

        public func collectSites(category catp: String?, tags tgs: Array<String>) -> Array<TSSite> {
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

        public func save(to url: URL) -> NSError? {
                let srcval = toValue()
                let text   = MIJsonEncoder.encode(value: srcval)
                let str    = text.toString()
                var result: NSError? = nil
                do {
                        //NSLog("save table into \(url.absoluteString)")
                        try str.write(to: url, atomically: false, encoding: .utf8)
                } catch {
                        result = MIError.error(errorCode: .fileError, message: "Failed to save table info \(url.absoluteString)")
                }
                return result
        }

        public func toValue() -> MIValue {
                var result: Array<MIValue> = []
                for (_, sites) in mSiteTable {
                        for site in sites {
                                result.append(site.toValue())
                        }
                }
                return MIValue(type: .array(TSSite.valueType), value: .array(result))
        }

        public func dump() {
                let tableval = self.toValue()
                let text = MIJsonEncoder.encode(value: tableval)
                NSLog("[Site table] " + text.toString())
        }
}
