# eqSh
<p align="center">
  <i>“Sometimes less is more, when it's built right.”</i>
</p>

---

<p align="center">
	<img src="./assets/logo.svg" alt="eqSh Logo" width="160"/>
</p>

<table align="center">
  <tr>
    <td><a href="https://www.apache.org/licenses/LICENSE-2.0"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache-2.0"></a></td>
    <td><a href="https://github.com/e3nviction/eqSh/stargazers"><img src="https://img.shields.io/github/stars/e3nviction/eqSh?style=flat" alt="GitHub stars"></a></td>
    <td><a href="https://github.com/e3nviction/eqSh/issues"><img src="https://img.shields.io/github/issues/e3nviction/eqSh" alt="GitHub issues"></a></td>
    <td><a href="https://github.com/e3nviction/eqSh"><img src="https://img.shields.io/github/last-commit/e3nviction/eqSh" alt="GitHub last commit"></a></td>
  </tr>
</table>


![eqSh Banner](./assets/banner.png)  

---

<table align="center">
  <tr>
    <td><a href="https://github.com/e3nviction/eqSh/releases/latest">Download</a></td>
    <td><a href="#install-guide">Install Guide</a></td>
    <td><a href="https://github.com/e3nviction/eqSh/issues">Issues</a></td>
  </tr>
</table>


---

**eqSh** is the next-generation shell for [Hyprland](https://github.com/hyprwm/Hyprland) —  
a polished, Apple-inspired Linux environment for both **superusers** and **everyday users**.  

It’s more than a bar. eqSh is your **panel, notch, launcher, notifications hub, lockscreen, wallpaper engine, tray, and more** — all in one.

---

## 🚀 Quickstart

<a name="install-guide">Install Guide</a>

<details>
<summary>
<b>1. Install Quickshell</b>
</summary>

<details>
<summary>Arch</summary>

```bash
yay -S quickshell
```

</details>
<details>
<summary>NixOS</summary>

```
{
	inputs = {  
		nixpkgs.url = "nixpkgs/nixos-unstable";  

		quickshell = {
			url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
}
```

</details>
<details>
<summary>Fedora</summary>

```bash
sudo dnf copr enable errornointernet/quickshell
sudo dnf install quickshell
```

</details>
<details>
<summary>Guix</summary>

```bash
guix install quickshell
```

</details>
</details>

<details>
<summary>
<b>2. Clone git repository</b>
</summary>

```bash
mkdir ~/eqSh
mkdir ~/.config/quickshell
git clone https://github.com/e3nviction/eqSh ~/eqSh
mv ~/eqSh/eqsh ~/.config/quickshell/
```

</details>

<details>
<summary>
<b>3. Start eqSh</b>
</summary>

```bash
qs -c eqsh
```

Or make it permanent by adding this to `~/.config/hypr/hyprland.conf`:

```bash
exec-once = qs -c eqsh
layerrule = ignorezero, ^eqsh-blur$
layerrule = blur, ^eqsh-blur$
```

</details>

---

## ✨ Features

- [x] Top Panel  
- [x] Notch (Dynamic Island + Spotlight-like Runner)  
- [x] Notifications  
- [x] Dialogs with IPC integration  
- [x] Lockscreen  
- [x] Wallpaper Engine  
- [x] System Tray  
- [x] Battery & WiFi Indicators  
- [x] Clock  

---

## 🛠 Coming Soon

* Dock with magnification
* Global Menu
* Apple-style App Drawer
* Control Center
* Desktop Icons & Widgets
* Spotlight Extensions
* Custom dropdown menus
* Advanced IPC-powered popup system
* Layered wallpapers & lockscreen
* Full JSON user settings & Settings App

---

## 📖 Documentation

👉 Full docs & guides: [Wiki](https://github.com/e3nviction/eqSh/wiki)

---

## ⚖️ License

This project is released under the **APACHE-2.0 License**.  
You are free to use, modify, and distribute — but all changes must remain open-source.

---

## 🌌 eqSh = Linux + Elegance

Stop juggling multiple apps.  
Let them **rely on eqSh**.
