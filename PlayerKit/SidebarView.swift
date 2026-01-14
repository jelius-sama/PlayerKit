//
//  SidebarView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PlayerKit")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ForEach(SidebarItem.allCases) { item in
                Button {
                    selection = item
                } label: {
                    Label(item.rawValue, systemImage: item.icon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(
                            selection == item
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear
                        )
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 4)
            }

            Spacer()
        }
        .padding(.bottom)
    }
}
