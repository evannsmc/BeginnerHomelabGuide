

# Part 6 — VPN privacy: Aura, Mullvad, and your options

> **The payoff of this part:** understand what a VPN actually does for
> you, see how the VPN you already use (Aura) compares to a
> privacy-focused option (Mullvad), and learn the Tailscale-native way
> to route traffic — the *exit node* — so you can pick the setup that
> fits. The messier question of how all this behaves *away from home*
> (and how it collides with your Pi-hole) gets its own treatment in
> [Part 7](../07-away-from-home/README.md).

Everything so far has been about reaching *into* your homelab. This part
is the opposite direction: making your devices’ traffic leave through a
VPN, so the websites and apps you use can’t see your real IP address,
and so your ISP or a café’s Wi-Fi can’t see what you’re doing.

You already use **Aura VPN** to change locations. That’s a perfectly
good consumer VPN. The goal here isn’t to talk you out of it — it’s to
lay out the landscape clearly: what a VPN does, where Aura fits, where
**Mullvad** fits, and the one Tailscale concept (the **exit node**) that
ties VPNs into the homelab you’ve been building.

## What a VPN does (and what it doesn’t)

A VPN routes all your internet traffic through a remote server before it
reaches the wider internet. Two practical consequences:

- **Your IP is hidden.** Sites see the VPN server’s address, not yours —
  useful for privacy and for appearing to be in another location.
- **Your local network can’t snoop.** On untrusted Wi-Fi, the airport or
  hotel can see only that you’re talking to a VPN, not what you’re
  doing.

What a VPN does *not* do: it isn’t anonymity (the VPN provider can see
your traffic, so provider trust matters), and it doesn’t block ads by
itself unless the provider offers DNS-level filtering. Keep that
ad-blocking caveat in mind — it’s the seam where VPNs and your Pi-hole
rub against each other, which is exactly the Part 7 discussion.

## The Tailscale exit node — a VPN built from your own tailnet

Before comparing products, here’s the concept that makes Tailscale
relevant to VPNs at all.

Normal Tailscale is an **overlay network**: it only carries traffic
*between* your own devices (laptop ↔ `homelab` ↔ phone). Your ordinary
internet traffic still leaves through your local connection; Tailscale
doesn’t touch it.

An **exit node** changes that. You designate one device on your tailnet
as “the exit,” and other devices route **all** their internet traffic
through it — the full default route, not just tailnet traffic. To the
outside world, your traffic now appears to come from the exit node’s IP.
That’s exactly how a traditional full-tunnel VPN behaves, except the
“VPN server” is a node on your own tailnet. Only one exit node is active
per device at a time, and you switch it off by selecting “None.”

This matters because Tailscale can use **Mullvad’s servers as exit
nodes** — giving you a real privacy VPN *inside* the same Tailscale app
you already run, with no second VPN client. That’s the key to making VPN
and homelab coexist, and it’s why Mullvad gets special attention below.

## Your three real options

### Option A — Tailscale’s Mullvad add-on *(best fit for this homelab)*

Tailscale sells access to Mullvad’s worldwide WireGuard servers as a
paid add-on **purchased through Tailscale** — no separate Mullvad
subscription. Mullvad’s servers simply appear as selectable exit nodes
inside your tailnet.

- **Cost:** about **\$5/month**. Tailscale describes this as 5
  “licenses,” where one license covers up to 5 devices. (Tailscale’s
  marketing page and its docs state the device math slightly differently
  — confirm the exact count at the checkout screen before buying.)

- **Enable it:** admin console → **Settings** → the **Mullvad** section
  → **Configure**, complete checkout, then grant your devices access.

- **Use it (Linux):**

  ``` bash
  tailscale exit-node list                 # list Mullvad cities/servers
  tailscale set --exit-node=<mullvad-node> # route everything through it
  tailscale set --exit-node=               # turn it back off
  ```

  On **iOS / macOS / Android**: the `•••` menu → **Use exit node** →
  pick a Mullvad **location**.

- **Why it’s the best fit here:** it *is* Tailscale, so it coexists with
  everything you’ve built — and crucially, it’s the only option that
  works on your iPhone *without* fighting Tailscale (more on that in
  Part 7). The `--exit-node` choice is persistent across reboots, so
  “always on” is just setting it once.

### Option B — A standalone VPN app (Aura, or the Mullvad app)

This is what you do today with **Aura**: a self-contained VPN app on
each device that you toggle on to change location.

- **Aura:** part of the Aura identity-protection suite. A closed
  consumer app — easy to use, location-switching, with split tunneling
  on its supported platforms. It’s fine for casual “make me look like
  I’m elsewhere.” Its limitations for *this* project: it’s app-only
  (there’s no client you can run on the headless Pi, and no WireGuard
  config files to reuse), and like any full-device VPN it takes over DNS
  while it’s on.
- **Mullvad app:** a flat **€5/month** (~\$5.40), up to 5 devices,
  includes a proper **kill switch**, and — unlike Aura — Mullvad hands
  you **WireGuard config files** you can run anywhere, including on the
  Pi. That openness is what makes the advanced setups in Part 7
  possible.

The catch with *any* standalone VPN app is how it coexists with
Tailscale — a genuinely thorny topic that’s the heart of Part 7. The
short version: **phones run only one VPN at a time**, so the
Aura/Mullvad app and Tailscale are mutually exclusive on your iPhone.

### Option C — Your Pi as a self-hosted exit node (free, but not private)

You can advertise one of your *own* machines as an exit node:

``` bash
sudo tailscale set --advertise-exit-node
# then approve it: admin console -> Machines -> the device ->
#   Edit route settings -> enable "Use as exit node"
```

On Linux you also enable IP forwarding (`net.ipv4.ip_forward=1` and the
IPv6 equivalent).

- **What it’s good for:** routing through your **home** Pi so you appear
  to be at home — reaching home-only services, or content tied to your
  home connection — and, importantly, it’s the one exit option that
  keeps your traffic on your own network where **Pi-hole still
  applies**.
- **What it’s not:** privacy. Traffic exits from **your own IP**, so
  there’s no hiding. And don’t use a *phone* as an exit node — it routes
  in userspace and is slow; the Pi (kernel routing) is fine.

## Recommendation

For a homelab that’s already built on Tailscale and a user who wants
privacy *and* wants it to mesh with everything else:

- **For privacy / location changing: Option A (Tailscale’s Mullvad
  add-on).** It’s the same price ballpark as Aura or a standalone
  Mullvad sub, but it lives inside the one VPN your devices already run
  — so it’s the only choice that works cleanly on your iPhone alongside
  the rest of the homelab, and the setting persists across reboots for
  true “always on.”
- **Keep Option C (Pi as exit node) in your pocket** as a complement,
  not a replacement: flip to it when you want to appear at home or keep
  Pi-hole filtering active.
- **Aura (Option B) is fine to keep** as a standalone tool, but
  understand it won’t integrate with the homelab — it can’t run on the
  Pi, and on your phone it can’t run at the same time as Tailscale. That
  trade-off, and how to live with it on the road, is precisely what Part
  7 unpacks.

> [!NOTE]
>
> ### “Always on” in one line
>
> With Option A, `tailscale set --exit-node=<mullvad-node>` (or picking
> a location in the mobile app) sticks across reboots and reconnects —
> you set it once per device. If the exit node ever becomes unreachable,
> traffic *fails closed* rather than leaking out your real connection,
> which is the behavior you want for an always-on privacy setup.

## Recap

- A **VPN** hides your IP and shields your traffic from the local
  network — but it isn’t anonymity and doesn’t block ads on its own.
- A Tailscale **exit node** is a VPN built from your tailnet; with the
  **Mullvad add-on**, Mullvad’s servers *are* your exit nodes, inside
  the app you already run.
- Three options: **A)** Tailscale’s Mullvad add-on (best fit, works on
  iPhone), **B)** a standalone app like Aura or Mullvad’s own, **C)**
  your Pi as a free-but-not-private exit node.
- **Recommendation:** use Option A for privacy, keep Option C for
  appear-at-home, and know Aura’s limits before relying on it.

You now know your VPN options and how to turn each one on. The hard part
— what actually happens to your Pi-hole, your homelab access, and your
VPN when you walk out the front door, and how to get a setup that
doesn’t fight itself — is next, in [Part 7](../07-away-from-home/README.md).
