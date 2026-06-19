# AsterBot Integrated Installer

A simple installation and deployment tool for **AsterBot**, **NapCatQQ**, and **GeWeChat** on Ubuntu.

## Overview

AsterBot Integrated Installer was developed by **Yeyu** and **Kaohuasheng A** to simplify the deployment process for new users.

The project is inspired by the UI design of Xiaomantou's open-source installer on Gitee. While some UI elements and implementation ideas are similar, the installation workflow and deployment logic are different.

The installer uses official Docker images and Docker mirror sources provided by 1Panel to improve installation speed and reliability.

## Features

* One-click installation
* Beginner-friendly interface
* Automated Docker environment setup
* Deployment support for:

  * AsterBot
  * NapCatQQ
  * GeWeChat
* Simplified service management

## Requirements

* Ubuntu (x86_64 / AMD64)
* Docker-compatible environment
* Internet connection

> Other operating systems and architectures are not currently supported.

## Quick Start

Run the following command:

```bash
wget -qO- https://gitee.com/yeyv123/asterbot/raw/master/install.sh | sed 's/\r//' | bash
```

## Manual Installation

Clone the repository and execute the installation script manually:

```bash
git clone <repository-url>
cd asterbot
bash install.sh
```

## Notes

This project is still under active development and may contain bugs or incomplete features.

If you encounter any issues, please submit an issue report or contact the maintainers.

## Contributing

Contributions are welcome.

If you would like to improve this project, feel free to:

* Submit pull requests
* Report bugs
* Suggest new features
* Improve documentation

### Maintainers

* Yeyu
* Kaohuasheng A

## License

This project is licensed under the **Mulan Permissive Software License Version 2 (Mulan PSL v2)**.

You are free to use, modify, distribute, and publish this software in accordance with the terms of the license.

For full license details, see the `LICENSE` file in the project root directory or visit the official Mulan PSL website.

---

**Disclaimer:** This software is provided "AS IS", without warranty of any kind. See the license for details.
