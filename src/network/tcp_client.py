from socket import *
import time
client = socket(AF_INET, SOCK_STREAM)
client.connect(('127.0.0.1', 8888))

client.send(b'1')
client.send(b'2')
client.send(b'3')
client.send(b'4')
# client.close()
