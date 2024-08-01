//
//  2.swift
//  Journal
//
//  Created by Yukiko Nii on 2024/07/24.
//

import SwiftUI
import SwiftData

struct PageTwoView: View {

    @State private var stressLevel : Double = 0
    @State private var sleep : Double = 0
    @State private var activity : Double = 0
    @State private var school : Double = 0
    @State private var date = Date()


    @State private var journal = ""
    
    @ObservedObject var viewModel: JournalViewModel
    
    @Environment(\.modelContext) var context
    @Query var logs: [log]

    var body: some View {
        ZStack {
            
            Color("Prim")
                .ignoresSafeArea()
            
            ScrollView {
                
                
            // Stress Tracker which you can log as many times as you want each day.
            VStack {
                Text("Stress Tracker")
                    .font(.system(20))
                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                
                Text("Stress Level: \(stressLevel, specifier:"%.0f")")
                    .padding()
                //.frame(maxWidth:.infinity, alignment: .leading)
                //https://t32k.me/mol/log/text-align-swiftui/
                Slider(value: $stressLevel, in: 0...10, step:1,  minimumValueLabel: Text("Low"),
                       maximumValueLabel: Text("High"),
                       label: { EmptyView() })
                .padding(.horizontal)
                .tint(Color("Sec"))
                
                Button("Submit") {
                    let newLog = log(logDate: date, stressLevel: stressLevel)
                    context.insert(newLog)
                } // Button
                .padding()
                .buttonStyle(.bordered)
                .tint(.white)
                
                    
            }
            .padding()
            .font(.system(16))
            .foregroundStyle(Color("Sec"))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("Sec"), lineWidth: 4)
            )
            .padding(20)
            
            
            VStack {
                
                Text("Daily Log")
                    .font(.system(20))
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                
                //https://zenn.dev/joo_hashi/books/ccb8a3799ce7ba/viewer/8ae4e2
                
                /*Text(Date(), style: .date)
                 .font(.system(30))
                 .padding() */
                Divider()
                
                
                /*
                Text("Stress Level: \(stressLevel, specifier:"%.0f")")
                    .padding()
                //.frame(maxWidth:.infinity, alignment: .leading)
                //https://t32k.me/mol/log/text-align-swiftui/
                Slider(value: $stressLevel, in: 0...10, step:1,  minimumValueLabel: Text("Low"),
                       maximumValueLabel: Text("High"),
                       label: { EmptyView() })
                .padding(.horizontal) */
                
                Text("Sleep: \(sleep, specifier:"%.0f") hours")
                    .padding()
                Slider(value: $sleep, in: 0...10, step:1,  minimumValueLabel: Text("0"),
                       maximumValueLabel: Text("10h+"),
                       label: { EmptyView() })
                .padding(.horizontal)
                .tint(Color("Sec"))

                
                Text("Activity: \(activity, specifier:"%.0f")")
                    .padding()
                Slider(value: $activity, in: 0...10, step:1,  minimumValueLabel: Text("0"),
                       maximumValueLabel: Text("10"),
                       label: { EmptyView() })
                .padding(.horizontal)
                .tint(Color("Sec"))

                
                Text("School: \(school, specifier:"%.0f")")
                    .padding()
                Slider(value: $school, in: 0...10, step:1,  minimumValueLabel: Text("0"),
                       maximumValueLabel: Text("10"),
                       label: { EmptyView() })
                .padding(.horizontal)
                .tint(Color("Sec"))

                
                Text("Journal")
                
                TextField("Anything else?", text: $journal)
                    .padding()
                
                
                
            } // VStack
            .padding()
            .font(.system(16))
            .foregroundStyle(Color("Sec"))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("Sec"), lineWidth: 4)
            )
            .padding(20)
            
        }// scroll
        .frame(height:700)

        }
    }
}

