
package com.futurepress.staticserver;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReadableMap;

import java.io.IOException;

public class FPStaticServerModule extends ReactContextBaseJavaModule implements LifecycleEventListener {
  private WebServer server = null;

  public FPStaticServerModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "FPStaticServer";
  }

  @Override
  public void onHostResume() {
    try {
      server.start();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  @Override
  public void onHostPause() {
    stop();
  }

  @Override
  public void onHostDestroy() {
    stop();
  }

  @ReactMethod
  public void start(ReadableMap options, Promise promise) {
    try {
      if (server != null && server.wasStarted()) {
        server.stop();
      }

      server = new WebServer(options.getInt("port"));
      server.start();

      promise.resolve("http://" + server.getHostname() + ":" + server.getListeningPort());

    } catch (IOException e) {
      promise.reject(null, e.getMessage());
    }
  }

  @ReactMethod
  public void setHtml(String html) {
    server.html = html;
  }

  @ReactMethod
  public void stop() {
    if (server.wasStarted()) {
      server.stop();
    }
  }
}
