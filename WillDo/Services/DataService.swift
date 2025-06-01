//
//  DataService.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/06/01.
//
import SwiftData
import Foundation
import SwiftUICore

class DataService: ObservableObject {
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    func saveNewWillDo(_ willDo: WillDo) throws {
        modelContext.insert(willDo)
        try modelContext.save()
    }
    
    func createChild(parent: WillDo, child: WillDo) throws {
        child.parent = parent
        parent.childWillDos.append(child)
        modelContext.insert(parent)
        try modelContext.save()
    }
    
    func fetchAll() throws -> [WillDo] {
        let descriptor = FetchDescriptor<WillDo>()
        return try modelContext.fetch(descriptor)
    }
}
