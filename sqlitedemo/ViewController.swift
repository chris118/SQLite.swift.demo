//
//  ViewController.swift
//  sqlitedemo
//
//  Created by xiaopeng on 2017/7/7.
//  Copyright © 2017年 putao. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let dbPath = doumentDirectoryPath.appendingPathComponent("ptlog.sqlite")
        
        var db: Connection!
        let users = Table("users")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        
        do {
            db = try Connection(dbPath)
            
            try db.run(users.create { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(email, unique: true)
            })
            // CREATE TABLE "users" (
            //     "id" INTEGER PRIMARY KEY NOT NULL,
            //     "name" TEXT,
            //     "email" TEXT NOT NULL UNIQUE
            // )
        } catch  {
            print("existed table !")
        }
        
        do {

            let insert = users.insert(name <- "Alice", email <- "alice@mac.com")
            let rowid = try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            
            for user in try db.prepare(users) {
                print("id: \(user[id]), name: \(String(describing: user[name])), email: \(user[email])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
            }
            // SELECT * FROM "users"
            
            let alice = users.filter(id == rowid)
            
            try db.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
            
//            try db.run(alice.delete())
            // DELETE FROM "users" WHERE ("id" = 1)
            
            let count = try db.scalar(users.count) // 0
            print("count: \(count)")
            // SELECT count(*) FROM "users"
            
        } catch {
            print("db error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

