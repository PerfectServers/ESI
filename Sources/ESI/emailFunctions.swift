//
//  emailFunctions.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-20.
//

class EmailFunctions {
	public static func queueInitialEmail(_ sendOne: String) -> String {
		let testing = Employee()
		do{
			try testing.get(sendOne)

			// save answer stub
			let ans = Answer()
			ans.uid = testing.id
			ans.commit()

			// form email
			var txt = configEmailText
			txt = txt.stringByReplacing(string: "{name}", withString: "\(testing.first) \(testing.last)")
			txt = txt.stringByReplacing(string: "{link}", withString: "\(baseURL)/survey/\(ans.link)")

			// queue email
			let _ = try EmailQueue.queue(to: testing.email, name: "\(testing.first) \(testing.last)", subject: configEmailSubject, body: txt)
			return "<div class=\"row error\">Queued ESI survey to: \(testing.email)</div>"
		} catch {
			print(error)
			return "<div class=\"row error\">Error queuing ESI survey email: \(error)</div>"
		}
	}

	public static func queueReminderEmail(_ sendOne: String) -> String {
		let testing = Employee()
		do{
			try testing.get(sendOne)

			// save answer stub
			let ans = Answer()
			ans.uid = testing.id
			ans.commit()

			// form email
			var txt = configEmailText
			txt = txt.stringByReplacing(string: "{name}", withString: "\(testing.first) \(testing.last)")
			txt = txt.stringByReplacing(string: "{link}", withString: "\(baseURL)/survey/\(ans.link)")

			// queue email
			let _ = try EmailQueue.queue(to: testing.email, name: "\(testing.first) \(testing.last)", subject: configEmailSubject, body: txt)
			return "<div class=\"row error\">Queued ESI survey to: \(testing.email)</div>"
		} catch {
			print(error)
			return "<div class=\"row error\">Error queuing ESI survey email: \(error)</div>"
		}
	}
}
