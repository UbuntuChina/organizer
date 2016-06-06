import QtQuick 2.4
import Ubuntu.Components 1.3
import QtOrganizer 5.0

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "organizer.liu-xiao-guo"

    width: units.gu(60)
    height: units.gu(85)

    OrganizerModel {
        id: organizerModel

        endPeriod: {
            var date = new Date();
            date.setDate(date.getDate() + 10);
            return date
        }

        sortOrders: [
            SortOrder {
                id: sortOrder

                detail: Detail.EventTime
                field: EventTime.startDateTime
                direction: Qt
            }
        ]

        onExportCompleted: {
            console.log("onExportCompleted")
        }

        onImportCompleted: {
            console.log("onImportCompleted")
        }

        onItemsFetched: {
            console.log("onItemsFetched")
        }

        onModelChanged: {
            console.log("onModelChanged")
            console.log("item count: " + organizerModel.itemCount)
            mymodel.clear();
            var count = organizerModel.itemCount
            for ( var i = 0; i < count; i ++ ) {
                var item = organizerModel.items[i];
                mymodel.append( {"item": item })
            }
        }

        onDataChanged: {
            console.log("onDataChanged")
        }

        manager: "eds"
    }

    ListModel {
        id: mymodel
    }

    Component {
        id: highlight
        Rectangle {
            width: parent.width
            color: "lightsteelblue"; radius: 5
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    PageStack {
        id: pagestack
        anchors.fill: parent

        Component.onCompleted: {
            pagestack.push(main)
        }

        Page {
            id: main
            header: PageHeader {
                id: pageHeader
                title: i18n.tr("organizer")
            }
            visible: false

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    top: pageHeader.bottom
                }

                Column {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    Label {
                        text: "Organizer managers:"
                    }

                    ListView {
                        id: listview
                        width: parent.width
                        height: units.gu(10)
                        highlight: highlight
                        model:organizerModel.availableManagers
                        delegate: Label {
                            width: listview.width
                            text: modelData
                            fontSize: "large"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    listview.currentIndex = index
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: divider
                        width: parent.width
                        height: units.gu(0.1)
                        color: "green"
                    }

                    ListView {
                        clip: true
                        width: parent.width
                        height: parent.height - divider.height - listview.height
                        model: mymodel
                        delegate: ListItem {
                            Label {
                                text: item.description
                            }

                            Label {
                                anchors.right: parent.right
                                text : {
                                    var evt_time = item.detail(Detail.EventTime)
                                    var starttime = evt_time.startDateTime;
                                    console.log("time: " + starttime.toLocaleDateString())
                                    return starttime.toLocaleDateString()
                                }
                            }

                            onClicked: {
                                detailpage.myitem = item
                                pagestack.push(detailpage)
                            }

                            trailingActions: ListItemActions {
                                actions: [
                                    Action {
                                        iconName: "delete"
                                        onTriggered: {
                                            console.log("delete is triggered!");
                                            organizerModel.removeItem(item)
                                        }
                                    }
                                ]
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                console.log("manage name: " + organizerModel.manager)
            }
        }

        Page {
            id: detailpage
            header: PageHeader {
                id: header
                title: i18n.tr("Detail page")
            }
            visible: false

            property var myitem

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    top: header.bottom
                }

                Column {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    Label {
                        id: col1
                        width: parent.width
                        text: "collectionId: " + detailpage.myitem.collectionId
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col2
                        width: parent.width
                        text: "description: " + detailpage.myitem.description
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col3
                        width: parent.width
                        text: "displayLabel: " + detailpage.myitem.displayLabel
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col4
                        width: parent.width
                        text: "guid: " + detailpage.myitem.guid
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col5
                        width: parent.width
                        text: "itemId: " + detailpage.myitem.itemId
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col6
                        width: parent.width
                        text: "itemType : " + detailpage.myitem.itemType
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col7
                        width: parent.width
                        text: "manager : " + detailpage.myitem.manager
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col8
                        width: parent.width
                        text: "modified  : " + detailpage.myitem.modified
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: col9
                        width: parent.width
                        text: "Item details are:"
                    }

                    ListView {
                        width: parent.width
                        height: parent.height - col1.height - col2.height -col3.height - col9.height -
                                col4.height - col5.height - col6.height - col7.height - col8.height
                        model: detailpage.myitem.itemDetails
                        delegate: Label {
                            text: {
                                switch (modelData.type) {
                                case Detail.Undefined:
                                    return "Undefined";
                                case Detail.Classification:
                                    return "Classification"
                                case Detail.Comment:
                                    return "Comment";
                                case Detail.Description:
                                    return "Description"
                                case Detail.DisplayLabel:
                                    return "DisplayLabel"
                                case Detail.ItemType:
                                    return "ItemType"
                                case Detail.Guid:
                                    return "Guid"
                                case Detail.Location:
                                    return "Location"
                                case Detail.Parent:
                                    return "Parent"
                                case Detail.Priority:
                                    return "Priority"
                                case Detail.Recurrence:
                                    return "Recurrence"
                                case Detail.Tag:
                                    return "Tag"
                                case Detail.Timestamp:
                                    return "Timestamp"
                                case Detail.Version:
                                    return "Version"
                                case Detail.Reminder:
                                    return "Reminder"
                                case Detail.AudibleReminder:
                                    return "AudibleReminder"
                                case Detail.EmailReminder:
                                    return "EmailReminder"
                                case Detail.VisualReminder:
                                    return "VisualReminder"
                                case Detail.ExtendedDetail:
                                    return "ExtendedDetail"
                                case Detail.EventAttendee:
                                    return "EventAttendee"
                                case Detail.EventRsvp:
                                    return "EventRsvp"
                                case Detail.EventTime:
                                    return "EventTime"
                                case Detail.JournalTime:
                                    return "JournalTime"
                                case Detail.TodoTime:
                                    return "TodoTime"
                                case Detail.TodoProgress:
                                    return "TodoProgress"
                                default:
                                    return "Unknown type"
                                }
                            }
                        }
                    }
                }

                Button {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Change the description to I LOVE"
                    onClicked: {
                        console.log("changing the description")
                        detailpage.myitem.description = "I LOVE YOU"
                        organizerModel.saveItem(detailpage.myitem)
                    }
                }
            }

        }
    }
}

