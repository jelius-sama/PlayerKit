// SPDX-License-Identifier: See LICENSE
//
// LibraryDirectory.swift
// PlayerKit
//
// Copyright (c) 2026 Jelius <personal@jelius.dev>
//
// This file is part of PlayerKit.
// See the LICENSE file in the project root for license information.
//

import Foundation
import SQLite3

struct LibraryDirectory: Identifiable {
    let id: Int64
    let path: String
    let bookmark: Data
    let dateAdded: Date
}

extension Database {
    func insertDirectory(path: String, bookmark: Data) {
        // let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        let sql = """
            INSERT OR IGNORE INTO directories (path, bookmark, date_added)
            VALUES (?, ?, ?);
            """

        var statement: OpaquePointer?
        sqlite3_prepare_v2(db, sql, -1, &statement, nil)

        sqlite3_bind_text(statement, 1, path, -1, SQLITE_TRANSIENT)
        sqlite3_bind_blob(
            statement, 2, (bookmark as NSData).bytes, Int32(bookmark.count), SQLITE_TRANSIENT)
        sqlite3_bind_double(statement, 3, Date().timeIntervalSince1970)

        if sqlite3_step(statement) != SQLITE_DONE {
            sqlite3_finalize(statement)
            return
        }

        sqlite3_finalize(statement)
    }

    func fetchDirectories() -> [LibraryDirectory] {
        let sql = """
            SELECT id, path, bookmark, date_added
            FROM directories
            ORDER BY date_added ASC;
            """

        var result: [LibraryDirectory] = []
        var statement: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &statement, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            let path = String(cString: sqlite3_column_text(statement, 1))
            let bookmarkData = Data(
                bytes: sqlite3_column_blob(statement, 2),
                count: Int(sqlite3_column_bytes(statement, 2))
            )
            let timestamp = sqlite3_column_double(statement, 3)

            result.append(
                LibraryDirectory(
                    id: id,
                    path: path,
                    bookmark: bookmarkData,
                    dateAdded: Date(timeIntervalSince1970: timestamp)
                )
            )
        }

        sqlite3_finalize(statement)
        return result
    }

    func isDirectoryTableEmpty() -> Bool {
        let sql = "SELECT COUNT(*) FROM directories;"
        var statement: OpaquePointer?

        sqlite3_prepare_v2(db, sql, -1, &statement, nil)
        sqlite3_step(statement)

        let count = sqlite3_column_int(statement, 0)
        sqlite3_finalize(statement)

        return count == 0
    }
}
