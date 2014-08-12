# 参考：http://help.adobe.com/ja_JP/AIR/1.5/devappshtml/WS5b3ccc516d4fbf351e63e3d118666ade46-7d49.html
class window.BbsDb
	# air Airインスタンス
	# bbses SQLConnectionインスタンス
	# bbsList 掲示板一覧が格納されたオブジェクト

	constructor: (air) ->
		@air = air

	# DBへ接続
	connect: =>
		@bbses = new @air.SQLConnection()
		dbFile = @air.File.applicationStorageDirectory.resolvePath("bbs.db")
		try
			# 同期処理
			@bbses.open(dbFile, @air.SQLMode.CREATE)
		catch error
			@air.trace("Error message:", error.message)
			@air.trace("Details:", error.details)

	# 掲示板bbsesテーブルの生成
	create: ->
		createBbs = new @air.SQLStatement()
		createBbs.sqlConnection = @bbses
		sql = """
			CREATE TABLE IF NOT EXISTS bbses (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				name TEXT,
				url TEXT
				)
			"""
		createBbs.text = sql
		try
			createBbs.execute()
			air.trace("Table created")
		catch error
			@air.trace("Error message:", error.message)
			@air.trace("Details:", error.details)

	# 掲示板を登録
	insertBbs: (name, url) ->
		insertBbsStmt = new @air.SQLStatement()
		insertBbsStmt.sqlConnection = @bbses
		sql = "INSERT INTO bbses (name, url) VALUES ('#{name}', '#{url}')"
		insertBbsStmt.text = sql
		try
			insertBbsStmt.execute()
			@air.trace("INSERT statement succeeded")
		catch error
			@air.trace("Error message:", error.message)
			@air.trace("Details:", error.details)

	#掲示板一覧を取得
	selectBbs: ->
		selectBbsStmt = new @air.SQLStatement()
		selectBbsStmt.sqlConnection = @bbses
		sql = "SELECT * FROM bbses"
		selectBbsStmt.text = sql
		try
			selectBbsStmt.execute()
			result = selectBbsStmt.getResult()
			@bbsList = result.data
			@air.trace("SELECT statement succeeded")
			# @air.Introspector.Console.log(result.data)
		catch error
			@air.trace("Error message:", error.message)
			@air.trace("Details:", error.details)

	# 掲示板を削除
	deleteBbs: (id) ->
		deleteBbsStmt = new @air.SQLStatement()
		deleteBbsStmt.sqlConnection = @bbses
		sql = "DELETE FROM bbses WHERE id = #{id}"
		deleteBbsStmt.text = sql
		try
			deleteBbsStmt.execute()
			@air.trace("DELETE statement succeeded")
		catch erorr
			@air.trace("Error message:", error.message)
			@air.trace("Details:", error.details)