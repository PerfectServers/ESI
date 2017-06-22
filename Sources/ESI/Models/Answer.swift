//
//  Answer.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-14.
//

import StORM
import PostgresStORM
import SwiftRandom
import SwiftMoment

public class Answer: PostgresStORM {
	public var id						= ""
	public var uid						= ""
	public var data						= [String:Any]()
	public var link						= ""
	public var year						= 0
	public var month					= 0
	public var completed				= 0
	public var datecompleted			= 0

	let _r = URandom()

	public func makeID() { id = _r.secureToken }
	public func makelink() { link = _r.secureToken }

	public static func runSetup() {
		do {
			let this = Answer()
			try this.setup()
		} catch {
			print(error)
		}
	}

	public func commit(){
		do {
			if id.isEmpty {
				makeID()
				makelink()
				if year == 0 { makeMonthYear() }
				try create()
			} else {
				completed = 1
				let th = moment()
				datecompleted = Int(th.epoch())
				try save()
			}
		} catch {
			print(error)
		}
	}

	func makeMonthYear(){
		let today = moment()
		year = today.year
		month = today.month
	}

	override public func to(_ this: StORMRow) {
		id				= this.data["id"] as? String			?? ""
		uid				= this.data["uid"] as? String			?? ""
		if let detailObj = this.data["data"] {
			data = detailObj as? [String:Any] ?? [String:Any]()
		}
		link			= this.data["link"] as? String			?? ""
		year			= this.data["year"] as? Int				?? 0
		month			= this.data["month"] as? Int			?? 0
		completed		= this.data["completed"] as? Int		?? 0
		datecompleted	= this.data["datecompleted"] as? Int	?? 0
	}

	public func rows() -> [Answer] {
		var rows = [Answer]()
		for i in 0..<self.results.rows.count {
			let row = Answer()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
}
