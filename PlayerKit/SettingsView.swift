//
//  SettingsView.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 26/01/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var fullscreen: FullscreenController

    var body: some View {
        VStack {
            Image(systemName: "gearshape").font(.system(size: 40)).padding()
            NavigationLink(
                "Open Profile Settings",
                destination: (Text("This is a Settings Sub-Page"))
                    .toolbar(.hidden)
            )
            .buttonStyle(.bordered)
        }
    }
}
