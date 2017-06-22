//
//  employeeResponses.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-20.
//

import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {

	static func employeeResponses(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Employee()
			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Employee", template: "views/employee")
				}
			}


			let questions = Question.list()
			let responses = user.responses(questions: questions)
			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"resp?":"true",
				"responses": responses,
				"questions": questions
			]
			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.render(template: "views/employees", context: context)
		}
	}

}

