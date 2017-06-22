//
//  EmailQueue.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-20.
//


import StORM
import PostgresStORM
import SwiftRandom
import SwiftMoment
import PerfectSMTP
import LocalAuthentication
import PerfectMarkdown

public class EmailQueue: PostgresStORM {
	public var id						= ""
	public var queueddate				= 0
	public var recipient				= ""
	public var properties				= [String:Any]()
	public var status					= 0
	public var sentdate					= 0
	public var code						= ""

	let _r = URandom()

	public func makeID() {
		id = _r.secureToken
	}

	public static func runSetup() {
		do {
			let this = EmailQueue()
			try this.setup()
		} catch {
			print(error)
		}
	}

	public static func queue(to: String, name: String, subject: String, html: String = "", body: String = "") throws -> EmailQueue {
		let q = EmailQueue()
		q.recipient = to
		q.properties["recipientname"] = name
		q.properties["subject"] = subject
		q.properties["html"] = html
		q.properties["body"] = body
		if html.isEmpty && body.isEmpty {
			throw EmailQueueError.noBody
		}
		q.commit()
		return q
	}

	public func commit(){
		do {
			if id.isEmpty {
				makeID()
				let th = moment()
				queueddate = Int(th.epoch())
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
		queueddate		= this.data["queueddate"] as? Int		?? 0
		recipient		= this.data["recipient"] as? String		?? ""
		if let detailObj = this.data["properties"] {
			properties = detailObj as? [String:Any] ?? [String:Any]()
		}
		status			= this.data["status"] as? Int			?? 0
		sentdate		= this.data["sentdate"] as? Int			?? 0
		code			= this.data["code"] as? String			?? ""
	}

	public func rows() -> [EmailQueue] {
		var rows = [EmailQueue]()
		for i in 0..<self.results.rows.count {
			let row = EmailQueue()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	public static func check(){
		let client = SMTPClient(url: SMTPConfig.mailserver, username: SMTPConfig.mailuser, password:SMTPConfig.mailpass)
		let sender = Recipient(name: SMTPConfig.mailfromname, address: SMTPConfig.mailfromaddress)
		let t = EmailQueue()
		let cursor = StORMCursor(limit: queueSize,offset: 0)
		try? t.select(
			columns: [],
			whereclause: "status = $1 AND sentdate = $2 AND code = $3",
			params: [0,0,""],
			orderby: ["queueddate"],
			cursor: cursor
		)
		let th = moment()


		for row in t.rows() {
			if let subject = row.properties["subject"], !(subject as? String ?? "").isEmpty,
				let body = row.properties["body"], !(body as? String ?? "").isEmpty,
				let recipientname = row.properties["recipientname"], !(recipientname as? String ?? "").isEmpty

				{

				let email = EMail(client: client)
				email.from = sender
				email.subject = subject as? String ?? ""
				email.to = [Recipient(name: recipientname as? String ?? "", address: row.recipient)]
				email.html = (body as? String ?? "").markdownToHTML ?? ""

				do {
					try email.send { code, header, body in
						/// response info from mail server
						row.status = 1
						row.sentdate = Int(th.epoch())
						row.code = "\(code)"
						do {
							try row.save()
						} catch {
							print(error)
						}
					}//end send
				} catch {
					print(error)
					row.code = "\(error)"
					do {
						try row.save()
					} catch {
						print(error)
					}

				}

			}
		}

	}

}


public enum EmailQueueError: Error {
	case noError, noBody
}
