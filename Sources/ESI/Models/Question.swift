//
//  Question.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-14.
//


import StORM
import PostgresStORM
import SwiftRandom

public class Question: PostgresStORM {
	public var id						= ""
	public var name						= ""
	public var txt						= ""
	public var displayorder				= 100
	public var status					= 0

	let _r = URandom()

	public func makeID() {
		id = _r.secureToken
	}

	public static func runSetup() {
		do {
			let this = Question()
			try this.setup()
		} catch {
			print(error)
		}
	}

	public func commit(){
		do {
			if id.isEmpty {
				makeID()
				try create()
			} else {
				try save()
			}
		} catch {
			print(error)
		}
	}

	override public func to(_ this: StORMRow) {
		id				= this.data["id"] as? String			?? ""
		name			= this.data["name"] as? String			?? ""
		txt				= this.data["txt"] as? String			?? ""
		displayorder	= this.data["displayorder"] as? Int		?? 0
		status			= this.data["status"] as? Int			?? 0
	}

	public func rows() -> [Question] {
		var rows = [Question]()
		for i in 0..<self.results.rows.count {
			let row = Question()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	public static func list() -> [[String: Any]] {
		var list = [[String: Any]]()
		let t = Question()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? t.select(
			columns: [],
			whereclause: "true",
			params: [],
			orderby: ["displayorder"],
			cursor: cursor
		)


		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["name"] = row.name
			r["txt"] = row.txt
			r["status"] = "Active"
			if row.status == 0 {
				r["status"] = "Inactive"
			}
			list.append(r)
		}
		return list
	}

	public static func survey() -> [[String: Any]] {
		var list = [[String: Any]]()
		let t = Question()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		var orderby = "displayorder"
		if configRandomOrder == "true" { orderby = "random()" }

		try? t.select(
			columns: [],
			whereclause: "status = $1",
			params: ["1"],
			orderby: [orderby],
			cursor: cursor
		)

		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["name"] = row.name
			r["txt"] = row.txt
			list.append(r)
		}
		return list
	}

}
