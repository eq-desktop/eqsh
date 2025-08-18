import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
	id: root

	signal unlocked()
	signal unlocking()
	signal failed()

	property string currentText: ""
	property bool unlockInProgress: false
	property bool showFailure: false

	onCurrentTextChanged: showFailure = false;

	function tryUnlock() {
		if (currentText === "") return;

		root.unlockInProgress = true;
		pam.start();
	}

	PamContext {
		id: pam
		configDirectory: "pam"
		config: "password.conf"

		onPamMessage: {
			if (this.responseRequired) {
				this.respond(root.currentText);
			}
		}

		onCompleted: result => {
			if (result == PamResult.Success) {
				root.unlocking();
			} else {
				root.currentText = "";
				root.showFailure = true;
			}

			root.unlockInProgress = false;
		}
	}
}
