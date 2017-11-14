import { NativeModules } from 'react-native';

const { FPStaticServer } = NativeModules;

class StaticServer {
    start(options) {
        return FPStaticServer.start(options);
    }

    setHtml(html) {
        FPStaticServer.setHtml(html);
    }

    stop() {
        return FPStaticServer.stop();
    }
}

export default StaticServer;
