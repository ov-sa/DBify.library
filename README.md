# ━ S Y N O P S I S

![](https://raw.githubusercontent.com/ov-sa/DBify-Library/Documentation/assets/dbify_banner.png)

##### ━ Maintainer(s): [Aviril](https://github.com/Aviril)

**DBify Library** is a open-source MySQL based Async database management library made by **Aviril** for [Multi Theft Auto \(MTA\)](https://multitheftauto.com/).

**DBify** integrates & synchronizes default MTA Accounts & Serials w/ MySQL aiming towards gamemode perspective for efficient & reliable database management, thus giving you more time to focus on your gamemode rather than managing redundant database queries or reinventing the wheel. Moreover, DBify helps you to process your queries efficiently without freezing the server due to its Async nature. This library is a complete overhaul of **mysql_library**, **accounts_library** & **serials_library** developed by **[Tron](https://github.com/OvileAmriam)** with efficient & reliable methodology.

## ━ Features

💎**CONSIDER** [**SPONSORING**](https://ko-fi.com/ovileamriam) **US TO SUPPORT THE DEVELOPMENT.**

* Completely Open-Source
* Procedure Oriented Programming
* Completely Performance-Friendly
* MySQL Based
* Gamemode Perspective
* Async Data-Handling
* Synchronizes default MTA Accounts
* Synchronizes default MTA Serials
* Supports Direct-Embedding (No exports required)
* Necessary Integration APIs

## ━ Contents

* [**Official Releases**](https://github.com/OvileAmriam/MTA-DBify-Library/releases)
* [**Discord Community**](http://discord.gg/sVCnxPW)

## ━ Installation

### How to get started?

1. Head over to [DBify's Releases](https://github.com/ov-sa/DBify-Library/releases) and download the latest build.
2. Drag and drop the **\[Library\]** folder into your `YourMTAFolder\server\mods\deathmatch\resources` after unzipping.
3. Type `refresh` in the console to load the library.
4. Type `start dbify_library` in the console and the library shall be successfully started. [**Note: Make sure this library should be started prior to scripts using it**]
5. Presuming you have installed the library, this page guides you on how to get started with the framework!
6. Initialize **DBify's** module within the resource you want to use it.

### How to Initialize the Module?

Add the below code once in either of the server-sided `.lua` script of the resource you want to use within:

```lua
-- Declare it globally once
loadstring(exports.dbify_library:fetchImports())()
```

## ━ Module APIs

### 📚 MySQL Module
```lua
--Objective: Validates existence of a MySQL table
dbify.mysql.table.isValid(tableName, callback(result, arguments)
    print(tostring(result))
    print(toJSON(arguments))
end, ...)

--Objective: Fetches complete contents of the specified MySQL table
dbify.mysql.table.fetchContents(tableName, callback(result, arguments)
    print(toJSON(result))
    print(toJSON(arguments))
end, ...)

--Objective: Validates existence of a MySQL table's column
dbify.mysql.column.isValid(tableName, columnName, callback(result, arguments)
    print(tostring(result))
    print(toJSON(arguments))
end, ...)

-->> Sets Data
dbify.mysql.data.set("serialdata", {
    {"serial_TEST", "1"}
}, {
    {"serial", "1"},
    {"character", "1"},
}, function(result, arguments)
    print(tostring(result))
    print(toJSON(arguments))
end, "testArg1", "testArg2")

-->> Gets Data
dbify.db.data.get("serialdata", {"serial", "character"}, {
    {"serial", "1"},
    {"character", "1"}
}, true, function(result)
    print(toJSON(result))
end)
```
