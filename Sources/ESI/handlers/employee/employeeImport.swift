//
//  employeeImport.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-14.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import PerfectLib


extension Handlers {

	fileprivate static func fileHandler(_ upload: String) -> String {
			let contents = upload.split("\n")
			var msg = ""
			contents.forEach{
				line in
				let vars = line.split(",")
				if vars.count != 3 {
					msg = "Invalid parameters: \(vars)"
				} else {
					let o = Employee(vars[0] as String, vars[1] as String, vars[2] as String)
					// test to see if user email already in the db
					// ...
					// end test
					o.commit()
				}
			}
			if !msg.isEmpty {
				return msg
			}
		return ""
	}

	static func employeeImport(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			var msg = ""

			// IMPORT:
			if let uploads = request.postFileUploads, uploads.count > 0 {
				// iterate through the file uploads.
				for upload in uploads {

					do {
						let thisFile = File(upload.tmpFileName)
						try thisFile.open(.read, permissions: .readGroup)
						defer{
							thisFile.close()
						}
						msg = Handlers.fileHandler(try thisFile.readString())
					} catch {
						msg = "Error with file: \(error)"
					}
				}
			}

			// LIST:
			let users = Employee.list()
			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
				"msg": msg,
				"users": users
			]
			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.render(template: "views/employees", context: context)
		}
	}

}

