import QtQuick
import Quickshell

///! Rectangle capable of clipping content inside its border.
/// > [!WARNING] This type requires at least Qt 6.7.
///
/// This is a specialized version of @@QtQuick.Rectangle that clips content
/// inside of its border, including rounded rectangles. It costs more than
/// @@QtQuick.Rectangle, so it should not be used unless you need to clip
/// items inside of it to the border.
Item {
	id: root

	/// Defaults to true if any corner has a non-zero radius, otherwise false.
	property /*bool*/alias antialiasing: rectangle.antialiasing
	/// The background color of the rectangle, which goes under its content.
	property /*color*/alias color: shader.backgroundColor
	/// Radius of all corners. Defaults to 0.
	property /*real*/alias radius: rectangle.radius
	/// Radius of the top left corner. Defaults to @@radius.
	property /*real*/alias topLeftRadius: rectangle.topLeftRadius
	/// Radius of the top right corner. Defaults to @@radius.
	property /*real*/alias topRightRadius: rectangle.topRightRadius
	/// Radius of the bottom left corner. Defaults to @@radius.
	property /*real*/alias bottomLeftRadius: rectangle.bottomLeftRadius
	/// Radius of the bottom right corner. Defaults to @@radius.
	property /*real*/alias bottomRightRadius: rectangle.bottomRightRadius

	/// Data of the ClippingRectangle's @@contentItem. (`list<QtObject>`).
	///
	/// See @@QtQuick.Item.data for details.
	default property alias data: contentItem.data
	/// Visual children of the ClippingRectangle's @@contentItem. (`list<Item>`).
	///
	/// See @@QtQuick.Item.children for details.
	property alias children: contentItem.children
	/// The item containing the rectangle's content.
	/// There is usually no reason to use this directly.
	readonly property alias contentItem: contentItem

	Rectangle {
		id: rectangle
		anchors.fill: root
		color: "#ffff0000"
		border.color: "#ff00ff00"
		layer.enabled: true
		visible: false
	}

	Item {
		id: contentItemContainer
		anchors.fill: root

		Item {
			id: contentItem
			anchors.fill: parent
			anchors.margins: 0
		}
	}

	ShaderEffect {
		id: shader
		anchors.fill: root
		fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/cliprect.frag.qsb")
		vertexShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/grxframe.vert.qsb")
		property Rectangle rect: rectangle
		property color backgroundColor: "transparent"

		property ShaderEffectSource content: ShaderEffectSource {
			samples: 16
			hideSource: true
			sourceItem: contentItemContainer

			smooth: false
			mipmap: false
		}
	}
}
