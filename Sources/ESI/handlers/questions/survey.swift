//
//  survey.swift
//  ESI
//
//  Created by Jonathan Guthrie on 2017-06-20.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication
import SwiftString


extension Handlers {
	static func surveyStart(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let ans = Answer()
			let employee = Employee()
			// get linkid
			if let link = request.urlVariables["link"] {
				try? ans.find(["link":link, "completed": "0"])

				if ans.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Survey", template: "views/surveyError")
				}
			}

			// find employee id for name
			do {
				try employee.get(ans.uid)
				if employee.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Survey", template: "views/surveyError")
				}

			} catch {
				print(error)
			}

			let questions = Question.survey()
			var context: [String : Any] = [
				"firstname": employee.first,
				"questions": questions,
				"link": ans.link
			]
			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.render(template: "views/survey", context: context)
		}
	}

	static func surveyProcess(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let ans = Answer()
			let employee = Employee()
			// get linkid
			if let link = request.urlVariables["link"] {
				try? ans.find(["link":link, "completed": "0"])
				if ans.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Survey", template: "views/surveyError")
				}
			}

			// find employee id for name
			do {
				try employee.get(ans.uid)
				if employee.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Survey", template: "views/surveyError")
				}
			} catch {
				print(error)
			}

			// process answers
			let answers = request.params().filter{ f in
				return f.0.startsWith("question")
			}
//			print(answers)
			answers.forEach{
				q in
				ans.data[q.0.chompLeft("question_")] = Int(q.1)
			}
			ans.data["more"] = request.param(name: "notes", defaultValue: "")
			ans.commit()

			var context: [String : Any] = [
				"firstname": employee.first
			]
			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.render(template: "views/surveyDone", context: context)
		}
	}

}

