def test_prometheus(User):
    assert User("prometheus").exists
