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
	
	static func employeeModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Employee()
			var msg = ""

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Employee", template: "views/employees")
				}
			}


			if let first = request.param(name: "first"), !first.isEmpty,
				let last = request.param(name: "last"), !last.isEmpty,
				let email = request.param(name: "email"), !email.isEmpty {
				user.first = first
				user.last = last
				user.email = email

				switch request.param(name: "status") ?? "" {
					case "active":
						user.status = 1
					case "test":
						user.status = 2
					default:
						user.status = 0
				}

				if user.id.isEmpty {
					user.makeID()
					try? user.create()
				} else {
					try? user.save()
				}

			} else {
				msg = "Please enter the user's first and last name, as well as a valid email."
				var action = "Create"
				if let id = request.urlVariables["id"] {
					try? user.get(id)
					action = "Edit"
				}

				redirectRequest(request, response, msg: msg, template: "views/employees", additional: [
					"accountID": contextAccountID,
					"authenticated": contextAuthenticated,
					"usermod?":"true",
					"action": action,
					"first": user.first,
					"last": user.last,
					"email": user.email,
					"usermod?":"true",
					])
			}


			let users = Employee.list()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
				"users": users,
				"msg": msg
			]
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
