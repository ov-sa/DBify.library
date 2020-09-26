----------------------------------------------------------------
--[[ Resource: Mysql Library
     Script: settings: server.lua
     Server: -
     Author: OvileAmriam
     Developer: -
     DOC: 06/09/2019 (OvileAmriam)
     Desc: Server Sided Settings ]]--
----------------------------------------------------------------


------------------
--[[ Settings ]]--
------------------

connection = {

    hostname = "",
    username = "",
    password = "",
    database = ""

}

connectedDB = Connection("mysql", "dbname="..connection.database..";host="..connection.hostname..";charset=utf8", connection.username, connection.password)
