/*
 * @file TSBaseViewCpntrpller.swift
 * @description Define TSSearchViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSBaseViewController: MIViewController
{
        public func makeCategoryMenu(controlParameter param: TSControlrameters) -> MIPopupMenu {
                let catmenu = MIPopupMenu()
                let mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "All", value: .none)
                ]
                catmenu.setMenuItems(items: mitems)
                catmenu.setCallback({
                        (_ value: MIMenuItem.Value) -> Void in
                        switch value {
                        case .none:
                                param.category = nil
                        case .stringValue(let sval):
                                param.category = sval
                        case .intValue(let ival):
                                NSLog("[Error] Unexpected int value: \(ival)")
                        @unknown default:
                                NSLog("[Error] can not happen at \(#function)")
                        }
                })
                return catmenu
        }

        public func initCategoryMenu(menu popup: MIPopupMenu) async {
                var mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "All", value: .none)
                ]
                let allcats = await TSSiteTable.shared.allCategories.sorted()
                for cat in allcats {
                        mitems.append(MIPopupMenu.MenuItem(title: cat, value: .stringValue(cat)))
                }
                popup.setMenuItems(items: mitems)
        }
}

