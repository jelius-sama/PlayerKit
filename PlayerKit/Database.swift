// SPDX-License-Identifier: See LICENSE
//
// Database.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import Foundation
import SQLite3

final class Database {
    static let shared = Database()

    public var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() {
        let fileURL = Self.databaseURL

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            fatalError("Unable to open database at \(fileURL.path)")
        }
    }

    private func createTables() {
        let sql = """
            CREATE TABLE IF NOT EXISTS directories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                path TEXT NOT NULL UNIQUE,
                bookmark BLOB NOT NULL,
                date_added REAL NOT NULL
            );
            """

        execute(sql: sql)
    }

    private func execute(sql: String) {
        var errorMessage: UnsafeMutablePointer<Int8>?

        if sqlite3_exec(db, sql, nil, nil, &errorMessage) != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Unknown error"
            fatalError("SQLite error: \(message)")
        }
    }

    static var databaseURL: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let directory = appSupport.appendingPathComponent("PlayerKit", isDirectory: true)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }

        return directory.appendingPathComponent("PlayerKit.sqlite")
    }
}
