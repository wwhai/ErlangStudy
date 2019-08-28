from socket import *
import time
client = socket(AF_INET, SOCK_STREAM)
client.connect(('127.0.0.1', 8888))
time.sleep(1)
b = bytes("1111111111111111",encoding='utf-8')
print(b)
client.send(b)
time.sleep(1)

def do():
    pass

while True:
    do()
