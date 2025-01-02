/*
 * @file TSViewCpntrpller.swift
 * @description Define TSViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSMainViewController: MITabViewController
{
        override func viewDidLoad() {
                let searchctrl = TSSearchViewController()
                super.addContentView(title: "Search", controller: searchctrl)

                NSLog("Main: viewDidLoad")
                super.viewDidLoad()
        }
}

