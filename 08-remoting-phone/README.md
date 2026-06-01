> [!NOTE]
> Part of my personal homelab guide, written around my own use case. This chapter
> is mostly reading / app setup (no scripts here). See the [main README](../README.md)
> for the full picture.


# Chapter 8. Remoting into your machines from your phone

> **The payoff of this chapter:** open a terminal on your Pi, or a full
> graphical desktop on your laptop, straight from your phone, anywhere,
> by typing the machine’s name. No IP addresses, no port forwarding,
> just the Tailscale name.

By now everything on your tailnet is reachable by name. This chapter
puts that to work from the device you always have on you: your phone.
Two tools cover the two things you’ll actually want:

| Tool | What it gives you | Good for |
|----|----|----|
| **Termius** | An SSH terminal (command line) | The headless Pi, or any server |
| **NoMachine** | A full remote **desktop** (mouse, windows) | A machine that has a GUI (your laptop/desktop) |

The Pi has no desktop, so you reach it with **Termius** (SSH). When you
want to click around a real desktop from your phone, that’s
**NoMachine**, pointed at a machine that actually runs one.

> [!TIP]
>
> ### Name your machines first, it makes all of this painless
>
> Everything below addresses machines by their **Tailscale name**, so
> before anything else, give each device a clear, memorable name. In the
> Tailscale admin console (<https://login.tailscale.com>) open the
> **Machines** page, and for each device use the `⋯` menu and **Edit
> machine name** to set something obvious like `homelab`, `laptop`, or
> `desktop`. With MagicDNS on (Chapter 1), every device on your tailnet
> can then reach each one by that bare name. Vague auto-generated names
> like `desktop-3f2a` are the thing that makes remote access annoying;
> fix that once here.

## Part A. SSH from your phone with Termius

**Termius** is a free, polished SSH client for iOS and Android. Because
your phone runs Tailscale, it resolves your machine names directly, so
you connect to `homelab` exactly like you would from your laptop.

### Step 1: Confirm your phone is on the tailnet

Open the **Tailscale** app on the phone and make sure it’s connected
(you set this up in Chapter 1). That’s what lets `homelab` resolve. On
cellular or any Wi-Fi, it just works.

### Step 2: Install Termius and add the Pi as a host

Install **Termius** from the App Store or Play Store, then add a new
host:

- **Hostname / Address:** the Tailscale name of the machine,
  e.g. `homelab` (or its full name `homelab.your-tailnet.ts.net`, or the
  `100.x.y.z` Tailscale IP if a bare name ever doesn’t resolve).
- **Username:** your account on that machine (the one you use for
  `ssh you@homelab`).
- **Port:** 22.

### Step 3: Authenticate with an SSH key

Your Pi only accepts **key-based** login (Chapter 1), so Termius needs a
key it trusts. Two easy ways:

- **Generate a key in Termius** (Keychain → new key), copy its
  **public** key, and append it to the Pi’s `~/.ssh/authorized_keys`
  from a machine that’s already logged in:

  ``` bash
  echo 'ssh-ed25519 AAAA... (the public key Termius shows you)' >> ~/.ssh/authorized_keys
  ```

- **Or import the key you already use** from your laptop into Termius’s
  Keychain, since that key is already authorized on the Pi.

Attach the key to the host, tap to connect, and you have a terminal on
the Pi from your phone. From here you can run `docker compose`, check
logs, restart a service, anything you’d do over SSH at your desk.

## Part B. A full desktop with NoMachine

Sometimes you want a real **graphical desktop**, not a terminal: a
browser, a file manager, a GUI app. **NoMachine** streams a machine’s
desktop to your phone, fast enough to actually use. It needs a machine
that **has** a desktop, so this is for your **Linux laptop or desktop**,
not the headless Pi.

### Step 4: Install the NoMachine server on the GUI machine

On the machine whose desktop you want to reach (your laptop/desktop),
download the NoMachine package for your system from
<https://www.nomachine.com/download> and install it. On Debian/Ubuntu
that’s the `.deb`:

``` bash
sudo dpkg -i nomachine_*.deb      # then, if it complains about deps:
sudo apt --fix-broken install
```

Installing it starts the NoMachine **server**, which listens on port
**4000**. You don’t need to open any router ports: your phone reaches it
over Tailscale.

> [!WARNING]
>
> ### Keep NoMachine on the tailnet only
>
> Don’t port-forward 4000 from your router. NoMachine should be
> reachable **only** over your tailnet (and your LAN), exactly like
> everything else in this series. The Tailscale tunnel is already
> encrypted; NoMachine adds its own login on top.

### Step 5: Connect from the phone by name

Install the **NoMachine** app on your phone, then add a connection:

- **Host:** the machine’s Tailscale name, e.g. `desktop` (or its
  `100.x.y.z`).
- **Port:** 4000.
- **Protocol:** NX.

Log in with that machine’s normal user account, and its desktop appears
on your phone, controllable by touch. The machine needs to be **on,
awake, and logged in to a desktop session** for this to work. When you
only need the command line, or you’re reaching the Pi, use Termius from
Part A instead.

## Recap

- **Name every machine** clearly on the Tailscale Machines page so the
  rest is just typing a name.
- **Termius** gives you an SSH terminal from your phone, addressed by
  Tailscale name, with key auth, the right tool for the headless Pi.
- **NoMachine** gives you a full remote desktop from your phone, for
  machines that actually run a desktop, over the tailnet with nothing
  exposed to the internet.