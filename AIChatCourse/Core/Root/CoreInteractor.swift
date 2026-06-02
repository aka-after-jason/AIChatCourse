//
//  CoreInteractor.swift
//  AIChatCourse
//
//  Created by Elaine on 2026/6/2.
//
import SwiftUI

/**
 Protocol-Oriented Programming
 
 Let's add the CoreInteractor to our app.
 This is a layer between the ViewModel and the Managers.
 */

@MainActor
struct CoreInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abtestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abtestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }
    
    // MARK: AuthManager
    var authUser: UserAuthInfoModel? {
        authManager.authUser
    }
    
    func getCurrentUserId() throws -> String {
        try authManager.getCurrentUserId()
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }
    
    func signInApple() async throws -> (user: UserAuthInfoModel, isNewUser: Bool) {
        try await authManager.signInApple()
    }

    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }
    
    // MARK: UserManager
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func login(auth: UserAuthInfoModel, isNewUser: Bool) async throws {
        try await userManager.login(auth: auth, isNewUser: isNewUser)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: profileColorHex)
    }
    
    func deleteUser() async throws {
        try await userManager.deleteUser()
    }
    
    // MARK: AIManager
    func generateImage(prompt: String) async throws -> UIImage {
        try await aiManager.generateImage(prompt: prompt)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
    
    // MARK: AvatarManager
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuthor(userId: userId)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await avatarManager.getAvatar(id: id)
    }
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    func removeAuthorIdFromAllUserAvatars(userId: String) async throws {
        try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: userId)
    }
    
    // MARK: ChatManager
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await chatManager.addChatMessage(chatId: chatId, message: message)
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: messageId, userId: userId)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await chatManager.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await chatManager.getAllChats(userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        chatManager.streamChatMessages(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        try await chatManager.deleteAllChatsForUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }
    
    // MARK: LogManager
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }

    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }

    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: CustomLogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }

    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackScreenEvent(event: event)
    }

    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackScreenEvent(event: event)
    }
    
    // MARK: PushManager
    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    // MARK: ABTestManager
    var activeABTestModel: ActiveABTestModel {
        abtestManager.activeABTestModel
    }
    
    var categoryRowTest: CategoryRowTestOption {
        activeABTestModel.categroyRowTest
    }
    
    var createAccountTest: Bool {
        activeABTestModel.createAccountTest
    }
    
    func override(updateABTestModel: ActiveABTestModel) throws {
        try abtestManager.override(updateABTestModel: updateABTestModel)
    }
    
    // MARK: PurchaseManager
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }

    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }
    
    @discardableResult
    func logIn(userId: String, attributes: PurchaseProfileAttributes? = nil) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.logIn(userId: userId, attributes: attributes)
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }
    
    // MARK: SHARED 因为 manager 里面有同名的方法, 这里都放在一起
    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
}
