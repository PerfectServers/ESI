//
//  AnswerLog.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-14.
//

import StORM
import PostgresStORM
import SwiftRandom

public class AnswerLog: PostgresStORM {
	public var id						= ""
	public var first					= ""
	public var last						= ""
	public var email					= ""
	public var status					= 0

	let _r = URandom()

	public func makeID() {
		id = _r.secureToken
	}

	public static func runSetup() {
		do {
			let this = AnswerLog()
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

	public func rows() -> [AnswerLog] {
		var rows = [AnswerLog]()
		for i in 0..<self.results.rows.count {
			let row = AnswerLog()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
}

