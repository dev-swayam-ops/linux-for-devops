# Package Management: Cheatsheet

## APT Basic Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo apt update` | Update package list | `sudo apt update` |
| `apt list --upgradable` | Show upgrades | `apt list --upgradable` |
| `sudo apt upgrade` | Upgrade packages | `sudo apt upgrade` |
| `sudo apt full-upgrade` | Distribution upgrade | `sudo apt full-upgrade` |
| `sudo apt install package` | Install package | `sudo apt install curl` |
| `sudo apt remove package` | Remove package | `sudo apt remove curl` |
| `sudo apt purge package` | Remove + config | `sudo apt purge curl` |
| `sudo apt autoremove` | Remove unused | `sudo apt autoremove` |

## APT Search and Info

| Command | Purpose | Example |
|---------|---------|---------|
| `apt search keyword` | Search packages | `apt search nginx` |
| `apt show package` | Package info | `apt show curl` |
| `apt list --installed` | Installed packages | `apt list --installed` |
| `apt list --installed \| wc -l` | Count packages | Count total |
| `apt policy package` | Available versions | `apt policy curl` |
| `apt depends package` | Dependencies | `apt depends curl` |
| `apt rdepends package` | Reverse depends | `apt rdepends gcc` |

## APT Advanced

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo apt install --simulate` | Simulate | Test before running |
| `sudo apt install --only-upgrade pkg` | Upgrade one | Single package only |
| `sudo apt --fix-broken install` | Fix broken deps | Repair installation |
| `apt-cache search keyword` | Detailed search | `apt-cache search web` |
| `apt-cache policy package` | Version details | Check available |

## APT Mark/Hold

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo apt-mark hold package` | Freeze version | `sudo apt-mark hold curl` |
| `apt-mark showhold` | Show held | List frozen packages |
| `sudo apt-mark unhold package` | Unfreeze | `sudo apt-mark unhold curl` |
| `apt-mark auto package` | Mark as auto | Auto-removable |
| `apt-mark manual package` | Mark manual | Don't auto-remove |

## DPKG Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `dpkg -l` | List installed | `dpkg -l \| grep curl` |
| `dpkg -l package` | Info on package | `dpkg -l curl` |
| `dpkg -L package` | Package files | `dpkg -L curl` |
| `dpkg -S file` | Find package | `dpkg -S /usr/bin/curl` |
| `dpkg -s package` | Package status | `dpkg -s curl` |

## Repository Management

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo add-apt-repository ppa:user/repo` | Add PPA | `sudo add-apt-repository ppa:nginx/stable` |
| `sudo add-apt-repository --remove ppa` | Remove PPA | Remove repository |
| `cat /etc/apt/sources.list` | View repos | Show main sources |
| `ls /etc/apt/sources.list.d/` | PPA locations | View .d repos |
| `sudo apt-key list` | GPG keys | Show repository keys |

## Package Cleanup

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo apt clean` | Remove cache | Delete .deb files |
| `sudo apt autoclean` | Partial clean | Keep recent cache |
| `sudo apt autoremove` | Remove unused | Delete orphaned |
| `du -sh /var/cache/apt/` | Cache size | Check space used |

## Common APT Tasks

| Task | Command |
|------|---------|
| Install with deps | `sudo apt install package` |
| Downgrade | `sudo apt install package=version` |
| Multiple install | `sudo apt install pkg1 pkg2 pkg3` |
| Search and install | `apt search nginx` then `sudo apt install` |
| Check if installed | `apt list --installed \| grep name` |
| Update single | `sudo apt install --only-upgrade name` |
| Remove all deps | `sudo apt purge name && sudo apt autoremove` |
| Simulate action | Add `--simulate` to command |

## YUM Commands (RedHat/CentOS)

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo yum update` | Update all | `sudo yum update` |
| `sudo yum install package` | Install | `sudo yum install curl` |
| `sudo yum remove package` | Remove | `sudo yum remove curl` |
| `yum list installed` | List installed | `yum list installed` |
| `yum search package` | Search | `yum search nginx` |
| `sudo yum clean all` | Clean cache | `sudo yum clean all` |

## DNF Commands (Fedora)

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo dnf update` | Update | `sudo dnf update` |
| `sudo dnf install package` | Install | `sudo dnf install curl` |
| `sudo dnf remove package` | Remove | `sudo dnf remove curl` |
| `dnf list installed` | List installed | `dnf list installed` |
| `dnf search package` | Search | `dnf search nginx` |
| `sudo dnf autoremove` | Remove unused | `sudo dnf autoremove` |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Package not found | `sudo apt update` first |
| Locked | Kill process using lock |
| Broken deps | `sudo apt --fix-broken install` |
| Conflicts | Use `apt policy` to check versions |
| Can't remove | Check reverse dependencies |

## Common Packages

| Package | Purpose |
|---------|---------|
| `curl` | HTTP client |
| `wget` | File downloader |
| `git` | Version control |
| `vim/nano` | Text editors |
| `htop` | Process monitor |
| `nginx` | Web server |
| `postgresql` | Database |
| `python3` | Programming |
| `docker.io` | Containerization |
| `gcc` | Compiler |
