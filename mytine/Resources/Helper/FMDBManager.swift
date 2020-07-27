//
//  FMDBManager.swift
//  mytine
//
//  Created by 남수김 on 2020/07/26.
//  Copyright © 2020 황수빈. All rights reserved.
//

import Foundation
import FMDB

class FMDBManager {
    
    enum TableType {
        case week, day, rootine
        
        var tableName: String {
            switch self {
            case .week:
                return "WeekRootine"
            case .day:
                return "DayRootine"
            case .rootine:
                return "Rootine"
            }
        }
    }
    static let shared = FMDBManager()
    private let database: FMDatabase
    private let dbName = "test2.sqlite"
    private let weekTableName = "WeekRootine"
    private let dayTableName = "DayRootine"
    private let rootineTableName = "Rootine"
    
    init() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(dbName)
        database = FMDatabase(url: fileURL)
    }
    
    // MARK: DB Manager
    
    func createTable() -> Bool {
        
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        do {
            try database.executeUpdate("create table if not exists \(weekTableName)(week Integer Primary key AutoIncrement, rootinesIdx Text)", values: nil)
            
            try database.executeUpdate("create table if not exists \(dayTableName)(id Integer Primary key, retrospect Text, week Integer, completes Text)", values: nil)
            
            try database.executeUpdate("create table if not exists \(rootineTableName)(id Integer Primary key AutoIncrement, emoji Text, title Text, goal Text, repeatDays Text, count Integer)", values: nil)
        } catch {
            print("create fail")
            database.close()
            return false
        }
        database.close()
        return true
    }
    
    func dropDB(type: TableType) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        do {
            try database.executeUpdate("drop table \(type.tableName)", values: nil)
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
        database.close()
        return true
    }
    
    // MARK: WeekRootine Manager
    func addWeek() -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        do {
            try database.executeUpdate("insert into \(weekTableName) (rootinesIdx) values (?)", values: [""])
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
        
        database.close()
        return true
    }
    
    // 0일때 모든 주차 조회
    func selectWeekRootine(week: Int) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        do {
            var queryString: String
            if week == 0 {
                queryString = "select * from \(weekTableName)"
            } else {
                queryString = "select * from \(weekTableName) where week = \(week)"
            }
            let rs = try database.executeQuery(queryString, values: nil)
            
            while rs.next() {
                let week: Int32 = rs.int(forColumn: "week")
                let rootinesIdx: String = rs.string(forColumn: "rootinesIdx") ?? ""
                
                print("week \(week) ::::: rootinesIdx \(rootinesIdx)")
            }
           
        } catch {
            print("Unable to open database")
            database.close()
            return false
        }
        
        database.close()
        return true
    }
    
    func updateWeekRootine(rootinesList: [Int], week: Int) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        let rootines = rootinesList.map {String($0)}
        let rootineString = rootines.joined(separator: " ")
        do {
            try database.executeUpdate("update \(weekTableName) set rootinesIdx = ? where week = ?", values: [rootineString, week])
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
        database.close()
        return true
    }
    
    // MARK: DayRootine Manager
    func createDayRootine(rootine: DayRootine) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        do {
            try database.executeUpdate("insert into \(dayTableName) (id, retrospect, week, complete) values (?,?,?,?)",
                values: [rootine.id, rootine.retrospect, rootine.week, rootine.getComplete()])
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
        
        database.close()
        return true
    }
    
    // 0이면 모두 조회
    func selectDayRootine(week: Int) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        do {
            var queryString: String
            if week == 0 {
                queryString = "select * from \(dayTableName)"
            } else {
                queryString = "select * from \(dayTableName) where week = \(week)"
            }
            let rs = try database.executeQuery(queryString, values: nil)
            
            while rs.next() {
                let id: String = rs.string(forColumn: "id") ?? ""
                let retrospect: String = rs.string(forColumn: "retrospect") ?? ""
                let week: Int32 = rs.int(forColumn: "week")
                let completes: String = rs.string(forColumn: "completes") ?? ""
                
                print("id \(id) :::: week \(week) ::::: completes \(completes)")
            }
           
        } catch {
            print("Unable to open database")
            database.close()
            return false
        }
        
        database.close()
        return true
    }
    
    func updateDayRootine(rootine: DayRootine) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        do {
            try database.executeUpdate("update \(dayTableName) set retrospect = ?, completes = ?, where id = ?",
                values: [rootine.retrospect, rootine.getComplete(), rootine.id])
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
        database.close()
        return true
    }
    
    func createRootine(rootine: Rootine) -> Bool {
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        do {
            try database.executeUpdate("insert into \(dayTableName) (emoji, title, goal, repeatDays, count) values (?,?,?,?,?)",
                values: [rootine.emoji, rootine.title, rootine.title, rootine.goal, rootine.getRepeatDay(), rootine.count])
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
        
        database.close()
        return true
    }
}

/*
 class WeekRootine {
   let rootinesIdx: [Int] = [1,3,4,9] //해당 루틴
   let week = 1 //주차, PK
 }

 class DayRootine {
   let id = 20200720 //idx를위한구분, PK
   let retrospect: String = "회고를 적어따" //회고
   let week = 1 // 주차구분을위한
   let complete = [true, false, true, false] //완료여부 - WeekRootine과 매칭 1완료
 }

 //////////
 class Rootine {
   let idx = 1 //id, PK
   let iconImg: String //이모지
   let title: String
   let goal: String
   let repeatDays = [.mon, .fri] //반복요일
   let count = 1 // 0일때 디비에서 삭제
 }
 */
