//
//  userDelete.swift
//  ServerMonitor
//
//  Created by Jonathan Guthrie on 2017-04-30.
//
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger


extension Handlers {

	static func employeeDelete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			if (request.session?.userid ?? "").isEmpty { response.completed(status: .notAcceptable) }

			let user = Employee()

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					errorJSON(request, response, msg: "Invalid Employee")
				} else {
					try? user.delete()
				}
			}


			response.setHeader(.contentType, value: "application/json")
			var resp = [String: Any]()
			resp["error"] = "None"
			do {
				try response.setBody(json: resp)
			} catch {
				print("error setBody: \(error)")
			}
			response.completed()
			return
		}
	}
}
