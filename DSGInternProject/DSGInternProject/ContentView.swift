//
//  ContentView.swift
//  DSGInternProject
//
//  Created by Mina Sedhom on 6/2/23.
//

import SwiftUI
import Combine


struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    
    @State private var isUpdateAvailable = false
    @State private var isForcible = false
    
    let currentDate = Date()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // comming date for testing purposes
    var futureDate: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: currentDate) ?? currentDate
    }
    
    // previeous date for testing purposes
    var updateSkippedDate: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: currentDate) ?? currentDate
    }
    
    // Returns true if the difference between that date and current date is >= 2 days
    // Hence proceed to Homepage
    var needsUpdateReminder: Bool {
        let calendar = Calendar.current
        let dateStr = UserDefaults.standard.string(forKey: "dismissedDate")
        let date = dateFormatter.date(from: dateStr ?? "") ?? currentDate
        let components = calendar.dateComponents([.day], from: updateSkippedDate, to: currentDate)
        print(" Today - skippedDate =  \(String(describing: components.day))")
        return abs(components.day ?? 0) >= 2
    }
    
    // returns true if its the first time to show update screen or the user hasn't prevoiusly skipped the update screen
    var firstTimeUpdate: Bool {
        // this value is being set in the dismiss button action
        return (UserDefaults.standard.string(forKey: "dismissedAction") == nil)
    }
    
    // returns true if the new fetched version from apple api is not the same as the last skipped update version.
    var differentVersionThanSkippedOne: Bool {
        let lastDismissedVersion = UserDefaults.standard.string(forKey: "dismissedVersion")
        print("networkManager.version != lastDismissedVersion \(networkManager.version != lastDismissedVersion)")
        return networkManager.version != lastDismissedVersion
    }
    
    var body: some View {
        if networkManager.version.isEmpty {
            ProgressView()
                .onAppear {
                    // fetch latest app version
                    networkManager.fetchVersion(bundleId: "com.dsg.mobile.consumer")
                }
        } else {
            if networkManager.isUpdateAvailable && (needsUpdateReminder || firstTimeUpdate || differentVersionThanSkippedOne){
                    UpdateView(version: networkManager.version) {
                        networkManager.dismissUpdate()
                    }
            } else {
                VStack{
                    Text("Home Screen")
                        .font(.largeTitle)
                    if let dateStr = UserDefaults.standard.string(forKey: "dismissedDate") {
                        Text("current date (dismissed tapped): \(dateStr)")
                        Text("Next remider: \(futureDate, formatter: dateFormatter)")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
