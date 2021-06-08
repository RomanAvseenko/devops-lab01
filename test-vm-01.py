def test_network_connection(host):
    assert host.addr("vm-01").is_resolvable       
    assert host.addr("100.100.100.10").is_reachable
    assert host.addr("100.100.100.11").is_reachable

def test_chronyd(host):
    chronyd = host.service("chronyd.service")
    assert chronyd.is_enabled
    assert chronyd.is_running


def test_timezone(host):  
    assert host.file("/etc/localtime").linked_to == "/usr/share/zoneinfo/Europe/Minsk"


def test_banners(host):
    assert host.file("/etc/motd").exists
    assert host.file("/etc/issue").exists
    with host.sudo():
        assert host.file("/etc/ssh/sshd_config").contains("^Banner /etc/issue")


def test_nginx(host):
    nginx = host.service("nginx.service")
    assert host.package("nginx").is_installed
    assert nginx.is_enabled
    assert nginx.is_running
    assert host.file("/usr/share/nginx/html/index.html").exists 
    assert host.addr("100.100.100.10").port(80).is_reachable 
