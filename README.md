***
#README WILL BE UPDATED SOON (AVIRIL)
## Resource: Mysql Library
## Developer(s): OvileAmriam
***

### Keypoints:
  :heavy_check_mark: **Eases out MySQL querying.**

  :heavy_check_mark: **Easy to understand & integrate APIs.**

  :warning: **Sync version** [Don't overuse it frequently; Instead cache your datas]

### Prerequisites:
  - **MySQL Host**

### Exports:
  - **Function:** _getDatabase()_ **| Type:** _server_ **| Returns:** _connection; else false bool_
      ```
      @Returns

      connection: Database's Instance
      ```
  - **Function:** _doesTableExist(tableName)_ **| Type:** _server_ **| Returns:** _bool_
  - **Function:** _doesColumnExist(tableName, columnName)_ **| Type:** _server_ **| Returns:** _bool_
  - **Function:** _getRowData(tableName, key, keyColumnName, dataColumnName)_ **| Type:** _shared_ **| Returns:** _data; else false bool_
  - **Function:** _setRowData(tableName, key, keyColumnName, dataColumnName, data)_ **| Type:** _server_ **| Returns:** _bool_
