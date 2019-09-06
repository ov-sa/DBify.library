***
# Resource Name: MYSQL
## Developer(s): Tron
***

### Keypoints:
> Connects MYSQL server and performs queries on it. Requires a MYSQL Host

- ### Exports:
  - **Function:** _getDatabase()_ **| Type:** _server_ **| Returns:** _connection; else false bool_
  - **Function:** _setRowData(tableName, key, keyColumnName, dataColumnName, data)_ **| Type:** _server_ **| Returns:** _bool_
  - **Function:** _getRowData(tableName, key, keyColumnName, dataColumnName)_ **| Type:** _shared_ **| Returns:** _data; else false bool_
