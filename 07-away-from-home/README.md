> [!NOTE]
> Part of my personal homelab guide. The scripts in this folder mirror the numbered
> setup steps in the chapter: create the example files, write local `.env` files,
> and start/recreate containers. They reflect my own setup, so read them before
> running and adapt as needed. See the [main README](../README.md).


# Chapter 7. Exit nodes, the Mullvad add-on, and what I run

> **The payoff of this chapter:** the routing rule that governs VPNs on
> the road, the setup I use (a standalone Mullvad account that I can
> switch on and off, giving up homelab access while it’s on), what a
> Tailscale **exit node** is, and the paid add-on that *can* give you
> privacy and your homelab at the same time, if you’re willing to trade
> control and a few more dollars for it.

At home, the pieces share the Pi’s network. Away from home,
**Tailscale** is the link back to the Pi. This part picks up where
[Chapter 6](../06-vpn/README.md) left off: the VPN choice is made; now it
has to coexist with the homelab.

## Reaching your homelab from anywhere (the easy part)

This part already works. Because Tailscale is a mesh VPN, any device
signed into the tailnet reaches the Pi from anywhere, coffee shop,
cellular, hotel, with no extra setup:

- **Audiobookshelf:** `https://abs.home` streams just as it does at
  home.
- **The dashboard:** `https://home.home` (or `https://homelab`) opens
  from anywhere.

That is inbound access over an authenticated tunnel. The hard parts
below are outbound: where traffic exits and which DNS resolver answers.

## Pi-hole already follows you (set up in Chapter 4)

No extra setup is needed here. When Pi-hole became the tailnet DNS in
[Chapter 4](../04-pretty-urls/README.md) (the **Override local DNS**
setup), Pi-hole ad-blocking came with it on every tailnet device. On
cellular, the phone still resolves through Pi-hole, so ads stay blocked.
The same step is also what makes your `.home` names work away from home.

The conflict starts when another VPN is turned on, which is the rest of
this chapter.

> [!IMPORTANT]
>
> ### This only holds while Tailscale is the active VPN
>
> The whole mechanism rides on Tailscale being the thing controlling
> your device’s DNS. The instant another VPN takes over (next section),
> this stops applying. That’s not a bug, it’s the central tension of
> going mobile, and the rest of this chapter is about navigating it.

## The one rule that governs everything off-network

The road setup follows this rule:

> **A full-device VPN owns the default route *and* the DNS, and a device
> runs only one such VPN at a time.**

Two consequences fall out of it:

1.  **A privacy VPN and Tailscale can’t both be the active tunnel.**
    Phones make this a hard wall: iOS and Android allow exactly one
    active VPN, so turning on Mullvad (or Aura) drops Tailscale. I ran
    into the same problem on a laptop, for a different reason:
    **routing.** A Mullvad WireGuard tunnel grabs the entire default
    route, which swallows the path back to your tailnet, so the moment
    Mullvad is up, `https://homelab` and your `100.x` addresses go dark
    there too. The phone enforces “one VPN” by policy; the laptop
    enforces it by routing.
2.  **Whatever VPN is active forces its own DNS.** Even setting the
    one-VPN limit aside, the active VPN routes DNS through its own
    resolvers. So while you’re on *any* location/privacy VPN, your
    traffic is *not* going through Pi-hole, by design, to prevent DNS
    leaks.

> [!NOTE]
>
> ### Why two VPN apps don’t give you everything at once
>
> This is why “use my own VPN *and* filter through Pi-hole *and* reach
> my homelab, all at once, on one device” has no clean answer with two
> separate apps: Pi-hole and your homelab live only on your tailnet,
> reaching them needs Tailscale to be the active tunnel, and a privacy
> VPN that’s up takes that role (by policy on a phone, by routing on a
> laptop). The only real escapes are to put the privacy VPN and your
> homelab on the *same tunnel*, which is the exit-node idea further
> down, or to switch between them, which is what I do.

## What I run: keep them separate, switch per activity

After trying to have it all at once and losing (see the sidebar), I
settled on the setup that has held up for me: **I keep a standalone
Mullvad subscription and Tailscale installed side by side, and I only
ever run one at a time.** On both my laptop and my phone.

In practice that means I segregate my activities into two modes and flip
between them in a couple of seconds:

- **Tailscale on, Mullvad off (my default).** Homelab reachable, Pi-hole
  ad-blocking everywhere via the DNS push, `.home` names resolve. This
  is where I live almost all the time. The cost is that my real IP is
  showing.
- **Mullvad on, Tailscale off (when privacy matters).** Sketchy Wi-Fi,
  or I want to change region or hide my IP. While it’s on I accept that
  the homelab and Pi-hole are unavailable for that stretch, Mullvad
  carries my DNS and its own ad-blocking instead. When I’m done, Mullvad
  off, Tailscale back on.

My setup is intentionally plain. No exit node, no policy routing, no
add-on. The downside is right there in the open: **I can’t reach my
homelab while the privacy VPN is on**, so I plan around it. For me that
beats the alternatives, because I keep full control of my own Mullvad
subscription, its config files, its settings, and I’m not paying for
anything extra.

> [!NOTE]
>
> ### I tried hard to have both on one box, and couldn’t make it stick
>
> Before settling on switch-per-activity, I spent hours and hours trying
> to run Mullvad and Tailscale *simultaneously* on my laptop. The
> approaches, and why each fell over:
>
> - **Split tunneling / carving out the tailnet.** Mullvad’s WireGuard
>   config claims the entire default route (`AllowedIPs = 0.0.0.0/0`),
>   which also swallows the return path to Tailscale’s range
>   (`100.64.0.0/10`). The plan was to exclude that range from the
>   Mullvad tunnel so my devices could still reach the homelab.
> - **Forcing Tailscale’s route priority** so its `100.x` routes would
>   win over Mullvad’s catch-all default.
>
> I could occasionally get a fragile version working, but never one that
> survived a reconnect, a Mullvad server change, or a reboot. It was
> never reliable enough to trust. The lesson I took: with two separate
> full-device VPN apps, having both on at once is not a stable setup. If
> you want both at the same time, change the architecture; that’s the
> exit-node add-on below.

## The thing that *would* let you have both: an exit node

Everything above assumes two separate VPN apps. There’s a different
architecture that sidesteps the whole “one tunnel at a time” problem,
and it’s good to know even if, like me, you don’t use it yet.

Normal Tailscale is an **overlay network**: it only carries traffic
*between* your own devices (laptop ↔ `homelab` ↔ phone). Your ordinary
internet traffic still leaves through your local connection; Tailscale
doesn’t touch it.

An **exit node** changes that. You designate one device on your tailnet
as “the exit,” and your other devices route **all** their internet
traffic through it, the full default route, not just tailnet traffic. To
the outside world, your traffic now appears to come from the exit node’s
IP. That’s exactly how a traditional full-tunnel VPN behaves, except the
“VPN server” is a node on your *own* tailnet, so **you’re still on
Tailscale the whole time**. Only one exit node is active per device, and
you switch it off by selecting “None”:

``` bash
tailscale exit-node list                 # list available exit nodes
tailscale set --exit-node=<node>         # route everything through it
tailscale set --exit-node=               # turn it back off
```

Because an exit node *is* still Tailscale, choosing one doesn’t drop
your tailnet. Your homelab stays reachable while your traffic exits
somewhere else. That architecture escapes the one-rule trap, and it
comes in three flavors.

## Flavor 1 (the upgrade path): the Tailscale Mullvad add-on

This is the option that buys you privacy *and* your homelab at the same
time, and it’s the thing I’d reach for if my needs grow. Tailscale sells
access to **Mullvad’s worldwide WireGuard servers as a paid add-on
purchased through Tailscale**. Mullvad’s servers appear as selectable
exit nodes inside the tailnet:

``` bash
tailscale exit-node list                  # Mullvad cities now appear here
tailscale set --exit-node=<mullvad-node>  # exit through Mullvad, stay on Tailscale
```

On **iOS / macOS / Android**: the `•••` menu → **Use exit node** → pick
a Mullvad **location**. Because it’s still Tailscale, your homelab and
`.home` names keep working while your traffic exits through Mullvad.
That gives you both pieces: always-on privacy that doesn’t cost you the
homelab, and it’s the only option that works cleanly on a phone without
fighting the one-VPN rule.

So why don’t I run it? Because of what you give up:

- **Cost:** about **\$5/month** on top of things. If you also keep your
  own Mullvad subscription (as I do, for the control), you’re now at
  **\$10+/month** for the pair. The add-on alone (~\$5) can *replace*
  your own sub, but then you lose the next point entirely.
- **Control.** When you buy the add-on, **Tailscale provisions a Mullvad
  account for you that you have very little say over.** You don’t get
  your own Mullvad login, you can’t download WireGuard config files to
  run on the Pi or a VPS, and you can’t tune Mullvad’s own settings. You
  get exit nodes and nothing else. For someone who specifically wants to
  *own and control* their Mullvad config (which is the whole reason
  Chapter 6 pointed at Mullvad), that’s a real loss.

> [!NOTE]
>
> ### Convenience versus control
>
> It comes down to convenience versus control. The add-on gives you
> *convenience* (one tunnel, always on, homelab intact). Owning your own
> Mullvad sub gives you *control* (portable configs, full settings, no
> extra account you don’t manage). Right now I value control more, and
> I’m fine switching apps by hand to get it. If my needs shift toward
> “always-on privacy that never costs me the homelab,” I’ll pay the
> extra and run both, or move fully to the add-on. It’s a
> budget-and-priorities call, not a right-or-wrong one.

When you *do* use a Mullvad exit node, two flags matter on the road:

``` bash
# Keep access to LAN devices (printers, etc.) while using an exit node
tailscale set --exit-node=<mullvad-node> --exit-node-allow-lan-access
```

- **`--exit-node-allow-lan-access`**: by default, turning on *any* exit
  node cuts your access to the local network you’re physically on. This
  flag restores it. On mobile it’s the **Allow LAN access** toggle when
  you pick the exit node.
- **DNS leaks:** allowing LAN access can let some DNS queries escape the
  tunnel. Recent Tailscale clients (1.48.3+) route DNS correctly through
  Mullvad exit nodes without extra config, so keep your clients updated.

> [!WARNING]
>
> ### A real bug to watch for
>
> Some Tailscale client versions around 1.82 had a defect where an
> **active exit node bypassed the global Pi-hole nameserver**, so your
> ad-blocking would quietly stop whenever an exit node was on. If you
> see that symptom, update the Tailscale client first. It’s a known
> issue, not your misconfiguration.

## Flavor 2: your own Pi as an exit node (free, but not private)

You can advertise one of your *own* machines as an exit node. The helper
script in this chapter’s folder does it on the Pi:

``` bash
sudo tailscale set --advertise-exit-node
# then approve it: admin console -> Machines -> the Pi ->
#   Edit route settings -> enable "Use as exit node"
```

On Linux you also enable IP forwarding (`net.ipv4.ip_forward=1` and the
IPv6 equivalent); the script sets both.

- **What it’s good for:** routing through your **home** Pi so you appear
  to be at home, reaching home-only services, or content tied to your
  home connection, and, importantly, it’s the one exit option that keeps
  your traffic on your own network where **Pi-hole still applies**. This
  is the sweet spot when what you want on the road is ad-blocking, not
  IP-hiding.
- **What it’s not:** privacy. Traffic exits from **your own home IP**,
  so there’s no hiding. And don’t use a *phone* as an exit node, it
  routes in userspace and is slow; the Pi (kernel routing) is fine.

## Flavor 3 (advanced): a Pi-style exit node chained through Mullvad

Flavor 2 hides nothing, because the box exits from the home IP. You can
fix that by *chaining*: run an exit node that itself tunnels out through
a standalone Mullvad **WireGuard** config. Your devices reach the node
over the tailnet, and the node forwards their traffic out through
Mullvad:

    you -> Tailscale -> your exit-node box -> Mullvad WireGuard -> internet

This is the only way to use a **standalone** Mullvad subscription *as a
Tailscale exit node* without paying for the add-on, so it keeps the
control you wanted while still giving you the always-on-plus-homelab
shape. The shape of it:

1.  Use a machine that is **not your home Pi** if privacy is the goal (a
    cheap Linux VPS works well). The home Pi only makes sense for
    “appear at home,” where adding Mullvad would defeat the purpose.
2.  On that box, install Tailscale, advertise it as an exit node, and
    enable IP forwarding (same as Flavor 2).
3.  Download a **WireGuard config** from your Mullvad account and bring
    it up (`wg-quick up <conf>`) so the box’s default route leaves
    through Mullvad.
4.  The sharp edge: Mullvad’s config claims the **entire** default route
    (`AllowedIPs = 0.0.0.0/0`), which also swallows the return path to
    your tailnet. You have to keep Tailscale’s range (`100.64.0.0/10`)
    out of the Mullvad tunnel so your devices can still reach the node.
    That policy-routing fiddliness is exactly the same fight I lost on
    the laptop, just moved to a box you can leave running, and it’s the
    work the add-on saves you.

Reach for this if you already pay for Mullvad, want to keep your own
config, and enjoy the plumbing. For most people the add-on (Flavor 1)
buys the same outcome with none of the routing surgery.

## A router-level VPN might be another answer, but I can’t test it yet

A friend with 10+ years of homelab experience recently pointed out
another possible path: configure the **router itself** to connect to a
VPN. In theory, that could move the privacy tunnel out of the
phone/laptop app layer and into the network layer, which may avoid some
of the conflicts in this chapter.

I can’t validate that setup on my current hardware. My router’s firmware
is too old and does not expose the VPN-client features needed to try it.
He also doesn’t use Mullvad, so I don’t know yet whether this works
cleanly with Mullvad’s WireGuard configs or whether it introduces a
different set of routing or DNS problems.

So treat this as a lead, not a recommendation: if your router supports
acting as a WireGuard/OpenVPN client, it may be worth investigating. It
is not part of the tested setup in this guide.

## The decision matrix

You can’t have all three of {homelab access, Pi-hole filtering, privacy
VPN} on one device at one time with two separate apps. But you *can*
switch between coherent modes in seconds. Pick per situation:

| You’re away and you want… | What you turn on | Pi-hole? | Homelab? | Hides IP? |
|:---|:---|:--:|:--:|:--:|
| **Homelab + ad-blocking** (my default) | Tailscale on, no exit node | Yes | Yes | No |
| **Privacy, my way** (what I run) | Mullvad on, Tailscale off | No | No | Yes |
| **Appear at home / reach LAN** | Tailscale + Pi exit node (Flavor 2) | Yes | Yes | No |
| **Privacy *and* homelab at once** | Mullvad add-on exit node (Flavor 1) | No | Yes | Yes |

The pattern to read out of that table: with two separate apps (rows 1
and 2) you trade the whole homelab for privacy and switch between them,
which is cheap, fully under your control, and what I do. The exit-node
rows (3 and 4) are the only ways to keep the homelab *while* your
traffic exits elsewhere, and the only one of those that also hides your
IP is the paid Mullvad add-on. Two things the Yes/No columns gloss over:
in the Mullvad rows your DNS goes to Mullvad, so Pi-hole is bypassed and
you lean on Mullvad’s own ad-blocking instead; and “appear at home”
hides nothing because traffic exits from the home IP.

## A practical everyday routine

For most people the comfortable default is simple, and it’s mine:

1.  **Leave Tailscale on, no exit node, all the time.** Homelab
    reachable, Pi-hole ad-blocking everywhere via the DNS push, phone
    behaves normally. You give up IP-hiding, which most of the time you
    don’t need.
2.  **When you specifically want privacy**, switch to standalone Mullvad
    for that session and accept that the homelab steps aside until you
    switch back. Cheap, reliable, fully yours.
3.  **If “always-on privacy without ever losing the homelab” becomes
    worth the money and the loss of control**, buy the Mullvad add-on
    (Flavor 1) and let a Mullvad exit node do both at once, or stand up
    a chained exit node (Flavor 3) if you’d rather keep your own config.

## Recap: the whole series

- **Reaching your homelab away** is the free win: Tailscale makes
  `homelab:13378` and `https://home.home` work from anywhere, no extra
  setup.
- **Pi-hole on the road** rides on the Chapter 4 DNS push, and works
  only while Tailscale is your active VPN.
- **The governing rule:** a full-device VPN owns the route and DNS, and
  a device runs one at a time (by policy on a phone, by routing on a
  laptop), so a separate privacy VPN and your homelab can’t both be live
  with two apps.
- **What I run:** a standalone Mullvad I keep fully under my own
  control, switched on only when I want privacy, accepting that the
  homelab is offline while it’s on. Boring, reliable, cheap.
- **The escape hatch, when you want both at once:** an **exit node**,
  most easily the paid **Mullvad add-on**, which trades some control and
  a few more dollars for always-on privacy that never costs you the
  homelab.

With that, your homelab is fully mobile: an always-on Raspberry Pi that
streams your media, blocks ads on every device, presents a single
`https://home.home` control panel, and gives you a deliberate,
switchable answer for privacy on the road. All of it private by default,
over one Tailscale network, with nothing exposed to the public internet.

That completes the core of the homelab. **Volume III** is the extras:
getting a *phone and Linux machines* to talk to each other for everyday
remoting, file transfer, and clipboard sharing, starting with [Chapter
8](../08-remoting-phone/README.md).