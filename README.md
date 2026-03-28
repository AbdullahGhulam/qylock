

<p align="center">
<pre align="center">
<a href="#sddm">sᴅᴅᴍ​​</a>  •  <a href="#quickshell">​ǫᴜɪᴄᴋsʜᴇʟʟ​</a>  •  <a href="#gallery">​ɢᴀʟʟᴇʀʏ</a>  •  <a href="#credits">​ᴄʀᴇᴅɪᴛs</a>
</pre>
</p>

<img id="header" align="center" src="./Assets/title.png" alt="SDDM Themes" width="100%" style="border-radius: 10px; margin-top: 20px; margin-bottom: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"/>


<div align="left">
  <a href="https://github.com/sddm/sddm"><img src="https://img.shields.io/badge/SDDM-000000?style=for-the-badge&logo=linux&logoColor=white" align="left"/></a>
  <a href="https://www.qt.io"><img src="https://img.shields.io/badge/QT_QML-000000?style=for-the-badge&logo=qt&logoColor=white" align="left"/></a>
  
  <div align="right">
    <a href="upi://pay?pa=abhaydevka169@okicici&pn=Kaizky" title="Support via UPI"><img src="https://img.shields.io/badge/abhaydevka169%40okicici-000000?style=for-the-badge&logo=googlepay&logoColor=white"/></a>
    <a href="https://ko-fi.com/kaizky1"><img src="https://img.shields.io/badge/KO--FI-000000?style=for-the-badge&logo=ko-fi&logoColor=white"/></a>
  </div>
</div>

---

<br>

###  ᴏᴠᴇʀᴠɪᴇᴡ
A simple collection of all the lockscreen themes I've made. It comes with a theme changer script so you don't have to worry about moving files manually. 

<br>

---

<div align="center">
  <h2 id="sddm">  ꜱᴅᴅᴍ ꜱᴇᴛᴜᴘ  </h2>
</div>

### ⚡ ɪɴꜱᴛᴀʟʟᴀᴛɪᴏɴ ᴀɴᴅ ᴜꜱᴀɢᴇ

**1. Install Dependencies:**
*   **Core SDDM:** `sddm`, `qt5-graphicaleffects`, `qt5-quickcontrols2`, `qt5-svg`
*   **Video Support:** `qt5-multimedia` (for Qt5) OR `qt6-multimedia-ffmpeg` (for Qt6)
*   **Optional:** `fzf` (for the interactive script)

**2. Use the Setup Script:**
Simply run the interactive script to select and apply your themes. As long as you have the dependencies, this will handle the rest.
> [!IMPORTANT]
> The `sddm.sh` script works best with `fzf` installed, but will fallback to a simple list if needed.

```sh
chmod +x sddm.sh
./sddm.sh
```

### 󱔗 ꜰᴏɴᴛ ʀᴇǫᴜɪʀᴇᴍᴇɴᴛꜱ
Some themes in this collection use premium or trademarked fonts that cannot be redistributed in this repository. If you choose one of these themes, you will need to manually download the font and place it in the theme's `font` subfolder.

| Theme | Recommended Font | File Name (approx) |
| :--- | :--- | :--- |
| **NieR: Automata** | FOT-Rodin Pro DB | `FOT-Rodin Pro DB.otf` |
| **Terraria** | Andy Bold | `Andy Bold.ttf` |
| **Genshin Impact** | HYWenHei-85W | `zhcn.ttf` |
| **Sword** | The Last Shuriken | `The Last Shuriken.ttf` |
| **Minecraft** | Minecraft Regular | `minecraft.ttf` |


**Instructions:**
1. Navigate to the theme folder: `themes/<theme_name>/font/`
2. Place your `.ttf` or `.otf` file inside that `font` folder.
3. The theme will automatically detect and load the font on the next start!

<br>

---

<div align="center">
  <h2 id="quickshell">  ʟᴏᴄᴋꜱᴄʀᴇᴇɴ ꜱᴇᴛᴜᴘ (ǫᴜɪᴄᴋꜱʜᴇʟʟ)  </h2>
</div>

If you're here to use these as lockscreen themes, then you can use QUICKSHELL to do so.

**1. Install Target Dependencies:**
*   **Core:** `quickshell` (or `quickshell-git`), `qt6-declarative`, `qt6-5compat`
*   **Video Support:** `qt6-multimedia`, `qt6-multimedia-ffmpeg` (or `qt6-multimedia-gstreamer`)
*   **Optional:** `fzf` (for the interactive script)

**2. Run the Interactive Installer:**
Execute the `quickshell.sh` script to set up your target lockscreen theme and create the needed directories in your local environment.
```sh
chmod +x quickshell.sh
./quickshell.sh
```

**3. Configure your Window Manager:**
Once completed, simply bind a keyboard shortcut in your Window Manager's configuration file (e.g., Qtile, Hyprland, Sway or i3) to trigger `~/.local/share/quickshell-lockscreen/lock.sh`.

<br>

---

<div align="center">
  <h2 id="gallery"> ◈ ᴛʜᴇ ᴄᴏʟʟᴇᴄᴛɪᴏɴ ◈ </h2>
</div>

<br>

### ◈ NieR: Automata

<div align="center">
  <img src="./Assets/nier_automata.gif" width="100%"/>
</div>

<br>

### ◈ Terraria

<div align="center">
  <img src="./Assets/terraria.gif" width="100%"/>
</div>

<br>

### ◈ Enfield

<div align="center">
  <img src="./Assets/enfield.gif" width="100%"/>
</div>

<br>

### ◈ Sword

<div align="center">
  <img src="./Assets/sword.gif" width="100%"/>
</div>

<br>

### ◈ Paper

<div align="center">
  <img src="./Assets/paper.gif" width="100%"/>
</div>

<br>

### ◈ Windows 7

<div align="center">
  <img src="./Assets/win7.gif" width="100%"/>
</div>

<br>

### ◈ Cyberpunk

<div align="center">
  <img src="./Assets/cyberpunk.gif" width="100%"/>
</div>

<br>

### ◈ TUI

<div align="center">
  <img src="./Assets/tui.gif" width="100%"/>
</div>

<br>

### ◈ Porsche

<div align="center">
  <img src="./Assets/porsche.gif" width="100%"/>
</div>

<br>

### ◈ Genshin Impact

<div align="center">
  <img src="./Assets/genshin.gif" width="100%"/>
</div>

<br>

### ◈ Ninja Gaiden

<div align="center">
  <img src="./Assets/ninja_gaiden.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Coffee

<div align="center">
  <img src="./Assets/pixel-coffee.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Dusk City

<div align="center">
  <img src="./Assets/pixel-dusk-city.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Emerald

<div align="center">
  <img src="./Assets/pixel-emerald.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Hollow Knight

<div align="center">
  <img src="./Assets/pixel-hollowknight.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Munchax

<div align="center">
  <img src="./Assets/pixel-munchax.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Night City

<div align="center">
  <img src="./Assets/pixel-night-city.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Rainy Room

<div align="center">
  <img src="./Assets/pixel-rainyroom.gif" width="100%"/>
</div>

<br>

### ◈ Pixel - Skyscrapers

<div align="center">
  <img src="./Assets/pixel-skyscrapers.gif" width="100%"/>
</div>

<br>

---

<div align="center">
  <h2 id="credits">  ᴄʀᴇᴅɪᴛꜱ ᴀɴᴅ ɢʀᴀᴛɪᴛᴜᴅᴇ  </h2>
</div>

* **Pumphium** -  A huge thanks to this lil guy for helping me with the theme suggestions and debugging with me.
* **Qt/QML Community** — For the powerful framework that makes these themes possible.
* **Unixporn** — For the aesthetic inspiration and feedback.

---

<div align="center">
  <br>
  <p><i>Make your login your own. Stay ricey.</i></p>
</div>

