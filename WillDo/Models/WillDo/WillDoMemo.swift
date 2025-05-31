//
//  WillDoMemo.swift
//  WillDo
//
//  Created by 加瀬一輝 on R 7/05/31.
//
import SwiftUI
import Foundation

struct Memo {
    var date: Date
    var content: String

    init(date: Date, content: String) {
        self.date = date
        self.content = content
    }
}
