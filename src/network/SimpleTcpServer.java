package network;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

/**
 * @author wwhai
 * @date 2019/8/25 15:12
 * @email:751957846@qq.com 瞅啥瞅？代码拿过来我看看有没有BUG。
 */
public class SimpleTcpServer {
    private int port = 9999;
    private ServerSocket serverSocket;

    public SimpleTcpServer() throws Exception {
        serverSocket = new ServerSocket(port, 3);
        System.out.println("服务器启动!");
    }

    public static void main(String[] args) throws Exception {
        SimpleTcpServer server = new SimpleTcpServer();
        Thread.sleep(60000 * 10);
        server.service();
    }

    public void service() {
        while (true) {
            Socket socket = null;
            try {
                socket = serverSocket.accept();
                System.out.println("New connection accepted " +
                        socket.getInetAddress() + ":" + socket.getPort());
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (socket != null) {
                    try {
                        socket.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }

    }
}
