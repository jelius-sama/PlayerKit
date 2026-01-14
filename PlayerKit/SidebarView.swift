//
//  SidebarView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?

    var body: some View {
        List(selection: $selection) {
            ForEach(SidebarItem.allCases) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("PlayerKit")
    }
}
