//
//  userMod.swift
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

	static func questionMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let o = Question()
			var action = "Create"

			if let id = request.urlVariables["id"] {
				try? o.get(id)

				if o.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Question", template: "views/questions")
				}

				action = "Edit"
			}


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"mod?":"true",
				"action": action,
				"name": o.name,
				"txt": o.txt,
				"displayorder": o.displayorder,
				"id": o.id
			]

			switch o.status {
			case 1:
				context["statusactive"] = " selected=\"selected\""
			default:
				context["statusinactive"] = " selected=\"selected\""
			}

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
