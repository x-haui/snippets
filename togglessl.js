//toggles the current page from https to http and vice versa
mappings.addUserMap([modes.NORMAL], ["<Leader>h"], "Toggle SSL",
		function() {
			var url = util.losslessDecodeURI(buffer.URL);
			if(url.match(/^http:/)){
				url = url.replace(/^http/, "https");
			}else if(url.match(/^https:/)){
				url = url.replace(/^https/, "http");
			}
			liberator.open(url, liberator.CURRENT_TAB);
		});
