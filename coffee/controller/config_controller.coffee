class window.ConfigController

	constructor: (configView) ->
		hoge = "hoge2"
		@configView = configView

	# configボタン押下時
	getConfig: =>
		if !@configView.windowFlag
			@configView.showConfigWindow()
