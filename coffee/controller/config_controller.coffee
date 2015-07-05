class window.ConfigController

	constructor: (configView) ->
		@configView = configView

	# configボタン押下時
	getConfig: =>
		if !@configView.windowFlag
			@configView.showConfigWindow()
