----------------------------------------------------------------
--[[ Resource: Mysql Library
     Script: settings: server.lua
     Server: -
     Author: Tron
     Developer: -
     Last Edit: 06/09/2019 (Tron)
     Desc: Server Sided Settings ]]--
----------------------------------------------------------------


------------------
--[[ Settings ]]--
------------------

connection = {

	hostname = "remoteconnection.com",
	username = "BYwEAap5Kz",
	password = "sguF3VFcOs",
	database = "BYwEAap5Kz"

}

connectedDB = Connection("mysql", "dbname="..connection.database..";host="..connection.hostname..";charset=utf8", connection.username, connection.password)
