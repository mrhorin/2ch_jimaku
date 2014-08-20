class window.ConfigController
	# fonts インストールされたフォント一覧
	# fontList font-listエレメント

	constructor: (configView) ->
		@configView = configView
		@windowFlag = false

	# configボタン押下時
	getConfig: =>
		@configView.showConfigWindow()

	# 設定ウィンドウを閉じる時のハンドラ
	# windowClosingHandler: (event) =>
	# 	alert "windowClosingHandler"
	# 	@configView.html.removeEventListener("complete", @windowCompleteHandler)

