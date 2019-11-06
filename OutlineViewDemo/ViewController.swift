//
//  ViewController.swift
//  OutlineViewDemo
//
//  Created by Heaven Chou on 2019/11/2.
//  Copyright © 2019 CBETA. All rights reserved.
//

import Cocoa

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
    @objc dynamic var sutra: [Sutra] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 資料實作
        makeSutra()

        // outlineView.dataSource = self
        // outlineView.delegate = self
    
        // 處理 click
        outlineView.target = self
        outlineView.action = #selector(self.onItemClicked)
        //outlineView.doubleAction = #selector(self.onItemDoubleClicked)
       
    }
        
    // 處理 click
    @objc private func onItemClicked(sender: Any) {
        if let node = outlineView.item(atRow: outlineView.clickedRow) as? NSTreeNode {
            if let item = node.representedObject as? Sutra {
                print("\(item.name)")
                print("(\(outlineView.clickedRow),\( outlineView.clickedColumn))")
            }
        }
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
/*
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
}
*/
