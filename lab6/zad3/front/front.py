from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.dirname(os.path.realpath(__file__)), **kwargs)

if __name__ == '__main__':
    httpd = HTTPServer(('0.0.0.0', 80), Handler)
    print("Server started at http://192.168.100.2:80")
    httpd.serve_forever()