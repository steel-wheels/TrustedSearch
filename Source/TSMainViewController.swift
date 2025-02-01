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
                if let searchctrl = fvc as? TSSearchViewController,
                   let sitectrl   = tvc as? TSSiteViewController {
                        NSLog("search ctrl -> site ctrl")
                        let srcparam = searchctrl.controlParameters
                        let dstparam = sitectrl.controlParameters
                        TSControlrameters.copy(dst: dstparam, src: srcparam)
                }
                return true
        }
}

