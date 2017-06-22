//
//  Routes.swift
//  Perfect-Local-Auth-template
//
//  Created by Jonathan Guthrie on 2017-02-20.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTPServer
import LocalAuthentication

func mainRoutes() -> [[String: Any]] {

	var routes: [[String: Any]] = [[String: Any]]()
	// Special healthcheck
	routes.append(["method":"get", "uri":"/healthcheck", "handler":Handlers.healthcheck])

	// add Static files
	routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
	               "documentRoot":"./webroot",
	               "allowResponseFilters":true])

	// Handler for home page
	routes.append(["method":"get", "uri":"/", "handler":Handlers.main])

	// Main Survey GET
	routes.append(["method":"get", "uri":"/survey/{link}", "handler":Handlers.surveyStart])
	routes.append(["method":"post", "uri":"/survey/{link}", "handler":Handlers.surveyProcess])

	// Login
	routes.append(["method":"get", "uri":"/login", "handler":Handlers.login]) // simply a serving of the login GET
	routes.append(["method":"post", "uri":"/login", "handler":LocalAuthWebHandlers.login])
	routes.append(["method":"get", "uri":"/logout", "handler":LocalAuthWebHandlers.logout])

	// Register
	routes.append(["method":"get", "uri":"/register", "handler":LocalAuthWebHandlers.register])
	routes.append(["method":"post", "uri":"/register", "handler":LocalAuthWebHandlers.registerPost])
	routes.append(["method":"get", "uri":"/verifyAccount/{passvalidation}", "handler":LocalAuthWebHandlers.registerVerify])
	routes.append(["method":"post", "uri":"/registrationCompletion", "handler":LocalAuthWebHandlers.registerCompletion])

	// JSON
	routes.append(["method":"get", "uri":"/api/v1/session", "handler":LocalAuthJSONHandlers.session])
	routes.append(["method":"get", "uri":"/api/v1/logout", "handler":LocalAuthJSONHandlers.logout])
	routes.append(["method":"post", "uri":"/api/v1/register", "handler":LocalAuthJSONHandlers.register])
	routes.append(["method":"login", "uri":"/api/v1/login", "handler":LocalAuthJSONHandlers.login])


	// Users
	routes.append(["method":"get", "uri":"/users", "handler":Handlers.userList])
	routes.append(["method":"get", "uri":"/users/create", "handler":Handlers.userMod])
	routes.append(["method":"get", "uri":"/users/{id}/edit", "handler":Handlers.userMod])
	routes.append(["method":"post", "uri":"/users/create", "handler":Handlers.userModAction])
	routes.append(["method":"post", "uri":"/users/{id}/edit", "handler":Handlers.userModAction])
	routes.append(["method":"delete", "uri":"/users/{id}/delete", "handler":Handlers.userDelete])

	// Employees
	routes.append(["method":"get", "uri":"/employees", "handler":Handlers.employeeList])
	routes.append(["method":"get", "uri":"/employees/create", "handler":Handlers.employeeMod])
	routes.append(["method":"get", "uri":"/employees/{id}/edit", "handler":Handlers.employeeMod])
	routes.append(["method":"post", "uri":"/employees/create", "handler":Handlers.employeeModAction])
	routes.append(["method":"post", "uri":"/employees/{id}/edit", "handler":Handlers.employeeModAction])
	routes.append(["method":"delete", "uri":"/employees/{id}/delete", "handler":Handlers.employeeDelete])

	routes.append(["method":"get", "uri":"/employees/import", "handler":Handlers.employeeImportSetup])
	routes.append(["method":"post", "uri":"/employees/import", "handler":Handlers.employeeImport])

	routes.append(["method":"get", "uri":"/employees/{id}/responses", "handler":Handlers.employeeResponses])


	// Questions
	routes.append(["method":"get", "uri":"/questions", "handler":Handlers.questionList])
	routes.append(["method":"get", "uri":"/questions/create", "handler":Handlers.questionMod])
	routes.append(["method":"get", "uri":"/questions/{id}/edit", "handler":Handlers.questionMod])
	routes.append(["method":"post", "uri":"/questions/create", "handler":Handlers.questionModAction])
	routes.append(["method":"post", "uri":"/questions/{id}/edit", "handler":Handlers.questionModAction])

	// Sending
	routes.append(["method":"get", "uri":"/sending", "handler":Handlers.sendView])
	routes.append(["method":"post", "uri":"/sending", "handler":Handlers.sendView])


	// Config
	routes.append(["method":"get", "uri":"/config", "handler":Handlers.configGet])
	routes.append(["method":"post", "uri":"/config", "handler":Handlers.configSave])

	// Graphs
	routes.append(["method":"get", "uri":"/graphs", "handler":Handlers.graphSetup])

	return routes
}
