from cowsay import get_output_string
def hello(message: str) -> str:
    return get_output_string('cow', message)
