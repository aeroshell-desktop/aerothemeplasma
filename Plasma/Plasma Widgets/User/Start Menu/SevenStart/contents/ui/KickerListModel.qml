import QtQuick 2.0

ListModel {
	id: listModel
	
	property var list: []
	property var sectionIcons: { return {} }

	signal refreshing()
	signal refreshed()

	onListChanged: {
		clear()
		for (var i = 0; i < list.length; i++) {
			append(list[i]);
		}
	}


	function parseAppsModelItem(model, i) {
		// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/actionlist.h#L30
		var DescriptionRole = Qt.UserRole + 1;
		var GroupRole = DescriptionRole + 1;
		var FavoriteIdRole = DescriptionRole + 2;
		var IsSeparatorRole = DescriptionRole + 3;
		var IsDropPlaceholderRole = DescriptionRole + 4;
		var IsParentRole = DescriptionRole + 5;
		var HasChildrenRole = DescriptionRole + 6;
		var HasActionListRole = DescriptionRole + 7;
		var ActionListRole = DescriptionRole + 8;
		var UrlRole = DescriptionRole + 9;

		var modelIndex = model.index(i, 0);

		var item = {
			parentModel: model,
			indexInParent: i,
			name: model.data(modelIndex, Qt.DisplayRole),
			description: model.data(modelIndex, DescriptionRole),
			favoriteId: model.data(modelIndex, FavoriteIdRole),
			largeIcon: false, // for KickerListView
		};

		if (typeof model.name === 'string') {
			item.parentName = model.name
		}

		// ListView.append() doesn't like it when we have { key: [object] }.
		var url = model.data(modelIndex, UrlRole);
		if (typeof url === 'object') {
			url = url.toString();
		}
		if (typeof url === 'string') {
			item.url = url
		}

		var icon =  model.data(modelIndex, Qt.DecorationRole);
		if (typeof icon === 'object') {
			item.icon = icon
		} else if (typeof icon === 'string') {
			item.iconName = icon
		}

		return item;
	}

	function parseModel(appList, model, path) {
		// console.log(path, model, model.description, model.count);
		for (var i = 0; i < model.count; i++) {
			var item = model.modelForRow(i);
			if (!item) {
				item = parseAppsModelItem(model, i);
			}
			var itemPath = (path || []).concat(i);
			if (item && item.hasChildren) {
				// console.log(item)
				parseModel(appList, item, itemPath);
			} else {
				// console.log(itemPath, item, item.description);
				appList.push(item);
			}
		}
	}


	function refresh() {
		refreshing()

		refreshed()
	}

	function log() {
		for (var i = 0; i < list.length; i++) {
			var item = list[i];
			console.log(JSON.stringify({
				name: item.name,
				description: item.description,
			}, null, '\t'))
		}
	}

	function triggerIndex(index) {
		var item = list[index]
		item.parentModel.trigger(item.indexInParent, "", null);
		itemTriggered()
	}

	signal itemTriggered()

	function hasActionList(index) {
		var DescriptionRole = Qt.UserRole + 1;
		var HasActionListRole = DescriptionRole + 7;

		var item = list[index]
		var modelIndex = item.parentModel.index(item.indexInParent, 0)
		return item.parentModel.data(modelIndex, HasActionListRole)
	}

	function getActionList(index) {
		var DescriptionRole = Qt.UserRole + 1;
		var ActionListRole = DescriptionRole + 8;

		var item = list[index]
		var modelIndex = item.parentModel.index(item.indexInParent, 0)
		return item.parentModel.data(modelIndex, ActionListRole)
	}

	function triggerIndexAction(index, actionId, actionArgument) {
		// kicker/code/tools.js triggerAction()

		var item = list[index]
		item.parentModel.trigger(item.indexInParent, actionId, actionArgument)
		itemTriggered()
	}

	function getByValue(key, value) {
		for (var i = 0; i < count; i++) {
			var item = get(i)
			if (item[key] == value) {
				return item
			}
		}
		return null
	}

	function hasApp(favoriteId) {
		for (var i = 0; i < count; i++) {
			var item = get(i);
			if (item.favoriteId == favoriteId) {
				return true
			}
		}
	}
}
