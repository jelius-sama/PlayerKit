//
//  SidebarItem.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 14/01/26.
//


enum SidebarItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}
