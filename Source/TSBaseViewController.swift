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

        public func makeTagMenu(controlParameter param: TSControlrameters, level lvl: Int) -> MIPopupMenu {
                let tagmenu = MIPopupMenu()
                let mitems = tagsToMenuItems(tags: [])
                tagmenu.setMenuItems(items: mitems)
                tagmenu.setCallback({
                        (_ value: MIMenuItem.Value) -> Void in
                        switch value {
                        case .none:
                                param.setTag(index: lvl, tag: nil)
                        case .stringValue(let str):
                                param.setTag(index: lvl, tag: str)
                        case .intValue(let ival):
                                NSLog("[Error] Unexpected int value: \(ival)")
                        @unknown default:
                                NSLog("[Error] can not happen at \(#function)")
                        }
                })
                return tagmenu
        }

        public func tagsToMenuItems(tags tgs: Set<String>) -> Array<MIMenuItem> {
                var mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "None", value: .none)
                ]
                for tag in tgs.sorted() {
                        mitems.append(MIPopupMenu.MenuItem(title: tag, value: .stringValue(tag)))
                }
                return mitems
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

