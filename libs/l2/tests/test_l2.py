from l2 import hello

def test_hello() -> None:
    assert hello("world").find("world") != -1

