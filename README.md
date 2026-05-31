# Beginner Homelab on a Raspberry Pi 🏠🐳

A friendly, **beginner-first** guide to building a small home server (a
"homelab") on a Raspberry Pi. By the end you'll have one always-on Pi that:

- 📚 streams your **audiobooks / language courses** (Audiobookshelf),
- 🛡️ **blocks ads** on every device in your house (Pi-hole),
- 🔗 gives every service a clean URL like `http://pihole.home` (Caddy),
- 🎛️ shows it all on one **dashboard** at `http://home.home` (Homepage + Portainer),
- 🌍 is reachable **from anywhere** over a private [Tailscale](https://tailscale.com)
  network, with **nothing exposed to the public internet**.

Every part is explained with the *why*, not just the *how*, and every command is
in a copy-friendly code block.

## Why I'm building this

This is my homelab, and this guide grows along with it.

Right now I'm just getting started, so I only need one thing from it. I want
remote access to the language-learning mp3s from my Assimil course, so I can
study on my lunch break by bringing just the little book. No CDs to carry around
(most laptops can't even play them anymore), no filling up my phone with audio
files, and no wrestling a CD's contents onto an iPhone from a Linux machine. So
the first job I gave my Pi was to hold those mp3s and stream them to my phone
from anywhere.

That's the example the whole guide is built around. I picked it because it was
actually useful to me, and a real need is easier to learn from than a made-up
one. I'm not assuming you want the same thing. I'm just showing how I set up a
homelab using the problem I had in front of me. As my homelab grows and changes,
this guide will change with it, and I'll write up what I learn along the way,
including the parts I got wrong.

> [!IMPORTANT]
> ### The `setup.sh` scripts are built for my setup
> Every `setup.sh` in this repo automates the way I set up my own homelab for my
> own use case. Treat them as worked examples to read and learn from, not a
> universal installer. Some of it will fit you and some of it won't. Read a
> script before you run it, and change anything that doesn't match your hardware,
> your services, or what you actually need. If a part isn't useful to you, skip
> it.

> [!NOTE]
> ### What this is (and the honest caveats)
> This is a **beginner** homelab, documented from a real build:
> - **Hardware:** a **Raspberry Pi 4 Model B** with a **32 GB microSD card**.
>   That's all, *so far*.
> - **Case:** an **Argon ONE M.2 Aluminum** case (keeps it cool and tidy; the
>   M.2 slot is there for a future SSD upgrade, not used yet).
> - **OS:** **Ubuntu Server 26.04 LTS (64-bit), headless** (no desktop, SSH only).
>   Raspberry Pi OS Lite works the same way, every command is identical.
> - It's a learning project, not a 99.99%-uptime production setup. It's a good way
>   to get comfortable with Docker, DNS, and self-hosting.

## 🚀 Quick start

On a Pi you've already flashed with a headless 64-bit Linux (Ubuntu Server
26.04 LTS or Raspberry Pi OS Lite, see [Part 1](01-foundation/README.md)) and
signed into Tailscale:

```bash
git clone https://github.com/evannsmc/BeginnerHomelabGuide.git
cd BeginnerHomelabGuide
chmod +x install-all.sh */setup.sh
./install-all.sh          # builds Parts 1–5, prompting for timezone + passwords
```

Prefer to go slow and understand each piece? Do it **part by part** instead.
Each folder is self-contained (read its `README.md`, then run its `setup.sh`).

## 📖 The parts

| # | Folder | What you build |
|---|---|---|
| 1 | [01-foundation](01-foundation/README.md) | Flash the Pi, install Docker, join a Tailscale network |
| 2 | [02-audiobookshelf](02-audiobookshelf/README.md) | An audiobook / language-course server |
| 3 | [03-pihole](03-pihole/README.md) | Network-wide ad blocking with Pi-hole |
| 4 | [04-pretty-urls](04-pretty-urls/README.md) | A Caddy reverse proxy + local DNS for `*.home` URLs |
| 5 | [05-dashboard](05-dashboard/README.md) | A one-URL dashboard (Homepage) + Docker GUI (Portainer) |
| 6 | [06-vpn](06-vpn/README.md) | VPN privacy: Aura vs Mullvad vs Tailscale exit nodes |
| 7 | [07-away-from-home](07-away-from-home/README.md) | What works on the road, and the one-VPN rule |
| 8 | [08-phone-linux](08-phone-linux/README.md) | File + clipboard sharing between your phone and Linux |

**Bonus reference:**
[appendix-a-compose](appendix-a-compose/README.md) (every Docker Compose file
explained line by line) ·
[appendix-b-verify](appendix-b-verify/README.md) (what should just work, and how
to verify it).

## 📂 What's in each folder

```
01-foundation/
├── README.md     ← the full guide for this part (copy-paste friendly)
├── 01-foundation.pdf   ← the same part as a standalone PDF
└── setup.sh      ← runs this part's automatable steps
```

And in the repo root:

- **[`Beginner-Homelab-on-a-Raspberry-Pi.pdf`](Beginner-Homelab-on-a-Raspberry-Pi.pdf)**.
  The entire guide as one book.
- **`install-all.sh`** runs Parts 1–5 end-to-end on the Pi.

## 🔐 What's automated vs. what you do by hand

The scripts do everything that *can* be safely automated on the Pi. A few steps
are inherently manual and the scripts print them clearly:

- **Flashing the SD card** (done on your laptop with Raspberry Pi Imager).
- **Signing into Tailscale** (opens a browser sign-in) and **renaming the Pi**
  in the Tailscale admin console.
- **The Tailscale DNS push** (admin console → add the Pi as a nameserver + turn
  on *Override local DNS*). This is what makes `*.home` and ad-blocking work on
  all your devices.
- **Pointing your router's DNS** at the Pi (Part 3) for non-Tailscale devices.
- Ripping your own audio, buying a VPN, installing phone apps.

## 🛟 Safety & privacy

- **No secrets in this repo.** Every service reads passwords/tokens from a local
  `.env` file the scripts create with `chmod 600` and which is `.gitignore`d.
  The guide text uses placeholders (`100.x.y.z`, `your-tailnet.ts.net`,
  `you@homelab`).
- **Nothing is port-forwarded.** Services are reached only over your
  authenticated Tailscale mesh or your home LAN.
- Re-running a `setup.sh` is safe. Steps skip or recreate cleanly.

---

*Built and tested on a Raspberry Pi 4 Model B (32 GB microSD, Argon ONE M.2
Aluminum case). Have fun, and welcome to self-hosting!* 🎉
