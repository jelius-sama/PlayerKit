//
//  DatabaseManager.swift
//  PlayerKit
//
//  Created by Jelius Basumatary on 15/01/26.
//

import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTable()
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(
                for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("PlayerKit")

        try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)
        let dbPath = fileURL.appendingPathComponent("PlayerKit.sqlite").path

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }

    private func createTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS directories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                path TEXT UNIQUE NOT NULL,
                bookmark BLOB NOT NULL,
                added_date TEXT NOT NULL
            );
            """

        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
        }
    }

    func addDirectory(path: String, bookmark: Data) -> Bool {
        let insertQuery =
            "INSERT OR REPLACE INTO directories (path, bookmark, added_date) VALUES (?, ?, ?);"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Failed to prepare insert statement")
            return false
        }

        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: Date())

        sqlite3_bind_text(statement, 1, (path as NSString).utf8String, -1, nil)
        sqlite3_bind_blob(statement, 2, (bookmark as NSData).bytes, Int32(bookmark.count), nil)
        sqlite3_bind_text(statement, 3, (dateString as NSString).utf8String, -1, nil)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)

        if success {
            print("Directory added to database: \(path)")
        }

        return success
    }

    func removeDirectory(path: String) -> Bool {
        let deleteQuery = "DELETE FROM directories WHERE path = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_text(statement, 1, (path as NSString).utf8String, -1, nil)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    func getAllDirectories() -> [SavedDirectory] {
        let query =
            "SELECT id, path, bookmark, added_date FROM directories ORDER BY added_date DESC;"
        var statement: OpaquePointer?
        var directories: [SavedDirectory] = []

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Failed to prepare select statement")
            return directories
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let path = String(cString: sqlite3_column_text(statement, 1))

            // Get bookmark data
            if let bookmarkBlob = sqlite3_column_blob(statement, 2) {
                let bookmarkSize = sqlite3_column_bytes(statement, 2)
                let bookmarkData = Data(bytes: bookmarkBlob, count: Int(bookmarkSize))

                let dateString = String(cString: sqlite3_column_text(statement, 3))

                let dateFormatter = ISO8601DateFormatter()
                let date = dateFormatter.date(from: dateString) ?? Date()

                directories.append(
                    SavedDirectory(
                        id: id,
                        path: path,
                        bookmarkData: bookmarkData,
                        addedDate: date
                    ))
            }
        }

        sqlite3_finalize(statement)
        print("Loaded \(directories.count) directories from database")

        return directories
    }

    deinit {
        sqlite3_close(db)
    }
}
