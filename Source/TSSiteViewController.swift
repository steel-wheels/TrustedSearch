/*
 * @file TSSiteViewCpntrpller.swift
 * @description Define TSSiteViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSSiteViewController: MIViewController
{
        #if os(iOS)
        @IBOutlet weak var mRootView: MIStack!
        #else
        @IBOutlet weak var mRootView: MIStack!
        #endif

        public var controlParameters = TSControlrameters()

        private var mURLTable: MITable? = nil

        override func viewDidLoad() {
                mRootView.axis = .vertical
                super.viewDidLoad()

                /* make contents */
                makeContents(rootView: mRootView)

                /* load table */
                //Task {
                //        await loadURLTable()
                //}
        }

        private func makeContents(rootView root: MIStack) {
                /* URL table */
                let urltbl  = makeURLTable()
                let urllbl = MILabel() ; urllbl.title = "URLs"
                root.addArrangedSubView(urllbl)
                root.addArrangedSubView(urltbl)
                mURLTable = urltbl
        }

        /*
        private func makeCategoryeMenu() -> MIPopupMenu {
                let catmenu = MIPopupMenu()
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                catmenu.setCallback({
                        (_ menuId: Int) -> Void in
                        //Task { await self.mBrowserController.set(category: nil)}
                })
                return catmenu
        }
         */

        private func makeURLTable() -> MITable {
                let table = MITable()
                return table
        }

        /*
        private func loadURLTable() async {
                NSLog("load URL table (1)")
                guard let urltable = mURLTable, let ctrl = browserController else {
                        NSLog("skip")
                        return
                }
                NSLog("load URL table (2)")
                let urls  = await ctrl.siteURLs()
                let paths = urls.map { $0.path }
                urltable.setTableData(paths)
                urltable.requireDisplay()
        }*/
}

