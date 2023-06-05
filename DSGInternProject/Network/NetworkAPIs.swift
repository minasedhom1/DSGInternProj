//
//  AppleAPI.swift
//  DSGInternProject
//
//  Created by Mina Sedhom on 6/2/23.
//
import Foundation
import Combine
import UIKit
import FirebaseRemoteConfig

class RemoteConfigManager: ObservableObject {
    static let shared = RemoteConfigManager()
    @Published var isForcible: Bool = false
    @Published var isLoading: Bool = false


    //private init() {}
    
    func fetchRemoteConfig() {
        self.isLoading = true
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Force network fetch

        remoteConfig.configSettings = settings
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
            if let error = error {
                print("Error fetching remote config: \(error.localizedDescription)")
            } else {
                remoteConfig.activate { (status, error) in
                    if let error = error {
                        print("Error activating remote config: \(error.localizedDescription)")
                    } else {
                            // Replace the below line with your actual code to fetch the remote configuration
                        self.isForcible = remoteConfig.configValue(forKey: "is_forcible").boolValue
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

class NetworkManager: ObservableObject {
    @Published var version: String = ""
    @Published var isUpdateAvailable: Bool = false
    
    static func getVersionFromAPI(bundleId: String) -> AnyPublisher<String, Error> {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: LookupResponse.self, decoder: JSONDecoder())
            .map { $0.results.first?.version ?? "" }
            .eraseToAnyPublisher()
    }
    
    func fetchVersion(bundleId: String) {
        NetworkManager.getVersionFromAPI(bundleId: bundleId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching version: \(error)")
                }
            }, receiveValue: { [weak self] version in
                self?.version = version
                self?.checkForUpdates()
            })
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func checkForUpdates() {
        let currentVersion = UIApplication.appVersion ?? ""
            isUpdateAvailable = currentVersion != version
        }
        
        func dismissUpdate() {
            isUpdateAvailable = false
        }
    
}
