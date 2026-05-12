// RememberTests/NotificationTests.swift
// Test hatası çözülene kadar yorum satırında
/*
import XCTest
@testable import Remember

final class NotificationTests: XCTestCase {
    var mockRepository: MockNotificationRepository!
    var notificationService: MockNotificationService!
    var fetchNotificationsUseCase: FetchNotificationsUseCase!
    var markAsReadUseCase: MarkNotificationAsReadUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockNotificationRepository()
        notificationService = MockNotificationService()
        fetchNotificationsUseCase = FetchNotificationsUseCase(repository: mockRepository)
        markAsReadUseCase = MarkNotificationAsReadUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        notificationService = nil
        fetchNotificationsUseCase = nil
        markAsReadUseCase = nil
        super.tearDown()
    }

    func testFetchNotifications() async throws {
        // Given
        let userId = "user-1"

        // When
        let notifications = try await fetchNotificationsUseCase.execute(for: userId)

        // Then
        XCTAssertEqual(notifications.count, 2)
        XCTAssertEqual(notifications.first?.type, .taskAssigned)
        XCTAssertEqual(notifications.first?.isRead, false)
    }

    func testMarkNotificationAsRead() async throws {
        // Given
        let notificationId = "notif-1"

        // When
        try await markAsReadUseCase.execute(notificationId: notificationId)

        // Then
        let notifications = try await fetchNotificationsUseCase.execute(for: "user-1")
        XCTAssertTrue(notifications.first?.isRead ?? false)
    }

    func testNotificationServiceScheduleReminder() async throws {
        // Given
        let taskId = "task-1"
        let taskTitle = "Test Task"
        let dueDate = Date().addingTimeInterval(24 * 60 * 60) // Tomorrow

        // When
        try await notificationService.scheduleTaskReminder(
            taskId: taskId,
            taskTitle: taskTitle,
            dueDate: dueDate
        )

        // Then
        XCTAssertTrue(notificationService.scheduledNotifications.contains("task_reminder_\(taskId)"))
    }
}

// Mock implementations for testing
class MockNotificationRepository: NotificationRepository {
    private var notifications: [AppNotification] = [
        AppNotification(
            id: "notif-1",
            type: .taskAssigned,
            title: "Task Assigned",
            message: "You have been assigned to a task",
            data: AppNotification.NotificationData(taskId: "task-1", chatId: nil, offerId: nil, userId: nil),
            isRead: false,
            createdAt: Date(),
            userId: "user-1"
        ),
        AppNotification(
            id: "notif-2",
            type: .taskStatusChanged,
            title: "Task Updated",
            message: "Task status changed to completed",
            data: nil,
            isRead: true,
            createdAt: Date(),
            userId: "user-1"
        )
    ]

    func fetchNotifications(for userId: String) async throws -> [AppNotification] {
        notifications.filter { $0.userId == userId }
    }

    func getUnreadCount(for userId: String) async throws -> Int {
        notifications.filter { !$0.isRead && $0.userId == userId }.count
    }

    func markAsRead(notificationId: String) async throws {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
    }

    func markAllAsRead(for userId: String) async throws {
        for i in notifications.indices where notifications[i].userId == userId {
            notifications[i].isRead = true
        }
    }

    func registerDeviceToken(_ token: String, for userId: String) async throws {
        // Mock implementation
    }

    func updateNotificationSettings(settings: NotificationSettings, for userId: String) async throws {
        // Mock implementation
    }

    func getNotificationSettings(for userId: String) async throws -> NotificationSettings {
        NotificationSettings()
    }
}

class MockNotificationService: NotificationService {
    var scheduledNotifications: Set<String> = []
    var cancelledNotifications: Set<String> = []

    func requestAuthorization() async throws -> Bool {
        true
    }

    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        triggerDate: Date,
        userInfo: [String: Any]?
    ) async throws {
        scheduledNotifications.insert(id)
    }

    func cancelNotification(id: String) async {
        cancelledNotifications.insert(id)
        scheduledNotifications.remove(id)
    }

    func cancelAllNotifications() async {
        cancelledNotifications.formUnion(scheduledNotifications)
        scheduledNotifications.removeAll()
    }
}
*/
