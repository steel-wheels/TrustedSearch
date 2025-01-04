/*
 * @file TSSiteViewCpntrpller.swift
 * @description Define TSSiteViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSSiteViewController: MIStackViewController
{
        private var mCategoryMenu:      MIPopupMenu?            = nil
        
        private var mBrowserController  = TSBrowserController()
        
        override func viewDidLoad() {
                super.setup(axis: .vertical)
                super.viewDidLoad()

                /* make contents */
                makeContents(rootView: self.root)
        }

        private func makeContents(rootView root: MIStack) {
                /* category site menu */
                let catmenu = makeCategoryeMenu()
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", content: catmenu)
                root.addArrangedSubView(catbox)
        }

        private func makeCategoryeMenu() -> MIPopupMenu {
                let catmenu = MIPopupMenu()
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                catmenu.setCallback({
                        (_ menuId: Int) -> Void in
                        Task { await self.mBrowserController.set(category: nil)}
                })
                return catmenu
        }
}

