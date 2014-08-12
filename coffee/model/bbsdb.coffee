# 参考：http://help.adobe.com/ja_JP/AIR/1.5/devappshtml/WS5b3ccc516d4fbf351e63e3d118666ade46-7d49.html
class window.BbsDb
	# bbses SQLConnectionインスタンス
	# bbsList 掲示板一覧が格納されたオブジェクト

	# DBへ接続
	connect: =>
		@bbses = new window.air.SQLConnection()
		dbFile = window.air.File.applicationStorageDirectory.resolvePath("bbs.db")
		try
			# 同期処理
			@bbses.open(dbFile, window.air.SQLMode.CREATE)
		catch error
			window.air.trace("Error message:", error.message)
			window.air.trace("Details:", error.details)

	# 掲示板bbsesテーブルの生成
	create: ->
		createBbs = new window.air.SQLStatement()
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
			window.air.trace("Error message:", error.message)
			window.air.trace("Details:", error.details)

	# 掲示板を登録
	insertBbs: (name, url) ->
		insertBbsStmt = new window.air.SQLStatement()
		insertBbsStmt.sqlConnection = @bbses
		sql = "INSERT INTO bbses (name, url) VALUES ('#{name}', '#{url}')"
		insertBbsStmt.text = sql
		try
			insertBbsStmt.execute()
			window.air.trace("INSERT statement succeeded")
		catch error
			window.air.trace("Error message:", error.message)
			window.air.trace("Details:", error.details)

	#掲示板一覧を取得
	selectBbs: ->
		selectBbsStmt = new window.air.SQLStatement()
		selectBbsStmt.sqlConnection = @bbses
		sql = "SELECT * FROM bbses"
		selectBbsStmt.text = sql
		try
			selectBbsStmt.execute()
			result = selectBbsStmt.getResult()
			@bbsList = result.data
			window.air.trace("SELECT statement succeeded")
		catch error
			window.air.trace("Error message:", error.message)
			window.air.trace("Details:", error.details)

	# 掲示板を削除
	# 【引数】削除する掲示板のID
	deleteBbs: (id) =>
		deleteBbsStmt = new window.air.SQLStatement()
		deleteBbsStmt.sqlConnection = @bbses
		sql = "DELETE FROM bbses WHERE id = #{id}"
		deleteBbsStmt.text = sql
		try
			deleteBbsStmt.execute()
			window.air.trace("DELETE statement succeeded")
		catch erorr
			window.air.trace("Error message:", error.message)
			window.air.trace("Details:", error.details)
