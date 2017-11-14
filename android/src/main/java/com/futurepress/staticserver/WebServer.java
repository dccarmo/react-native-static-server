package com.futurepress.staticserver;

import java.io.IOException;

import fi.iki.elonen.NanoHTTPD;

public class WebServer extends NanoHTTPD {
  public String html = "";

  public WebServer(String hostname, int port) throws IOException {
    super(hostname, port);
  }

  @Override
  public Response serve(IHTTPSession session) {
    return newFixedLengthResponse(html);
  }
}
