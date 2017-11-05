import {
	NativeModules,
	AppState,
	Platform
 } from 'react-native';

const { FPStaticServer } = NativeModules;

class StaticServer {
	constructor() {
		this.started = false;
	}

	start(opts) {
		if (this.running) {
			return console.warn('StaticServer already running');
		}

		this.started = true;
		this.running = true;

		if (!this.keepAlive && (Platform.OS === 'android')) {
			AppState.addEventListener('change', this._handleAppStateChange.bind(this));
		}

		return FPStaticServer.start(opts);
	}

	setRootHtml(html) {
		FPStaticServer.setRootHTML(html);
	}

	stop() {
		if (!this.running) {
			return console.warn('StaticServer not running');
		}

		this.running = false;

		return FPStaticServer.stop();
	}

	kill() {
		this.stop();

		this.started = false;

		AppState.removeEventListener('change', this._handleAppStateChange.bind(this));
	}

	_handleAppStateChange(appState) {
		if (!this.started) {
			return;
		}

		if (appState === "active" && !this.running) {
			this.start();
		}

		if (appState === "background" && this.running) {
			this.stop();
		}

		if (appState === "inactive" && this.running) {
			this.stop();
		}
	}


}

export default StaticServer;
