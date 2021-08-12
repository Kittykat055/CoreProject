//
//  LessonService.swift
//  KeystonePark
//
//  Created by Kirthi Maharaj on 2021/08/12.
//

import Foundation
import CoreData

enum LessonType: String {
    case ski, snowboard
}
 typealias StudentHandler = (Bool, [Student]) -> ()

class LessonService {
    
    private let moc: NSManagedObjectContext
    private var students = [Student]()
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    //Mark: - Public
    //READ
    func getAllStudents() -> [Student]? {
        let sortByLesson = NSSortDescriptor(key: "lesson.type", ascending: true)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortByLesson, sortByName]
        let request: NSFetchRequest<Student> = Student.fetchRequest()
        request.sortDescriptors = sortDescriptors
        do {
            students = try moc.fetch(request)
            return students
        } catch let error as NSError {
            print("Error fetching students: \(error)")
        }
        return nil
    }
    //CREATE
    func addStudent(name: String, for type: LessonType, completion: StudentHandler){
        let student = Student(context: moc)
        student.name = name
        
        if let lesson = lessonExists(type) {
            register(student, for: lesson)
            students.append(student)
            
            completion(true, students)
        }
        save()
    }
    
    // Mark: - Private
    private func lessonExists(_ type: LessonType) -> Lesson? {
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "type = %@", type.rawValue)
        var lesson: Lesson?
        
        do {
            let result = try moc.fetch(request)
            lesson = result.isEmpty ? addNew(lesson: type) : result.first
        } catch let error as NSError {
            print("Error getting lesson \(error.localizedDescription)")
        }
        return lesson
    }
    
    private func addNew(lesson type: LessonType)-> Lesson{
       let lesson = Lesson(context: moc)
        lesson.type = type.rawValue
        
        return lesson
    }
    private func register(_ student: Student, for lesson: Lesson){
        student.lesson = lesson
    }
    
    private func save(){
        do {
            try moc.save()
        } catch let error as NSError {
            print("Save failed: \(error.localizedDescription)")
        }
    }
}