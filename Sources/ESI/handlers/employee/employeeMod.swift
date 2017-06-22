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

	static func employeeMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Employee()
			var action = "Create"

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Employee", template: "views/employee")
				}

				action = "Edit"
			}


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"usermod?":"true",
				"action": action,
				"first": user.first,
				"last": user.last,
				"email": user.email,
				"id": user.id
			]

			switch user.status {
			case 1:
				context["statusactive"] = " selected=\"selected\""
			case 2:
				context["statustest"] = " selected=\"selected\""
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

			response.render(template: "views/employees", context: context)
		}
	}


}
