/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import UIKit

/**
    A condition for verifying that we can present alerts to the user via
    `UILocalNotification` and/or remote notifications.
*/
struct UserNotificationCondition: OperationCondition {
    
    enum Behavior {
        /// Merge the new `UIUserNotificationSettings` with the `currentUserNotificationSettings`.
        case Merge

        /// Replace the `currentUserNotificationSettings` with the new `UIUserNotificationSettings`.
        case Replace
    }
    
    static let name = "UserNotification"
    static let currentSettings = "CurrentUserNotificationSettings"
    static let desiredSettings = "DesiredUserNotificationSettigns"
    static let isMutuallyExclusive = false
    
    let settings: UIUserNotificationSettings
    let application: UIApplication
    let behavior: Behavior
    
    /**
        The designated initializer.
        
        - parameter settings: The `UIUserNotificationSettings` you wish to be
            registered.

        - parameter application: The `UIApplication` on which the `settings` should
            be registered.

        - parameter behavior: The way in which the `settings` should be applied
            to the `application`. By default, this value is `.Merge`, which means
            that the `settings` will be combined with the existing settings on the
            `application`. You may also specify `.Replace`, which means the `settings`
            will overwrite the exisiting settings.
    */
    init(settings: UIUserNotificationSettings, application: UIApplication, behavior: Behavior = .Merge) {
        self.settings = settings
        self.application = application
        self.behavior = behavior
    }
    
    func dependencyForOperation(operation: EQOperation) -> Operation? {
        return UserNotificationPermissionOperation(settings: settings, application: application, behavior: behavior)
    }
    
    func evaluateForOperation(operation: EQOperation, completion: (OperationConditionResult) -> Void) {
        let result: OperationConditionResult
        
        let current = application.currentUserNotificationSettings

        switch (current, settings)  {
        case (let current?, let settings) where current.contains(settings: settings):
                result = .Satisfied

            default:
                let error = NSError(code: .ConditionFailed, userInfo: [
                    OperationConditionKey: type(of: self).name,
                    type(of: self).currentSettings: current ?? NSNull(),
                    type(of: self).desiredSettings: settings
                ])
                
                result = .Failed(error)
        }
        
        completion(result)
    }
}

/**
    A private `Operation` subclass to register a `UIUserNotificationSettings`
    object with a `UIApplication`, prompting the user for permission if necessary.
*/
private class UserNotificationPermissionOperation: EQOperation {
    let settings: UIUserNotificationSettings
    let application: UIApplication
    let behavior: UserNotificationCondition.Behavior
    
    init(settings: UIUserNotificationSettings, application: UIApplication, behavior: UserNotificationCondition.Behavior) {
        self.settings = settings
        self.application = application
        self.behavior = behavior
        
        super.init()

        addCondition(condition: AlertPresentation())
    }
    
    override func execute() {
        DispatchQueue.global(qos: .background).async {

            // Background Thread

            DispatchQueue.main.async {
                // Run UI Updates
                let current = self.application.currentUserNotificationSettings

                let settingsToRegister: UIUserNotificationSettings

                switch (current, self.behavior) {
                case (let currentSettings?, .Merge):
                    settingsToRegister = currentSettings.settingsByMerging(settings: self.settings)

                default:
                    settingsToRegister = self.settings
                }

                self.application.registerUserNotificationSettings(settingsToRegister)
            }
        }
    }
}
    
#endif
