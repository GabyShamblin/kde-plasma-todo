import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.dateandtime as KirigamiDateTime
import "storage.js" as Storage

PlasmoidItem {
	id: root

	width: Kirigami.Units.gridUnit * 25
	height: Kirigami.Units.gridUnit * 35

	preferredRepresentation: compactRepresentation

	property var todos: []
	property string currentFilter: "all" // all, active, completed

	Component.onCompleted: {
		Storage.initDatabase(plasmoid)
		loadTodos()
	}

	// Auto-refresh every second to sync between instances
	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: root.loadTodos()
	}

	function loadTodos() {
		todos = Storage.getAllTodos(plasmoid)
	}

	// function addTodo(text) {
	// 	if (text.trim() === "") return
	// 	Storage.addTodo(plasmoid, text)
	// 	loadTodos()
	// }

	function addTodo(text, date) {
		if (text.trim() === "") return
		Storage.addTodo(plasmoid, text, date)
		loadTodos()
	}

	function toggleTodo(id) {
		Storage.toggleTodo(plasmoid, id)
		loadTodos()
	}

	function editTodo(id, title, date) {
		Storage.editTodo(plasmoid, id, title, date)
		loadTodos()
	}

	function deleteTodo(id) {
		Storage.deleteTodo(plasmoid, id)
		loadTodos()
	}

	function clearAllTodos() {
		Storage.clearAll(plasmoid)
		loadTodos()
	}

	function loadSampleData() {
		Storage.loadSampleData(plasmoid)
		loadTodos()
	}

	// Create the date label for todo date categories
	function getDateLabel(dateString) {
		const todoDate = new Date(dateString)
		const today = new Date()
		today.setHours(0, 0, 0, 0)

		const yesterday = new Date(today)
		yesterday.setDate(yesterday.getDate() - 1)

		const todoDateOnly = new Date(todoDate)
		todoDateOnly.setHours(0, 0, 0, 0)

		const diffDays = Math.floor((todoDateOnly - today) / (1000 * 60 * 60 * 24))

		const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
										"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

		if (diffDays === 0) return "Today"
		if (diffDays === 1) return "Tomorrow"
		if (todoDate.getYear() != today.getYear()) {
			return months[todoDate.getMonth()] + " " + todoDate.getDate() + ", " + todoDate.getFullYear()
		}
		if (diffDays < 7) {
			const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
			return days[todoDate.getDay()] + ", " + months[todoDate.getMonth()] + " " + todoDate.getDate()
		}

		return months[todoDate.getMonth()] + " " + todoDate.getDate()
	}

	function getFilteredTodos() {
		var filtered = []
		for (var i = 0; i < todos.length; i++) {
			var todo = todos[i]
			if (currentFilter === "all") {
				filtered.push(todo)
			} else if (currentFilter === "active" && !todo.completed) {
				filtered.push(todo)
			} else if (currentFilter === "completed" && todo.completed) {
				filtered.push(todo)
			}
		}
		return filtered
	}

	function getTodoCount(filter) {
		var count = 0
		for (var i = 0; i < todos.length; i++) {
			if (filter === "all") {
				count++
			} else if (filter === "active" && !todos[i].completed) {
				count++
			} else if (filter === "completed" && todos[i].completed) {
				count++
			}
		}
		return count
	}

	function groupTodosByDate() {
		const groups = {}
		const filtered = getFilteredTodos()

		for (let i = 0; i < filtered.length; i++) {
			const todo = filtered[i]
			const dateLabel = getDateLabel(todo.due_date)

			if (!groups[dateLabel]) {
				groups[dateLabel] = []
			}
			groups[dateLabel].push(todo)
		}

		return groups
	}

	// Compact representation (for panel)
	compactRepresentation: Item {
			Layout.preferredWidth: Kirigami.Units.iconSizes.medium
			Layout.preferredHeight: Kirigami.Units.iconSizes.medium

			Kirigami.Icon {
					id: icon
					anchors.fill: parent
					source: "view-list-details"
					active: mouseArea.containsMouse

					// Badge showing number of incomplete todos
					Rectangle {
							visible: {
									var incomplete = 0
									for (var i = 0; i < root.todos.length; i++) {
											if (!root.todos[i].completed) incomplete++
									}
									return incomplete > 0
							}
							anchors.right: parent.right
							anchors.top: parent.top
							anchors.rightMargin: -4
							anchors.topMargin: -4
							width: Math.max(16, badgeText.width + 6)
							height: 16
							radius: 8
							color: Kirigami.Theme.highlightColor

							QQC2.Label {
									id: badgeText
									anchors.centerIn: parent
									text: {
											var incomplete = 0
											for (var i = 0; i < root.todos.length; i++) {
													if (!root.todos[i].completed) incomplete++
											}
											return incomplete > 99 ? "99+" : incomplete.toString()
									}
									color: "white"
									font.pixelSize: 10
									font.bold: true
							}
					}
			}

			MouseArea {
					id: mouseArea
					anchors.fill: parent
					hoverEnabled: true
					onClicked: root.expanded = !root.expanded
			}
	}

	fullRepresentation: ColumnLayout {
		Layout.minimumWidth: Kirigami.Units.gridUnit * 20
		Layout.minimumHeight: Kirigami.Units.gridUnit * 25
		Layout.preferredWidth: Kirigami.Units.gridUnit * 25
		Layout.preferredHeight: Kirigami.Units.gridUnit * 35
		spacing: 0

		// Header
		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: Kirigami.Units.gridUnit * 7
			color: Kirigami.Theme.backgroundColor

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: Kirigami.Units.largeSpacing
				spacing: Kirigami.Units.smallSpacing

				// Input field with Add button
				RowLayout {
					Layout.fillWidth: true
					spacing: Kirigami.Units.smallSpacing

					QQC2.TextField {
						id: inputField
						Layout.fillWidth: true
						Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
						placeholderText: "New task..."
						leftPadding: Kirigami.Units.largeSpacing
						rightPadding: Kirigami.Units.largeSpacing

						Keys.onReturnPressed: {
							root.addTodo(text)
							text = ""
						}
					}

					// Due date calendar
					QQC2.Button {
						id: calendarButton
						Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
						text: Qt.formatDate(selectedDate,"MMM d")
						icon.name: "view-calendar"
						leftPadding: Kirigami.Units.largeSpacing
						rightPadding: Kirigami.Units.largeSpacing

						property date selectedDate: new Date()
						onClicked: calendarPopup.open()

						QQC2.Popup {
							id: calendarPopup
							x: calendarButton.width - width
							y: calendarButton.height + Kirigami.Units.smallSpacing
							width: Kirigami.Units.gridUnit * 20
							height: Kirigami.Units.gridUnit * 20
							modal: true
							focus: true
							closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
							padding: Kirigami.Units.smallSpacing

							KirigamiDateTime.DatePicker {
								id: datePicker
								anchors.fill: parent
								onDatePicked: (date) => {
									calendarButton.selectedDate = date
									calendarPopup.close()
								}
							}
						}
					}

					QQC2.Button {
						Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
						text: "Add"
						icon.name: "list-add"
						highlighted: true
						leftPadding: Kirigami.Units.largeSpacing
						rightPadding: Kirigami.Units.largeSpacing
						onClicked: {
							root.addTodo(inputField.text, calendarButton.selectedDate)
							inputField.text = ""
						}
					}
				}

				// Filters
				RowLayout {
					Layout.fillWidth: true
					spacing: Kirigami.Units.smallSpacing

					QQC2.Button {
						text: "All " + root.getTodoCount("all")
						checkable: true
						checked: root.currentFilter === "all"
						flat: !checked
						onClicked: root.currentFilter = "all"
					}

					QQC2.Button {
						text: "Active " + root.getTodoCount("active")
						checkable: true
						checked: root.currentFilter === "active"
						flat: !checked
						onClicked: root.currentFilter = "active"
					}

					QQC2.Button {
						text: "Completed " + root.getTodoCount("completed")
						checkable: true
						checked: root.currentFilter === "completed"
						flat: !checked
						onClicked: root.currentFilter = "completed"
					}

					Item { Layout.fillWidth: true }
				}
			}
		}

		// Separator
		Kirigami.Separator {
				Layout.fillWidth: true
		}

		// Todo list
		QQC2.ScrollView {
			Layout.fillWidth: true
			Layout.fillHeight: true

			ListView {
				id: todoListView
				clip: true
				spacing: 0

				model: {
					const groups = root.groupTodosByDate()
					const items = []

					for (const dateLabel in groups) {
						items.push({ type: "header", text: dateLabel })

						const todosInGroup = groups[dateLabel]
						for (let i = 0; i < todosInGroup.length; i++) {
							items.push({ type: "todo", data: todosInGroup[i] })
						}
					}

					return items
				}

				delegate: Loader {
					width: todoListView.width
					sourceComponent: modelData.type === "header" ? headerComponent : todoComponent

					property var itemData: modelData
				}
			}
		}
	}

	Component {
		id: headerComponent

		Item {
			height: Kirigami.Units.gridUnit * 2

			Kirigami.Heading {
				level: 4
				text: itemData.text
				color: Kirigami.Theme.disabledTextColor
				anchors.left: parent.left
				anchors.leftMargin: Kirigami.Units.largeSpacing
				anchors.verticalCenter: parent.verticalCenter
			}
		}
	}

	Component {
		id: todoComponent

		PlasmaComponents.ItemDelegate {
			height: Kirigami.Units.gridUnit * 3
			// width: ListView.view.width

			property bool editing: false

			contentItem: RowLayout {
				spacing: Kirigami.Units.largeSpacing

				// Checkbox using system colors
				QQC2.CheckBox {
					Layout.alignment: Qt.AlignVCenter
					checked: itemData.data.completed
					visible: !parent.parent.editing
					onClicked: root.toggleTodo(itemData.data.id)
				}

				// --- View mode ---

				// Todo text with URL support
				QQC2.Label {
					Layout.fillWidth: true
					visible: !parent.parent.editing
					text: {
						var title = itemData.data.title
						// Convert URLs to clickable links
						var urlPattern = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim
						return title.replace(urlPattern, '<a href="$1">$1</a>')
					}
					textFormat: Text.RichText
					wrapMode: Text.Wrap
					font.strikeout: itemData.data.completed
					color: itemData.data.completed ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
					onLinkActivated: function(link) {
						Qt.openUrlExternally(link)
					}

					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.NoButton
						cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
					}
				}

				// --- Edit mode ---

				QQC2.TextField {
					id: editField
					Layout.fillWidth: true
					visible: parent.parent.editing
					text: itemData.data.title
				}

				QQC2.Button {
					id: calendarEditButton
					Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
					visible: parent.parent.editing
					text: Qt.formatDate(selectedDate,"MMM d")
					icon.name: "view-calendar"
					leftPadding: Kirigami.Units.smallSpacing
					rightPadding: Kirigami.Units.smallSpacing

					property date selectedDate: itemData.data.due_date
					onClicked: calendarPopup.open()

					QQC2.Popup {
						id: calendarPopup
						x: calendarEditButton.width - width
						y: calendarEditButton.height + Kirigami.Units.smallSpacing
						width: Kirigami.Units.gridUnit * 20
						height: Kirigami.Units.gridUnit * 20
						modal: true
						focus: true
						closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
						padding: Kirigami.Units.smallSpacing

						KirigamiDateTime.DatePicker {
							id: datePicker
							anchors.fill: parent
							onDatePicked: (date) => {
								calendarEditButton.selectedDate = date
								calendarPopup.close()
							}
						}
					}
				}

				// Edit / confirm button
				PlasmaComponents.ToolButton {
					icon.name: parent.parent.editing ? "dialog-ok" : "edit-entry"
					icon.width: Kirigami.Units.iconSizes.small
					icon.height: Kirigami.Units.iconSizes.small
					onClicked: {
						if (parent.parent.editing) {
							root.editTodo(itemData.data.id, editField.text, calendarEditButton.selectedDate)
							parent.parent.editing = false
						} else {
							editField.text - itemData.data.title
							parent.parent.editing = true
						}
					}
				}

				// Delete / cancel button
				PlasmaComponents.ToolButton {
					icon.name: parent.parent.editing ? "dialog-cancel" : "edit-delete"
					icon.width: Kirigami.Units.iconSizes.small
					icon.height: Kirigami.Units.iconSizes.small
					onClicked: {
						if (parent.parent.editing) {
							parent.parent.editing = false
						} else {
							root.deleteTodo(itemData.data.id)
						}
					}
				}
			}
		}
	}
}
