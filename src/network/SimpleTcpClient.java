package network;

import java.net.Socket;

public class SimpleTcpClient {
    public static void main(String[] args) throws Exception {
        String host = "localhost";
        int port = 9999;
        Socket socket = new Socket(host, port);
        Thread.sleep(3000);
        socket.close();

    }
}