//
//  TaskItem+Mock.swift
import Foundation

extension TaskItem {
    static let createdMockList: [TaskItem] = [
        // Bana atanan tasklar — assigneeIds'e "current-user" ekledik
        TaskItem(
            id: "created-1",
            title: "Iconlary ýygnamaly",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            status: .inProgress,
            department: "UI Design",
            departmentId: "dept-1",
            assignees: [
                TaskAssignee(id: "a1", user: User(id: "u1", name: "Nurgeldi Rejepow", phone: "+99362000001"), status: .waiting),
                TaskAssignee(id: "a2", user: User(id: "u2", name: "Latif tagma", phone: "+99362000002"), status: .completed),
                TaskAssignee(id: "a3", user: User(id: "u3", name: "Haljanow Haknazar", phone: "+99362000003"), status: .inProgress),
            ],
            assigneeIds: ["current-user", "u1", "u2", "u3"], // ✅ current-user eklendi
            createdAt: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 9))!,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 12))!,
            files: [], comments: [], number: 1
        ),
        TaskItem(
            id: "created-2",
            title: "Iconlary ýygnamaly",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            status: .inProgress,
            department: "UI Design",
            departmentId: "dept-1",
            assignees: [
                TaskAssignee(id: "b1", user: User(id: "u4", name: "Nurgeldi Rejepow", phone: "+99362000004"), status: .cancelled),
                TaskAssignee(id: "b2", user: User(id: "u5", name: "Latif tagma", phone: "+99362000005"), status: .completed),
                TaskAssignee(id: "b3", user: User(id: "u6", name: "Haljanow Haknazar", phone: "+99362000006"), status: .inProgress),
            ],
            assigneeIds: ["current-user", "u4", "u5", "u6"], // ✅ current-user eklendi
            createdAt: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 9))!,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 12))!,
            files: [], comments: [], number: 1
        ),
        TaskItem(
            id: "created-3",
            title: "Backend API döretmek",
            description: "Ulanyjy dolandyryş we task API endpoint-lerini taýýarlamaly.",
            status: .waiting,
            department: "Backend",
            departmentId: "dept-2",
            assignees: [
                TaskAssignee(id: "c1", user: User(id: "u7", name: "Myrat Oraz", phone: "+99362000007"), status: .waiting),
                TaskAssignee(id: "c2", user: User(id: "u8", name: "Serdar Durdow", phone: "+99362000008"), status: .inProgress),
            ],
            assigneeIds: ["u7", "u8"], // ✅ bu "İş döretmek"te görünür
            createdAt: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 5))!,
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 10))!,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 20))!,
            files: [], comments: [], number: 1
        ),
        
        // ✅ Şahsy tasklar — departmentId: "sahsy"
        TaskItem(
            id: "personal-1",
            title: "UX logika",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            status: .waiting,
            department: "Şahsy",
            departmentId: "sahsy",
            assignees: [],
            assigneeIds: ["current-user"],
            createdAt: Date(),
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 9))!,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 12))!,
            files: [], comments: [], number: 1
        ),
        TaskItem(
            id: "personal-2",
            title: "UX logika",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            status: .completed,
            department: "Şahsy",
            departmentId: "sahsy",
            assignees: [],
            assigneeIds: ["current-user"],
            createdAt: Date(),
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 9))!,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 12))!,
            files: [], comments: [], number: 1
        ),
        TaskItem(
            id: "personal-3",
            title: "UX logika",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            status: .cancelled,
            department: "Şahsy",
            departmentId: "sahsy",
            assignees: [],
            assigneeIds: ["current-user"],
            createdAt: Date(),
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 9))!,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 12))!,
            files: [], comments: [], number: 1
        ),
    ]
}
