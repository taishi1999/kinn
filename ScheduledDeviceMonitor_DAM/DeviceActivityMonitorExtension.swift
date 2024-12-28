//
//  DeviceActivityMonitorExtension.swift
//  ScheduledDeviceMonitor_DAM
//
//  Created by 唐崎大志 on 2024/12/10.
//

import DeviceActivity
import Foundation
import ManagedSettings

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        NSLog("intervalDidStart")

        if let selection =  ShieldManager.shared.savedSelection().selection {
            NSLog("Saved selection: \(selection)")
            ShieldManager.shared.shieldActivities(selection: selection)
        } else {
            NSLog("No selection found")
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        NSLog("intervalDidEnd")
        ShieldManager.shared.removeAllShields()
        // Handle the end of the interval.
//        let database = DataBase()
//        guard let activityId = UUID(uuidString: activity.rawValue) else { return }
//        guard let application = database.getApplicationProfile(id: activityId) else { return }
//        let store = ManagedSettingsStore()
//        store.shield.applications?.insert(application.applicationToken)
//        database.removeApplicationProfile(application)
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        // Handle the event reaching its threshold.
        NSLog("eventDidReachThreshold")
        ShieldManager.shared.removeAllShields()
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)

        // Handle the warning before the interval starts.
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        // Handle the warning before the interval ends.
        NSLog("intervalWillEndWarning")
        ShieldManager.shared.removeAllShields()
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)

        // Handle the warning before the event reaches its threshold.
    }
}
