//
//  userModAction.swift
//  ServerMonitor
//
//  Created by Jonathan Guthrie on 2017-04-30.
//
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {
	
	static func questionModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let o = Question()
			var msg = ""

			if let id = request.urlVariables["id"] {
				try? o.get(id)

				if o.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Question", template: "views/questions")
				}
			}


			if let name = request.param(name: "name"), !name.isEmpty,
				let displayorder = request.param(name: "displayorder"), !displayorder.isEmpty {
				o.name = name
				o.displayorder = Int(displayorder) ?? 100

				o.txt = request.param(name: "txt") ?? ""

				switch request.param(name: "status") ?? "" {
					case "active":
						o.status = 1
					default:
						o.status = 0
				}

				if o.id.isEmpty {
					o.makeID()
					try? o.create()
				} else {
					try? o.save()
				}

			} else {
				msg = "Please enter the question's display name and a valid display order number."
				var action = "Create"
				if let id = request.urlVariables["id"] {
					try? o.get(id)
					action = "Edit"
				}

				redirectRequest(request, response, msg: msg, template: "views/employees", additional: [
					"accountID": contextAccountID,
					"authenticated": contextAuthenticated,
					"mod?":"true",
					"action": action,
					"name": o.name,
					"txt": o.txt,
					"displayorder": o.displayorder
					])
			}


			let oo = Question.list()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"list?":"true",
				"questions": oo,
				"msg": msg
			]
			if contextAuthenticated {
				for i in Handlers.extras(request) {
					context[i.0] = i.1
				}
			}
			// add app config vars
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }


			response.render(template: "views/questions", context: context)
		}
	}
}
