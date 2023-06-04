//
//  SettingsStore.swift
//  NFCPassportReaderApp
//
//  Created by Andy Qua on 10/02/2021.
//  Copyright © 2021 Andy Qua. All rights reserved.
//

import SwiftUI
import Combine
import NFCPassportReader

class SettingsStore {

    private enum Keys {
        static let captureLog = "captureLog"
        static let logLevel = "logLevel"
        static let passportNumber = "passportNumber"
        static let dateOfBirth = "dateOfBirth"
        static let dateOfExpiry = "dateOfExpiry"
        static let imgBase64 = "imgBase64"
        static let userInfo = "userInfo"
        static let template = "template"
        

        static let allVals = [captureLog, logLevel, passportNumber, dateOfBirth, dateOfExpiry]
    }
    
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        

        defaults.register(defaults: [
            Keys.imgBase64: "",
            Keys.template: "",
            Keys.captureLog: true,
            Keys.logLevel: 1,
            Keys.passportNumber: "",
            Keys.dateOfBirth: "",
            Keys.dateOfExpiry: "",
            Keys.userInfo: Data(),
            
        ])
        
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    
    func reset() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    var shouldCaptureLogs: Bool {
        set { defaults.set(newValue, forKey: Keys.captureLog) }
        get { defaults.bool(forKey: Keys.captureLog) }
    }
    
    var logLevel: LogLevel {
        get {
            return LogLevel(rawValue:defaults.integer(forKey: Keys.logLevel)) ?? .info
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.logLevel)
        }
    }
    
    var template: String {
        set { defaults.set(newValue, forKey: Keys.template) }
        get { defaults.string(forKey: Keys.template) ?? "" }
    }
    
    
    var passportNumber: String {
        set { defaults.set(newValue, forKey: Keys.passportNumber) }
        get { defaults.string(forKey: Keys.passportNumber) ?? "" }
    }
    var dateOfBirth: String {
        set { defaults.set(newValue, forKey: Keys.dateOfBirth) }
        get { defaults.string(forKey: Keys.dateOfBirth) ?? "" }
    }
    var dateOfExpiry: String {
        set { defaults.set(newValue, forKey: Keys.dateOfExpiry) }
        get { defaults.string(forKey: Keys.dateOfExpiry) ?? "" }
    }
    
    var imgBase64: String {
        set { defaults.set(newValue, forKey: Keys.imgBase64) }
        get { defaults.string(forKey: Keys.imgBase64) ?? "" }
    }
    var userInfo: UserInfo {
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                defaults.set(encoded, forKey: Keys.userInfo)
                objectWillChange.send()
            }
        }
        get {
            if let savedUserInfo = defaults.object(forKey: Keys.userInfo) as? Data {
                let decoder = JSONDecoder()
                if let loadedUserInfo = try? decoder.decode(UserInfo.self, from: savedUserInfo) {
                    return loadedUserInfo
                }
            }
            return UserInfo(name: "", clientId: "", image: "", idNum: "", expireDate: "", birthDate: "", registrationDate: "",registrationHour: "",QRCode: "",phoneNumber: "")
        }
    }


    
    @Published var passport : NFCPassportModel?
}


struct UserInfo : Codable{
    
    var name:String
    var clientId:String
    var image:String
    var idNum:String
    var expireDate:String
    var birthDate:String
    var registrationDate:String
    var registrationHour:String
    var QRCode:String
    var phoneNumber:String
    
    

}




