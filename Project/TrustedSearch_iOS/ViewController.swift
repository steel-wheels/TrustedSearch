/*
 * @file ViewCpntrpller.swift
 * @description Define ViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import UIKit

class ViewController: TSViewController
{
        @IBOutlet weak var mRootView: MIStack!

        override func viewDidLoad() {
                setRootView(mRootView)
                super.viewDidLoad()
        }
}

