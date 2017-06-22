//
//  main.swift
//  Perfect-App-Template
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

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectRequestLogger
import PerfectSession
import PerfectSessionPostgreSQL
import PerfectCrypto
import LocalAuthentication
import PerfectRepeater

let _ = PerfectCrypto.isInitialized

#if os(Linux)
let fileRoot = "/perfect-deployed/esi/" // <-- change if needed
var httpPort = 8100
let fname = "./config/ApplicationConfigurationLinux.json"
#else
let fname = "./config/ApplicationConfiguration.json"
let fileRoot = ""
var httpPort = 8181
#endif

var baseURL = ""

// Configuration of Session
SessionConfig.name = "ESI"  //<-- change if needed
SessionConfig.idle = 86400
SessionConfig.cookieDomain = "localhost" //<-- change if needed
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax

RequestLogFile.location = "./log.log"

let opts = initializeSchema(fname)
httpPort = opts["httpPort"] as? Int ?? httpPort
baseURL = opts["baseURL"] as? String ?? baseURL

let sessionDriver = SessionPostgresDriver()


config() // custom options
Utility.initializeObjects()

// Run local setup routines
Utility.initializeObjects()

// Defaults
var configTitle = Config.getVal("title","Employee Satisfaction Index")
var configLogo = Config.getVal("logo","/assets/images/perfect-logo-2-0.png")
var configLogoSrcSet = Config.getVal("logosrcset","/assets/images/perfect-logo-2-0.png 1x, /assets/images/perfect-logo-2-0.svg 2x")

var configEmailText = Config.getVal("emailText","Greetings!\n\nIt is time once again to fill out a survey critical to the effective operation of our company. Please make sure you fill out this survey immediately - this system will actively remind you until you finish the survey. It only takes one minute, so do not put this off until tomorrow.\n\n{name}\n\n{link}\n\nThank you in advance for your immediate involvement.\n")
var configEmailSubject = Config.getVal("emailSubject","Monthly ESI Survey")
var configAutoMonth = Config.getVal("autoMonth","false")
var configDayOfMonth = Config.getVal("dayOfMonth","1")
var configRandomOrder = Config.getVal("randomOrder","true")


// set up repeater for email queue
let queueSize = 10
let emailRepeater = {
	() -> Bool in
	EmailQueue.check()
	return true
}
Repeater.exec(timer: 30.0, callback: emailRepeater)



// Configure Server
var confData: [String:[[String:Any]]] = [
	"servers": [
		[
			"name":"localhost",
			"port":httpPort,
			"routes":[],
			"filters":[]
		]
	]
]

// Load Filters
confData["servers"]?[0]["filters"] = filters()

// Load Routes
confData["servers"]?[0]["routes"] = mainRoutes()

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	 // fatal error launching one of the servers
	fatalError("\(error)")
}

