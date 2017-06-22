//
//  configSave.swift
//  APIDocumentationServer
//
//  Created by Jonathan Guthrie on 2017-06-04.
//
//

import PerfectHTTP
import PerfectLogger

extension Handlers {

	static func configSave(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			var msg = ""

			if let title = request.param(name: "configTitle"), !title.isEmpty,
				let logo = request.param(name: "configLogo"), !logo.isEmpty,
				let srcset = request.param(name: "configLogoSrcSet"), !srcset.isEmpty,
				let emailText = request.param(name: "configEmailText"), !emailText.isEmpty,
				let emailSubject = request.param(name: "configEmailSubject"), !emailSubject.isEmpty
				{

				do {
					let cTitle = Config()
					try cTitle.upsert(cols: ["name","val"], params: ["title",title], conflictkeys: ["name"])
					configTitle = title

					let cLogo = Config()
					try cLogo.upsert(cols: ["name","val"], params: ["logo",logo], conflictkeys: ["name"])
					configLogo = logo

					let cLogoSrcSet = Config()
					try cLogoSrcSet.upsert(cols: ["name","val"], params: ["logosrcset",srcset], conflictkeys: ["name"])
					configLogoSrcSet = srcset

					let cEmailSubject = Config()
					try cEmailSubject.upsert(cols: ["name","val"], params: ["emailSubject",emailSubject], conflictkeys: ["name"])
					configEmailSubject = emailSubject


					// optionals
					var cfg = Config()
					try cfg.upsert(cols: ["name","val"], params: ["emailText",emailText], conflictkeys: ["name"])
					configEmailText = emailText

					cfg = Config()
					try cfg.upsert(cols: ["name","val"], params: ["emailText",emailText], conflictkeys: ["name"])
					configEmailText = emailText

					var autoM = request.param(name: "configAutoMonth") ?? "false"
					if autoM != "false" { autoM = "true" }
					cfg = Config()
					try cfg.upsert(cols: ["name","val"], params: ["autoMonth",autoM], conflictkeys: ["name"])
					configAutoMonth = autoM

					// DOM
					var doM = request.param(name: "configDayOfMonth") ?? "1"
					if (Int(doM) ?? 0) < 1, (Int(doM) ?? 0) > 31 { doM = "1" }
					cfg = Config()
					try cfg.upsert(cols: ["name","val"], params: ["dayOfMonth",doM], conflictkeys: ["name"])
					configDayOfMonth = doM

					// Random Order
					var autoR = request.param(name: "configRandomOrder") ?? "false"
					if autoR != "false" { autoR = "true" }
					cfg = Config()
					try cfg.upsert(cols: ["name","val"], params: ["randomOrder",autoR], conflictkeys: ["name"])
					configRandomOrder = autoR


				} catch {
					msg = "Error saving Config Data: \(error)"
				}
				
			} else {
				msg = "Please enter all information."
			}

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
				"msg": msg
			]
			if contextAuthenticated {
				for i in Handlers.extras(request) {
					context[i.0] = i.1
				}
			}

			// add app config vars
			for i in Handlers.appExtras(request) {
				context[i.0] = i.1
			}

			if configAutoMonth == "true" {
				context["configAutoMonthOption"] = " checked=\"checked\""
			}
			if configRandomOrder == "true" {
				context["configRandomOrderOption"] = " checked=\"checked\""
			}

			response.render(template: "views/config", context: context)
		}
	}
	
}
