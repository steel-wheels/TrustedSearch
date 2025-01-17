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
        public override func shouldTransition(from fvc: MIViewControllerBase, to tvc: MIViewControllerBase) -> Bool {
                if let searchctrl = fvc as? TSSearchViewController,
                   let sitectrl   = tvc as? TSSiteViewController {
                        NSLog("search ctrl -> site ctrl")
                        TSControlrameters.copy(from: searchctrl.controlParameters, to: sitectrl.controlParameters)
                }
                return true
        }
}

