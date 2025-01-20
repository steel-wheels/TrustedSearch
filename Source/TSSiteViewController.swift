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
        
        private var mCategoryMenu:      MIPopupMenu?            = nil

        override func viewDidLoad() {
                mRootView.axis = .vertical
                super.viewDidLoad()

                /* make contents */
                makeContents(rootView: mRootView)
        }

        private func makeContents(rootView root: MIStack) {
                /* category site menu */
                let catmenu = makeCategoryeMenu()
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", contents: [catmenu])
                root.addArrangedSubView(catbox)

                /* URL table */
                let urltbl  = makeURLTable()
                let urllbl = MILabel() ; urllbl.title = "URLs"
                root.addArrangedSubView(urllbl)
                root.addArrangedSubView(urltbl)
        }

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

        private func makeURLTable() -> MITable {
                let table = MITable()
                return table
        }
}

