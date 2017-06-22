//
//  graphSetup.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-20.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {

	static func graphSetup(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated
			]
			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.render(template: "views/graphs", context: context)
		}
	}

}


