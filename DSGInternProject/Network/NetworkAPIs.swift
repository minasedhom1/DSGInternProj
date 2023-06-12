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
    
    func compareAppVersions(storeVersion: String, currentVersion: String) -> ComparisonResult {
        let components1 = storeVersion.components(separatedBy: ".")
        let components2 = currentVersion.components(separatedBy: ".")
        
        // Determine the minimum length between the two version component arrays
        let minLength = min(components1.count, components2.count)
        
        // Iterate through the common components and compare them
        for i in 0..<minLength {
            let component1 = Int(components1[i]) ?? 0
            let component2 = Int(components2[i]) ?? 0
            
            if component1 < component2 {
                return .orderedAscending
            } else if component1 > component2 {
                return .orderedDescending
            }
        }
        
        // If the common components are equal, but one version has more components,
        // the version with more components as the newer version. case-> 5.2 and 5.2.3
        if components1.count < components2.count {
            return .orderedAscending
        } else if components1.count > components2.count {
            return .orderedDescending
        }
        
        // If all components are equal, the versions are the same.
        return .orderedSame
    }

    
    
    func checkForUpdates(){
        let currentVersion = "5.3.12" //UIApplication.appVersion ?? ""
            isUpdateAvailable = currentVersion != version
        
        let result = compareAppVersions(storeVersion: version, currentVersion: currentVersion)

        switch result {
        case .orderedAscending:
            print("\(version) is older than \(currentVersion)")
        case .orderedDescending:
            print("\(version) is newer than \(currentVersion)")
            isUpdateAvailable = true
        case .orderedSame:
            print("\(version) and \(currentVersion) are the same")
        }
        
        }
        
        func dismissUpdate() {
            isUpdateAvailable = false
        }
    
}
