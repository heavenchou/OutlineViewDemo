//
//  ViewController.swift
//  OutlineViewDemo
//
//  Created by Heaven Chou on 2019/11/2.
//  Copyright © 2019 CBETA. All rights reserved.
//

import Cocoa

let REORDER_PASTEBOARD_TYPE = "com.kinematicsystems.outline.item"

// MARK: 資料結構
@objcMembers class Sutra:NSObject {
    dynamic var name: String = ""
    dynamic var sub: [Sutra] = []
    init (_ name: String) {
        self.name = name
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var outlineBindView: NSOutlineView!
    
    @objc dynamic var sutra: [Sutra] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 資料實作
        makeSutra()
        
        outlineView.delegate = self
        outlineView.dataSource = self
    
        // 處理 click
        outlineBindView.target = self
        outlineBindView.action = #selector(self.onItemClicked)
        outlineBindView.doubleAction = #selector(self.onItemDbClicked)

        
        // Register for the dropped object types we can accept.
        outlineView.registerForDraggedTypes([NSPasteboard.PasteboardType (rawValue: REORDER_PASTEBOARD_TYPE)])
        
        // Disable dragging items from our view to other applications.
        outlineView.setDraggingSourceOperationMask(NSDragOperation(), forLocal: false)
        
        // Enable dragging items within and into our view.
        outlineView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
    }
        
    // 處理 click
    @objc private func onItemClicked(sender: Any) {
        if let node = outlineBindView.item(atRow: outlineBindView.clickedRow) as? NSTreeNode {
            if let item = node.representedObject as? Sutra {
                print("\(item.name)")
                print("(\(outlineBindView.clickedRow),\( outlineBindView.clickedColumn))")
            }
        }
    }
    // 處理 double click
    @objc private func onItemDbClicked(sender: Any) {
        print("Double Click")
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /*
    override func viewDidAppear() {
        super.viewDidAppear()
        // 展現全部的方法
        //outlineView.expandItem(nil, expandChildren: true)
        // 展現節點 1 的方法，子層不要呈現
        //outlineView.expandItem(outlineView.item(atRow: 1), expandChildren: false)
    }
    */
    
    // MARK: 自訂成員函式，資料實作
    fileprivate func makeSutra() {
        sutra.append(Sutra("阿含"))
        sutra[0].sub.append(Sutra("雜阿含"))
        sutra[0].sub.append(Sutra("中阿含"))
        sutra[0].sub.append(Sutra("長阿含"))
        
        sutra.append(Sutra("般若"))
        sutra[1].sub.append(Sutra("心經"))
        sutra[1].sub.append(Sutra("金剛經"))
        sutra[1].sub[1].sub.append(Sutra("能斷金剛"))
        sutra[1].sub[1].sub.append(Sutra("般若金剛"))
        
    }
}

extension NSOutlineView {
    open override func mouseDown(with event: NSEvent) {
        print(event.clickCount)
        super.mouseDown(with: event)
    }
}

// MARK: 資料來源和代理實作
// 將代理程式另外獨立出來，也是不錯的方法
extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    // 1.詢問 item 這個節點底下有多少子節點
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // nil 表示是根目錄
        if item == nil {
            // 傳回 sutra 的數量
            return sutra.count
        } else {
            // 若是子層，就傳回子層的 sub 陣列數量
            if let item = item as? Sutra {
                return item.sub.count
            }
        }
        return 0
    }
    
    // 2.詢問 item 節點下第 index 個節點的子 item 識別代號
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        // 這裡的識別代碼必須是獨一無二的代號，用來判斷是在哪一層，在此就是傳回該 Sutra 的地址 (應該是地址吧?)
        if item == nil {
            return sutra[index]
        } else {
            if let item = item as? Sutra {
                return item.sub[index]
            }
        }
        return 0
    }
    
    // 3.詢問在某一個 Column 時，某子 item 要呈現什麼內容
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        // 抄來的，實際追踨時並沒有進入裡面
        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }
        // 因為 item 是 Sutra 物件的地址，
        // 所以直接取它的 name 屬性當成內容
        var text = (item as! Sutra).name
        
        // 前面把第一個 Column 定義為 keyColumn
        // 這裡就處理成若不是 keyColumn (表示第二欄)
        // text 就加上書名號，用來區別第一欄
        if columnIdentifier != "keyColumn" {
            text = "《\(text)》"
            // 但如果這個節點是有子層的，就不要有內容
            if (item as! Sutra).sub.count != 0 {
                text = ""
            }
        }
        // 這裡比較不好懂，也是抄來的
        // outlineViewCell 是第一個 Column 的 Table Cell View 的 Identifier
        // 好像就是做出一個 cell，內容是 text，然後傳回去
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewCell")
        let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField!.stringValue = text

        return cell
    }
    
    // 4.詢問某一個子 item 底下還有沒有子 item?
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // 如果 item 的 sub 有內容，就表示有子層，傳回 true
        if let item = item as? Sutra , item.sub.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: Drag & Drop
    
    // Implement this method to enable the table to be an NSDraggingSource that supports dragging multiple items.
    // 實現此方法可使表成為 NSDraggingSource 以支持拖動多個項目的表。
/*
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        print(1)
        let pbItem:NSPasteboardItem = NSPasteboardItem()
        pbItem.setDataProvider(self, forTypes: [NSPasteboard.PasteboardType(rawValue: REORDER_PASTEBOARD_TYPE)])
        return pbItem
    }
    
    // Implement this method know when the given dragging session is about to begin and potentially modify the dragging session.
    // 知道給定的拖動會話何時開始並有可能修改拖動會話時，實施此方法即可。

    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        print(2)
        draggedNode = draggedItems[0] as AnyObject?
        session.draggingPasteboard.setData(Data(), forType: NSPasteboard.PasteboardType(rawValue: REORDER_PASTEBOARD_TYPE))
    }
    
    // Used by an outline view to determine a valid drop target.
    // 大綱視圖用於確定有效的放置目標。

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        print(3)
        var retVal:NSDragOperation = NSDragOperation()
        var itemName = "nilItem"
        
        let baseItem = item as? BaseItem
        
        if baseItem != nil
        {
            itemName = baseItem!.name
        }

        // proposedItem is the item we are dropping on not the item we are dragging
        // - If dragging a set target item must be nil
        if (item as AnyObject? !== draggedNode && index != NSOutlineViewDropOnItemIndex)
        {
            if let _ = draggedNode as? FolderItem
            {
                if (item == nil)
                {
                    retVal = NSDragOperation.generic
                }
            }
            else if let _ = draggedNode as? TestItem
            {
                retVal = NSDragOperation.generic
            }
        }
        
        debugPrint("validateDrop targetItem:\(itemName) childIndex:\(index) returning: \(retVal != NSDragOperation())")
        return retVal
    }
    
    // Returns a Boolean value that indicates whether a drop operation was successful.
    // 返回一個布爾值，該值指示放置操作是否成功。

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        print(4)
        var retVal:Bool = false
        if !(draggedNode is BaseItem)
        {
            return false
        }
        
        let srcItem = draggedNode as! BaseItem
        let destItem:FolderItem? = item as? FolderItem
        let parentItem:FolderItem? = outlineView.parent(forItem: srcItem) as? FolderItem
        let oldIndex = outlineView.childIndex(forItem: srcItem)
        var   toIndex = index
        
        debugPrint("move src:\(srcItem.name) dest:\(String(describing: destItem?.name)) destIndex:\(index) oldIndex:\(oldIndex) srcParent:\(String(describing: parentItem?.name)) toIndex:\(toIndex) toParent:\(String(describing: destItem?.name)) childIndex:\(index)", terminator: "")
        
        if (toIndex == NSOutlineViewDropOnItemIndex) // This should never happen, prevented in validateDrop
        {
            toIndex = 0
        }
        else if toIndex > oldIndex
        {
            toIndex -= 1
        }
        
        if srcItem is FolderItem && destItem != nil
        {
            retVal = false
        }
        else if oldIndex != toIndex || parentItem !== destItem
        {
            testData.moveItemAtIndex(oldIndex, inParent: parentItem, toIndex: toIndex, inParent: destItem)
            outlineView.moveItem(at: oldIndex, inParent: parentItem, to: toIndex, inParent: destItem)
            retVal = true
        }
        
        debugPrint(" returning:\(retVal)")
        if retVal
        {
            testData.dump()
        }
        return retVal
    }
    
    // Implement this method to know when the given dragging session has ended.
    // 實現此方法以了解給定的拖動會話何時結束。

    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        //debugPrint("Drag session ended")
        print(5)
        self.draggedNode = nil
    }
    
    // Asks the receiver to provide data for a specified type to a given pasteboard.
    // 要求接收者向指定的粘貼板提供指定類型的數據。

    // MARK: NSPasteboardItemDataProvider
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType)
    {
        print(6)
        let s = "Outline Pasteboard Item"
        item.setString(s, forType: type)
    }
*/
}

