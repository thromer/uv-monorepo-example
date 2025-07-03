from l1 import hello

def test_hello() -> None:
    assert hello("world").find("world") != -1
