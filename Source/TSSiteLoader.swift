/*
 * @file TSSiteLoader.swift
 * @description Define TSSiteLoader class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSSiteLoader
{
        public static func load(file url: URL) -> Result<Array<TSSite>, NSError> {
                let result: Result<Array<TSSite>, NSError>
                switch MIJsonFile.load(from: url) {
                case .success(let value):
                        result = load(value: value)
                case .failure(let err):
                        result = .failure(err)
                }
                return result
        }

        private static func load(value src: MIValue) -> Result<Array<TSSite>, NSError> {
                if let arr = src.arrayValue {
                        var result: Array<TSSite> = []
                        for elm in arr {
                                if let dict = elm.interfaceValue {
                                        switch load(dictionary: dict, index: result.count) {
                                        case .success(let site):
                                                result.append(site)
                                        case .failure(let err):
                                                return .failure(err)
                                        }
                                } else {
                                        let idx = result.count
                                        let err = MIError.error(errorCode: .fileError, message: "Array element \(idx) must be dictionary")
                                        return .failure(err)
                                }
                        }
                        return .success(result)
                } else {
                        let err = MIError.error(errorCode: .fileError, message: "Root value must be array")
                        return .failure(err)
                }
        }

        private static func load(dictionary src: Dictionary<String, MIValue>, index idx: Int) -> Result<TSSite, NSError> {
                let CategoryIdentifier  = "category"
                let TagsIdentifier      = "tags"
                let SitesIdentifier     = "sites"

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
