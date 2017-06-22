//
//  Employee.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-14.
//

import StORM
import PostgresStORM
import SwiftRandom

public class Employee: PostgresStORM {
	public var id						= ""
	public var first					= ""
	public var last						= ""
	public var email					= ""
	public var status					= 0


	public override init() {
		super.init()
	}

	public init(_ f: String, _ l: String, _ e: String) {
		super.init()
		first = f
		last = l
		email = e
		status = 1
	}

	let _r = URandom()

	public func makeID() {
		id = _r.secureToken
	}

	public static func runSetup() {
		do {
			let this = Employee()
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
		first			= this.data["first"] as? String			?? ""
		last			= this.data["last"] as? String			?? ""
		email			= this.data["email"] as? String			?? ""
		status			= this.data["status"] as? Int			?? 0
	}

	public func rows() -> [Employee] {
		var rows = [Employee]()
		for i in 0..<self.results.rows.count {
			let row = Employee()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}


	public static func list(_ filterStatus: Int = -1) -> [[String: Any]] {


		var filtertxt = "true"
		var params = [Any]()
		if filterStatus > -1 {
			filtertxt = "status = $1"
			params.append(filterStatus)
		}

		var users = [[String: Any]]()
		let t = Employee()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? t.select(
			columns: [],
			whereclause: filtertxt,
			params: params,
			orderby: ["last, first, email"],
			cursor: cursor
		)


		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["first"] = row.first
			r["last"] = row.last
			r["email"] = row.email
			r["status"] = "Active"
			if row.status == 0 {
				r["status"] = "Inactive"
			} else if row.status == 2 {
				r["status"] = "TEST"
			}

			// how many complete
			let complete = Answer()
			try? complete.find(["uid":row.id, "completed": "1"])
			r["complete"] = complete.results.cursorData.totalRecords

			// of how many in total
			let of = Answer()
			try? of.find(["uid":row.id])
			r["of"] = of.results.cursorData.totalRecords


			users.append(r)
		}
		return users
	}


	public func responses(questions: [[String: Any]]) -> [[String: Any]] {
		let ans = Answer()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? ans.select(
			columns: [],
			whereclause: "uid = $1",
			params: [id],
			orderby: ["year DESC, month DESC"],
			cursor: cursor
		)
		var responses = [[String: Any]]()
		for row in ans.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["year"] = row.year
			r["month"] = row.month
			r["note"] = row.data["more"] as? String ?? ""
			r["completed"] = false
			if row.completed == 1 {
				r["completed"] = true
			}

			// pull out answers in the same order (or a zero) as in the question array
			var x = [[String:Any]]()
			var total = 0
			questions.forEach{
				q in
				let questionid = q["id"] as? String ?? ""
				if let d = row.data[questionid] {
					x.append(["response":d])
					total += Int("\(d)") ?? 0
				} else {
					x.append(["response":0])
				}
			}
			if total > 0 {
				r["average"] = Double(total) / Double(x.count)
			}
			r["answers"] = x
			responses.append(r)
		}
		return responses

	}
}
