# catjitsu_api/middleware.py
class GodotWasmHeaderMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        # These two headers allow Godot 4's Wasm threads to initialize
        response["Cross-Origin-Opener-Policy"] = "same-origin"
        response["Cross-Origin-Embedder-Policy"] = "require-corp"
        response["Permissions-Policy"] = "cross-origin-isolated=(self)"
        return response