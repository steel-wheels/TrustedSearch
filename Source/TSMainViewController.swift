/*
 * @file TSMainViewCpntrpller.swift
 * @description Define TSMainViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSMainViewController: MITabViewController
{
        open override func shouldTransition(from fvc: MIViewControllerBase, to tvc: MIViewControllerBase) -> Bool {
                NSLog("shouldTransition (1) \(#function)")
                if let searchctrl = fvc as? TSSearchViewController,
                   let sitectrl   = tvc as? TSSiteViewController {
                        NSLog("search ctrl -> site ctrl")
                }
                NSLog("shouldTransition (2) \(#function)")
                return true
        }
}

