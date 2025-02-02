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

        public func updateCategoryMenu(menu popup: MIPopupMenu) async {
                var mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "All", value: .none)
                ]
                let allcats = await TSSiteTable.shared.allCategories.sorted()
                for cat in allcats {
                        mitems.append(MIPopupMenu.MenuItem(title: cat, value: .stringValue(cat)))
                }
                popup.setMenuItems(items: mitems)
        }

        public func updateTags(tag0Menu tag0menu: MIPopupMenu, tag1Menu tag1menu: MIPopupMenu, tag2Menu tag2menu: MIPopupMenu, controlParameter cparam: TSControlrameters) async {

                let cat = cparam.category

                var definedtags: Array<String> = []

                /* update tag0 */
                let hastag0 : Bool
                if true {
                        let tag0tags  = await TSSiteTable.shared.collectTags(category: cat, tags: definedtags)
                        let tag0items = tagsToMenuItems(tags: tag0tags)
                        tag0menu.setMenuItems(items: tag0items)
                        if let tag0lab = cparam.tag0Label {
                                definedtags.append(tag0lab)
                                hastag0 = true
                        } else {
                                hastag0 = false
                        }
                }

                /* update tag1 */
                let hastag1: Bool
                if hastag0 {
                        let tag1tags  = await TSSiteTable.shared.collectTags(category: cat, tags: definedtags)
                        let tag1items = tagsToMenuItems(tags: tag1tags)
                        tag1menu.setMenuItems(items: tag1items)
                        if let tag1lab = cparam.tag1Label {
                                definedtags.append(tag1lab)
                                hastag1 = true
                        } else {
                                hastag1 = false
                        }
                } else {
                        let tag1items = tagsToMenuItems(tags: [])
                        tag1menu.setMenuItems(items: tag1items)
                        hastag1 = false
                }

                /* update tag2 */
                if hastag0 && hastag1 {
                        let tag2tags  = await TSSiteTable.shared.collectTags(category: cat, tags: definedtags)
                        let tag2items = tagsToMenuItems(tags: tag2tags)
                        tag2menu.setMenuItems(items: tag2items)
                        if let tag2lab = cparam.tag2Label {
                                definedtags.append(tag2lab)
                        }
                } else {
                        let tag2items = tagsToMenuItems(tags: [])
                        tag2menu.setMenuItems(items: tag2items)
                }
        }
}

