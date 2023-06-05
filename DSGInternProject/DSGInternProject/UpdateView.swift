//
//  UpdateView.swift
//  DSGInternProject
//
//  Created by Mina Sedhom on 6/2/23.
//

import SwiftUI
import FirebaseRemoteConfig

struct UpdateView: View {
    let version: String
    @StateObject private var remoteConfigManager = RemoteConfigManager()
    
    let dismissAction: () -> Void?
    @State private var appVersion = ""
    var body: some View {
        VStack{
            if remoteConfigManager.isLoading {
                ProgressView()
            } else {
                Spacer()
                Text("You got an update!!")
                    .font(.title)
                Text("app_version: \(version) \n is_focible: \(remoteConfigManager.isForcible)" as String)
                Spacer()
                HStack {
                    Button("Update") {
                        if let url = URL(string: "https://www.apple.com/app-store/") {
                            UIApplication.shared.open(url)
                        }
                        //Reset update dismissedDate to be nil
                       // UserDefaults.standard.setValue(nil, forKey: "dismissedDate")
                    }.padding()
                        .background(.green)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    if !remoteConfigManager.isForcible {
                        Button("Dismiss") {
                            //record the date
                            let df = DateFormatter()
                            df.dateStyle = .medium
                            df.timeStyle = .none
                            let str = df.string(from: Date())
                            //overwrite the dismissed date in userDefault
                            UserDefaults.standard.setValue(str, forKey: "dismissedDate")
                            print("dismissed and date saved to UD \(str)")
                            UserDefaults.standard.setValue(true, forKey: "dismissedAction")
                            UserDefaults.standard.setValue(version, forKey: "dismissedVersion")
                            
                            dismissAction()
                        }.padding()
                            .background(.red)
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                Spacer()
            }
        }
        .onAppear {
            remoteConfigManager.fetchRemoteConfig()
        }
    }
}
