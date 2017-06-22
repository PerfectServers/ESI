//
//  SendView.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-19.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication
import SwiftString

extension Handlers {

	static func sendView(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }
			var msg = ""

			// send one
			if let sendOne = request.param(name: "sendTest"), !sendOne.isEmpty {
				msg = EmailFunctions.queueInitialEmail(sendOne)
			}

			// send all

			let testUsers = Employee.list(2)
			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"testUsers": testUsers,
				"msg": msg
			]
			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }


			response.render(template: "views/sendView", context: context)
		}
	}

}

