def hello_http(request):
    name = request.args.get("name", "world")
    return f"Hello, {name}!"


