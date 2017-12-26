package com.futurepress.staticserver;

import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;

import fi.iki.elonen.NanoHTTPD;

public class WebServer extends NanoHTTPD {
  public String html = "";


  public WebServer(int port) throws IOException {
    super(port);
  }

  @Override
  public String getHostname() {
    return getLocalIpAddress();
  }

  public static String getLocalIpAddress() {
    try {
      for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
        NetworkInterface intf = en.nextElement();
        for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
          InetAddress inetAddress = enumIpAddr.nextElement();
          if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
            return inetAddress.getHostAddress();
          }
        }
      }
    } catch (SocketException ex) {
      ex.printStackTrace();
    }
    return null;
  }

  @Override
  public Response serve(IHTTPSession session) {
    return newFixedLengthResponse(html);
  }
}
