//
//  ContentView.swift
//  Journal
//
//  Created by Yukiko Nii on 2024/07/23.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @ObservedObject var viewModel: JournalViewModel
    
    @State var selection = 1
    
    
    var body: some View {
        
        TabView(selection: $selection) {
            
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName:"house")
                }
                .tag(1)
            
            LogView(viewModel: viewModel)
                .tabItem {
                    Image(systemName:"plus.app.fill")
                }
                .tag(2)
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Image(systemName:"list.bullet.clipboard.fill")
                }
                .tag(3)
            
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName:"gear")
                }
                .tag(4)
            
        }
        .tint(Color("Prim"))
        
        /*
        .onAppear {
            let standardAppearance = UITabBarAppearance() // create UITabBarAppearance Object
                standardAppearance.configureWithDefaultBackground()
                standardAppearance.backgroundColor = UIColor(.red) // customize the color
                UITabBar.appearance().standardAppearance = standardAppearance // standard appearance applies when scrolling
        }
         */ // TODO: This works but I don't really want to use it
    }
    
}


#Preview {
    JournalView(viewModel: JournalViewModel())
        .modelContainer(for: [stressLog.self, summaryLog.self, metricsLog.self], inMemory:true)
    // Someone suggested that if the problem is only within Preview, inMemory: true works.
    // https://www.hackingwithswift.com/forums/100-days-of-swiftui/day-54-crash-in-preview-of-swiftdata/26510
    //  https://qiita.com/Puyan/items/117e8a266c34a81c393d
}
