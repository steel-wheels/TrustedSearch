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
                                        switch TSSite.fromValue(dict) {
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
}
