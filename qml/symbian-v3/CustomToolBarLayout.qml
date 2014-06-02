import QtQuick 1.0
import com.nokia.symbian 1.0
ToolBarLayout{}
/*ImplicitSizeItem {
    id: root

    property alias backImage: backg

    Image{
        id:backg
        source: night_mode?"qrc:/Image/toolbar.svg":"qrc:/Image/toolbar_inverse.svg"
    }

    property bool backButton: true // deprecated
    onBackButtonChanged: { console.log("warning: ToolBarLayout.backButton is deprecated.") }

    implicitWidth: screen.width
    implicitHeight: internal.defaultHeightToolBar

    visible: false

    Connections {
        target: privateStyle
        onLayoutParametersChanged: delayedLayout.start()
    }
    Connections {
        target: screen
        onCurrentOrientationChanged: delayedLayout.start()
    }

    QtObject {
        id: internal
        objectName: "internal"

        property bool portrait: screen.width < screen.height

        // These are the dynamic layout parameters used by the toolbar layout.
        property real defaultHeightToolBar: portrait ?
            privateStyle.toolBarHeightPortrait : privateStyle.toolBarHeightLandscape
        property real defaultHeightToolButton: privateStyle.toolBarHeightLandscape
        property real outerMarginHorizontal: portrait ?
            0 : (2 * platformStyle.paddingLarge)
        property real outerMarginButtonRowLong: portrait ?
            platformStyle.paddingLarge : (3 * platformStyle.paddingLarge)
        property real innerSpacingTextButtonSingle: portrait ?
            platformStyle.paddingMedium + (3 * platformStyle.paddingLarge) : (3 * platformStyle.paddingLarge)
        property real innerSpacingTextButtonDouble: portrait ?
            platformStyle.paddingSmall : (3 * platformStyle.paddingLarge)
        property real innerSpacingButtonRowTwoChildren: portrait ?
            platformStyle.paddingMedium : (3 * platformStyle.paddingLarge)
        property real innerSpacingButtonRowLong: portrait ?
            platformStyle.paddingMedium : platformStyle.paddingLarge
        property real centerSpacingTextButtonDouble: platformStyle.paddingLarge

        function isIconButton(item) {
            return item.hasOwnProperty("iconSource")
                && item.hasOwnProperty("text")
                && item.text == ""
        }

        function isTextToolButton(item) {
            // ToolButton has both iconSource and flat property,
            // Button only has iconSource
            return (item.hasOwnProperty("iconSource")
                    && item.iconSource == ""
                    && item.hasOwnProperty("flat"))
        }

        function isButtonRow(item) {
            return item.hasOwnProperty("checkedButton")
        }

        function buttonWidth(child) {
            if ((isTextToolButton(child)) || !(child.hasOwnProperty("implicitWidth"))) {
                // ImplicitWidth for the ToolButton returns wrong value right after
                // orientation change, and also we want to override its own
                // layout width calculation, so use the actual width
                return child.width
            }
            return child.implicitWidth
        }

        function centerOffset(outerLength, innerLength) {
            // calculate the offset of the leading edge of a centered child item
            return Math.floor((outerLength - innerLength) / 2.0)
        }

        function widthTextButtonSingle(leftMargin, innerSpacing) {
            // calculate the remaining width for a centered item
            var outerContents = leftMargin + innerSpacing
            return root.width - (outerContents * 2)
        }

        function widthTextButtonDouble(leftMargin, innerSpacing, centerSpacing) {
            // calculate the space available when there are two items with a center
            // margin, and share it between the two
            var outerContents = leftMargin + innerSpacing
            return Math.round((root.width - (outerContents * 2) - centerSpacing) / 2.0)
        }

        function widthButtonRowLong(leftButton, rightButton, itemMargin, innerSpacing, outerMargin) {
            // calculate the width of a long button row, which is used in the case that there are more
            // than three icons. If either left or right button is present, allocate the itemMargin to
            // ensure that there is sufficient space; otherwise we can use the special
            // outerMargin value
            var leftContents = leftButton ? itemMargin + innerSpacing : outerMargin
            var rightContents = rightButton ? itemMargin + innerSpacing : outerMargin
            return root.width - leftContents - rightContents
        }

        function layoutChildren() {
            var numChildren = children.length-1
            if (!parent || root.width == 0 || numChildren == 0)
                return

            for (var i = 0; i < numChildren; ++i) {
                // make sure all the children have correct parent, height, and y
                children[i+1].parent = root

                if (isButtonRow(children[i+1])) {
                    var buttonRow = children[i+1]
                    // ButtonRow frame height is always tool bar's height in
                    // landscape, regardless of the current orientation, so we need
                    // to override the heights of the buttons within (because it's a
                    // Row, so its height is based on its children)
                    for (var j = 0; j < buttonRow.children.length; ++j) {
                        buttonRow.children[j].implicitHeight = defaultHeightToolButton
                    }
                }
                // child's vertical center always goes to middle of the toolbar
                var childHeight = children[i+1].hasOwnProperty("implicitHeight") ?
                        children[i+1].implicitHeight : children[i+1].height
                children[i+1].y = root.y + centerOffset(root.implicitHeight, childHeight)
            }

            // detect whether we have left and or right items. we need to lay out
            // the remaining children (that are not left or right items) whether they
            // are tool buttons, text buttons or a button row
            var leftItem = isIconButton(children[1]) ?
                    children[1] : undefined
            var rightItem = isIconButton(children[numChildren]) ?
                    children[numChildren] : undefined
            var childrenRemaining = numChildren - (leftItem != undefined ? 1 : 0) - (rightItem != undefined ? 1 : 0)
            var firstRemainingIndex = leftItem != undefined ? 1 : 0
            var lastRemainingIndex = rightItem != undefined ? (numChildren - 2) : (numChildren - 1)

            // precalculate the margins for the left and right items, we will work
            // out child sizes assuming they are present
            var leftMargin = outerMarginHorizontal + defaultHeightToolBar
            var rightMargin = root.width - leftMargin

            // In the case of a lone remaining chlld, or in the case of 2 text
            // buttons, we need to override the width
            var overrideChildWidth = 0
            for (var p = firstRemainingIndex; p <= lastRemainingIndex; p++) {
                var child = children[p+1]
                overrideChildWidth = buttonWidth(child)

                // If necessary, we calculate and override the width first before we
                // can calculate the x positions
                if ((isTextToolButton(child) && childrenRemaining == 1)
                        || (isButtonRow(child) && child.children.length == 1)) {
                    // we treat a button row with a single item like a single tool button,
                    // but in landscape, calculate size as if there were two buttons
                    overrideChildWidth = portrait ?
                        widthTextButtonSingle(leftMargin, innerSpacingTextButtonSingle) :
                        widthTextButtonDouble(leftMargin, innerSpacingTextButtonDouble, innerSpacingTextButtonDouble)

                } else if (isTextToolButton(child) && childrenRemaining == 2) {
                    // special case of margins for two text buttons
                    overrideChildWidth = widthTextButtonDouble(
                                leftMargin, innerSpacingTextButtonDouble, centerSpacingTextButtonDouble)

                } else if (isButtonRow(child) && ((child.children.length == 2)
                              || (child.children.length > 2 && leftItem != undefined && rightItem != undefined))) {
                    // there are special margins if the button row has two children,
                    // or if it has more than two children and there is a left and
                    // a right item
                    overrideChildWidth = widthTextButtonSingle(
                                leftMargin, innerSpacingButtonRowTwoChildren)

                } else if (isButtonRow(child) && child.children.length > 2) {
                    // the long button row has special margins, which are used on
                    // either side if the side icon button is missing on that side. If the item is present,
                    // the leftMargin can be used on either side to leave space for either icon button
                    overrideChildWidth = widthButtonRowLong(
                                leftItem != undefined,
                                rightItem != undefined,
                                leftMargin,
                                innerSpacingButtonRowLong,
                                outerMarginButtonRowLong)
                }

                child.width = overrideChildWidth
            }

            if (numChildren == 1) {
                var loneChild = children[1]
                var loneChildWidth = buttonWidth(loneChild)
                if (isButtonRow(loneChild)) {
                    loneChildWidth = overrideChildWidth
                }
                if (isIconButton(loneChild))
                    loneChild.x = outerMarginHorizontal
                else
                    loneChild.x = centerOffset(root.width, loneChildWidth)
                return
            }

            // we can easily calculate the positions of the left and right items,
            // but if they are missing then correct the margins
            if (leftItem != undefined){
                leftItem.x = outerMarginHorizontal
            } else {
                leftMargin = 0
            }
            if (rightItem != undefined){
                rightItem.x = root.width - defaultHeightToolBar - outerMarginHorizontal
            } else {
                rightMargin = root.width
            }

            if (!childrenRemaining)
                return;

            if (childrenRemaining == 1) {
                loneChild = children[firstRemainingIndex+1]
                loneChildWidth = buttonWidth(loneChild)
                if (isButtonRow(loneChild)) {
                    // ButtonRow should have the override width (but it won't have
                    // been updated yet)
                    loneChildWidth = overrideChildWidth
                }
                // lone child is always centered, unless it's a long button row on
                // one side only
                if (isButtonRow(loneChild) && loneChild.children.length >= 3
                        && ((leftItem == undefined) != (rightItem == undefined))) {
                    loneChild.x = (leftItem != undefined) ?
                                (leftMargin + innerSpacingButtonRowLong) : outerMarginButtonRowLong
                } else {
                    loneChild.x = centerOffset(root.width, loneChildWidth)
                }
            } else if (childrenRemaining == 2 && isTextToolButton(children[firstRemainingIndex+1])) {
                // text buttons are distributed around the center with a center spacing
                var midPoint = Math.floor(root.width / 2.0)
                var halfSpacing = Math.round(platformStyle.paddingLarge / 2.0)
                children[firstRemainingIndex+1].x = midPoint - halfSpacing - buttonWidth(children[firstRemainingIndex+1])
                children[firstRemainingIndex + 2].x = midPoint + halfSpacing
            } else {
                // icon buttons are deployed evenly in the remaining space,
                // but we need to ensure that the spacings are integer values,
                // and share the rounding error to ensure that they are centered
                var remainingSpace = rightMargin - leftMargin
                var spacingNotRounded = remainingSpace
                for (var p = 0; p < childrenRemaining; p++) {
                    var nextChild = children[leftItem != undefined ? p + 2 : p+1]
                    spacingNotRounded -= buttonWidth(nextChild)
                }
                spacingNotRounded /= (childrenRemaining + 1)
                var spacing = Math.floor(spacingNotRounded)
                var totalRoundingError = (spacingNotRounded - spacing) * (childrenRemaining + 1)
                var curPos = leftMargin + Math.floor(totalRoundingError / 2.0)

                for (var p = 0; p < childrenRemaining; p++) {
                    nextChild = children[leftItem != undefined ? p + 2 : p+1]
                    curPos += spacing
                    nextChild.x = curPos
                    curPos += buttonWidth(nextChild)
                }
            }
        }
    }

    Timer {
        id: delayedLayout
        interval: 1
        onTriggered: internal.layoutChildren()
    }

    Component.onCompleted: internal.layoutChildren()
    onParentChanged: internal.layoutChildren()
    onChildrenChanged: internal.layoutChildren()
    onImplicitWidthChanged: delayedLayout.start()
    onImplicitHeightChanged: delayedLayout.start()
    onWidthChanged: delayedLayout.start()
}*/
