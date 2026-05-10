//
//  JPushManager.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/5/9.
//

import Combine
import Foundation
import UIKit
import UserNotifications

final class JPushManager: NSObject {
    static let shared = JPushManager()
    override private init() {}

    private let appKey = Keys.jpushApi
    private let channel = "App Store"

    #if DEBUG
    private let isProduction = false
    #else
    private let isProduction = true
    #endif

    let notificationTapped = PassthroughSubject<[AnyHashable: Any], Never>()
    let notificationReceived = PassthroughSubject<[AnyHashable: Any], Never>()

    func configure(
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        UNUserNotificationCenter.current().delegate = self

        let entity = JPUSHRegisterEntity()
        entity.types = Int(
            JPAuthorizationOptions.alert.rawValue |
                JPAuthorizationOptions.badge.rawValue |
                JPAuthorizationOptions.sound.rawValue
        )

        JPUSHService.register(
            forRemoteNotificationConfig: entity,
            delegate: self
        )

        JPUSHService.setup(
            withOption: launchOptions,
            appKey: appKey,
            channel: channel,
            apsForProduction: isProduction
        )

        observeJPushLogin()
        requestAPNsPermissionAndRegister()
        checkNotificationPermission()
    }

    private func requestAPNsPermissionAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            print("通知授权 granted:", granted)
            print("通知授权 error:", error?.localizedDescription ?? "nil")

            DispatchQueue.main.async {
                print("开始 registerForRemoteNotifications")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("authorizationStatus:", settings.authorizationStatus.rawValue)

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }

            case .denied:
                print("用户已经拒绝通知，需要去系统设置打开")

            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .badge, .sound]
                ) { granted, error in
                    print("通知授权 granted:", granted)
                    print("通知授权 error:", error?.localizedDescription ?? "nil")

                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }

            default:
                break
            }
        }
    }

    func registerDeviceToken(_ deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs deviceToken:", token)
    }

    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
        notificationReceived.send(userInfo)
    }

    func getRegistrationID() {
        JPUSHService.registrationIDCompletionHandler { code, registrationID in
            print("JPush registrationID code:", code)
            print("JPush registrationID:", registrationID ?? "nil")
        }
    }

    func setAlias(_ alias: String, seq: Int = 1001) {
        JPUSHService.setAlias(
            alias,
            completion: { code, alias, sequence in
                print("设置 alias:", code, alias ?? "", sequence)
            },
            seq: seq
        )
    }

    func deleteAlias(seq: Int = 1002) {
        JPUSHService.deleteAlias(
            { code, alias, sequence in
                print("删除 alias:", code, alias ?? "", sequence)
            },
            seq: seq
        )
    }

    func setTags(_ tags: Set<String>, seq: Int = 1003) {
        JPUSHService.setTags(
            tags,
            completion: { code, tags, sequence in
                print("设置 tags:", code, tags ?? [], sequence)
            },
            seq: seq
        )
    }

    func cleanBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        JPUSHService.setBadge(0)
    }

    private func observeJPushLogin() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(jpushLoginSuccess),
            name: NSNotification.Name.jpfNetworkDidLogin,
            object: nil
        )
    }

    @objc private func jpushLoginSuccess() {
        print("JPush 登录成功")
        getRegistrationID()
    }
}

extension JPushManager: UNUserNotificationCenterDelegate {}

extension JPushManager: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification) {}

    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable: Any]?) {}

    func jpushNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: (Int) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        JPUSHService.handleRemoteNotification(userInfo)
        notificationReceived.send(userInfo)

        print("前台收到推送:", userInfo)

        completionHandler(
            Int(
                // UNNotificationPresentationOptions.alert.rawValue |
                UNNotificationPresentationOptions.sound.rawValue |
                    UNNotificationPresentationOptions.badge.rawValue
            )
        )
    }

    func jpushNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        JPUSHService.handleRemoteNotification(userInfo)
        notificationTapped.send(userInfo)

        print("点击通知:", userInfo)

        completionHandler()
    }
}
