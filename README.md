# Beginner Homelab on a Raspberry Pi 🏠🐳

A friendly, **beginner-first** guide to building a small home server (a
"homelab") on a Raspberry Pi, based on my own setup and written for other people
who want to build something similar. By the end, following along gives you one
always-on Pi that:

- 📚 streams your **audiobooks / language courses** (Audiobookshelf),
- 🛡️ **blocks ads** on every device in your house (Pi-hole),
- 🔗 gives every service a clean URL like `https://pihole.home` (Caddy),
- 🎛️ shows it all on one **dashboard** at `https://home.home` (Homepage + Portainer),
- 🌍 is reachable **from anywhere** over a private [Tailscale](https://tailscale.com)
  network, with **nothing exposed to the public internet**.

Every chapter is explained with the *why*, not just the *how*, and every command is
in a copy-friendly code block.

## Why I'm building this

This is my homelab, and this guide grows along with it.

Right now I'm just getting started, so I only need one thing from it. I want
remote access to the language-learning mp3s from my Assimil course, so I can
study on my lunch break by bringing just the little book. No CDs to carry around
(most laptops can't even play them anymore), no filling up a phone with audio
files, and no wrestling a CD's contents onto iOS from a Linux machine. So
the first job I gave my Pi was to hold those mp3s and stream them to a phone
from anywhere.

That example is the thread running through the guide. I picked it because it was
useful to me, and a real need is easier to learn from than a made-up
one. I'm not assuming you want the same thing. I'm just showing how I set up a
homelab using the problem I had in front of me. As my homelab grows and changes,
this guide will change with it, and I'll write up what I learn along the way,
including the parts I got wrong.

> [!IMPORTANT]
> ### The scripts mirror the numbered setup steps
> Each folder holds small, self-contained scripts for the repeatable parts:
> creating the example `compose.yaml` files, writing local `.env` files, writing
> standalone config like the `Caddyfile`, and starting or recreating containers.
> They deliberately do **not** automate my use-case-specific bits (like ripping
> and copying my own audio); those live in the guide text. The scripts still
> reflect the choices I made for my own homelab, so read one before you run it
> and adapt it to your own hardware and needs.

> [!NOTE]
> ### What this is, and the caveats
> This is a **beginner** homelab, documented from a real build:
> - **Hardware:** a **Raspberry Pi 4 Model B** with a **32 GB microSD card**.
>   That's all, *so far*.
> - **Case:** an **Argon ONE M.2 Aluminum** case (keeps it cool and tidy; the
>   M.2 slot is there for a future SSD upgrade, not used yet).
> - **OS:** **Ubuntu Server 26.04 LTS (64-bit), headless** (no desktop, SSH only).
> - It's a learning project, not a 99.99%-uptime production setup. It's a good way
>   to get comfortable with Docker, DNS, and self-hosting.

## 🚀 How to use this

There's no one big installer. You **work through the guide chapter by chapter**.
Each folder has a `README.md` (the walkthrough), a PDF of that chapter, a
`scripts/` folder of small **numbered** helpers (run them in order), and, for the
service chapters, a `compose/` folder with reference copies of the
`compose.yaml` / `Caddyfile` for people doing the steps by hand. The scripts are
standalone: they write their own files inline and do not depend on the
`compose/` folder. A typical flow on a freshly flashed, Tailscale-signed-in Pi
(see [Chapter 1](01-foundation/README.md)):

```bash
git clone https://github.com/evannsmc/BeginnerHomelabGuide.git
cd BeginnerHomelabGuide

# read 01-foundation/README.md, then run its helpers in order:
01-foundation/scripts/01-update-system.sh
01-foundation/scripts/02-install-docker.sh
01-foundation/scripts/03-install-tailscale.sh
# ...then move on to 02-audiobookshelf, 03-pihole, and so on.
```

Prefer to do it by hand? Skip the scripts entirely: copy the files from each
chapter's `compose/` folder and the commands from its README. Either way works.
Read a script before running it; the use-case-specific steps (ripping your own
audio, pointing your router's DNS, trusting the HTTPS cert) are explained in the
chapter's README, not scripted.

## 📖 The chapters

The guide is two **volumes** of short chapters. Each chapter is grouped into
**Parts**, and each Part into **Steps**.

**Volume I, building the homelab**

| Ch | Folder | What you build |
|---|---|---|
| 1 | [01-foundation](01-foundation/README.md) | Flash the Pi, install Docker, join a Tailscale network |
| 2 | [02-audiobookshelf](02-audiobookshelf/README.md) | An audiobook / spoken-audio server |
| 3 | [03-pihole](03-pihole/README.md) | Network-wide ad blocking with Pi-hole |
| 4 | [04-pretty-urls](04-pretty-urls/README.md) | A Caddy reverse proxy + local DNS for `*.home` URLs (HTTPS) |
| 5 | [05-dashboard](05-dashboard/README.md) | A one-URL dashboard (Homepage) + Docker GUI (Portainer) |

**Volume II, VPNs and remote access**

| Ch | Folder | What you build |
|---|---|---|
| 6 | [06-vpn](06-vpn/README.md) | VPN privacy: Aura vs Mullvad vs Tailscale exit nodes |
| 7 | [07-away-from-home](07-away-from-home/README.md) | What works on the road, and the one-VPN rule |

**Volume III, extras**

| Ch | Folder | What you build |
|---|---|---|
| 8 | [08-remoting-phone](08-remoting-phone/README.md) | Reach machines from a phone: Termius (SSH) + NoMachine (desktop) |
| 9 | [09-phone-linux](09-phone-linux/README.md) | File + clipboard sharing between a phone and Linux |

**Bonus reference:**
[appendix-a-compose](appendix-a-compose/README.md) (every Docker Compose file
explained line by line) ·
[appendix-b-verify](appendix-b-verify/README.md) (what should just work, and how
to verify it).

## 📂 What's in each folder

```
04-pretty-urls/
├── README.md                ← the full guide for this chapter (copy-paste friendly)
├── 04-pretty-urls.pdf       ← the same chapter as a standalone PDF
├── scripts/                 ← small numbered helpers, run in order
│   ├── 01-create-homelab-network.sh
│   ├── 02-create-audiobookshelf-network-compose.sh
│   ├── 03-create-pihole-network-compose.sh
│   ├── 04-recreate-networked-services.sh
│   ├── 05-create-caddyfile.sh
│   ├── 06-create-caddy-compose.sh
│   ├── 07-start-caddy.sh
│   └── 08-add-local-dns-records.sh
└── compose/                 ← reference files to grab if you are doing it by hand
    ├── Caddyfile
    ├── caddy.compose.yaml
    ├── audiobookshelf.compose.yaml
    └── pihole.compose.yaml
```

Every chapter follows this shape: a `scripts/` folder of small numbered helpers
(`01-…`, `02-…`, in the order the chapter runs them), and, where the chapter has
you create config, a `compose/` folder with reference `compose.yaml` /
`Caddyfile` files (and the Homepage `config/` for the dashboard), ready to copy
by hand. The scripts are standalone equivalents: they write matching files inline
and then start the containers, so the manual path and script path stay aligned
without requiring the `compose/` folder. Secrets stay out; an `.env.example`
shows the shape where a `.env` is needed. (`08-remoting-phone` is reading / app
setup, so no scripts.) In the repo root:

- **[`Beginner-Homelab-on-a-Raspberry-Pi.pdf`](Beginner-Homelab-on-a-Raspberry-Pi.pdf)**.
  The entire guide as one book.

## 🔐 What the scripts cover vs. what you do by hand

The helper scripts cover only the **repeatable** steps (update, install
Docker/Tailscale, make folders, create compose/config files, create local `.env`
files, start containers). Everything use-case-specific or interactive you do
yourself, guided by each chapter's README:

- **Flashing the SD card** (done on your laptop with Raspberry Pi Imager).
- **Signing into Tailscale** (opens a browser sign-in) and **renaming the Pi**
  in the Tailscale admin console.
- **The Tailscale DNS push** (admin console → add the Pi as a nameserver + turn
  on *Override local DNS*). This is what makes `*.home` and ad-blocking work on
  all your devices.
- **Pointing your router's DNS** at the Pi (Chapter 3) for non-Tailscale devices.
- **Trusting Caddy's HTTPS cert** on your devices (Chapter 4).
- Ripping and copying your own audio, buying a VPN, installing phone apps.

## 🛟 Safety & privacy

- **No secrets in this repo.** Every service reads passwords/tokens from a local
  `.env` file the scripts create with `chmod 600` and which is `.gitignore`d.
  The guide text uses placeholders (`100.x.y.z`, `your-tailnet.ts.net`,
  `you@homelab`).
- **Nothing is port-forwarded.** Services are reached only over your
  authenticated Tailscale mesh or your home LAN.
- The scripts are safe to re-run. Starting a container that's already up just
  reconciles it; nothing is destructive.

---

*Built and tested on a Raspberry Pi 4 Model B (32 GB microSD, Argon ONE M.2
Aluminum case). Have fun, and welcome to self-hosting!* 🎉
