class window.ThreadView extends BaseView

	# regex: /((http:|https:|ttp:|ttps:)\/\/[\x21-\x26\x28-\x7e]+)/gi
	# regex: /(((f|h?t){1}tp(s)?:\/\/)[-a-zA-Z0-9@:%_\+.~?&\/\/=]+)/gi
	# regex: /(((f|h?t){1}tp(s)?:\/\/)[-a-zA-Z0-9@:%_\+.~?&\/\/=]+)/gi
	regex: /(f|h?)(t{1}tps?:\/\/[-a-zA-Z0-9@:%_\+.~?&\/\/=]+)/gi
	links: []

	# URLをリンク化してidを付加する
	autoLink: (res) =>
		makeLink = (all, url, h, href) =>
			# リンク用idを生成
			id = Math.floor(Math.random() * 100000000)
			# idとurlの組み合わせを配列に格納
			@links.push("id": id, "url": "h"+h)
			# window.air.Introspector.Console.log(id)
			return "<a href=\"#\" id=\""+id+"\">" + all + "</a>"
		res.replace(@regex, makeLink)

	# リンクにイベントを付加する
	addEventToLink: =>
		$.each @links, (index,value) =>
			id = window.viewerObj.html.window.document.getElementById(@links[index]["id"])
			id.addEventListener "click",@callNavigateToURL(@links[index]["url"])

	callNavigateToURL: (url) =>
		(event) =>
			urlReq = new window.air.URLRequest(url)
			window.air.navigateToURL(urlReq)

	# レスを描画
	printRes: (res)->
		$.each res, (index, value) =>
			section = window.viewerObj.html.window.document.getElementById("section")
			$(section).append(
				"""
				<div class="res">
					<div class="res-head">
						<span class="res-no">
							#{res[index][0]}
						</span>
						<span class="res-name">
							#{res[index][1]}
						</span>
						<span class="res-date">
							#{res[index][3]}
						</span>
					</div>
					<div class="res-body">
						#{@autoLink(res[index][4])}
					</div>
				</div>
				"""
			)
		@addEventToLink()
		# 一番下へスクロール
		bottomMost = window.viewerObj.html.window.document.getElementById("bottom-most")
		$(bottomMost)[0].scrollIntoView(false)