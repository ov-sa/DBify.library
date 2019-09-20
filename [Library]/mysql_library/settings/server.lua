----------------------------------------------------------------
--[[ Resource: Mysql Library
     Script: settings: server.lua
     Server: -
     Author: Tron
     Developer: -
     DOC: 06/09/2019 (Tron)
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
