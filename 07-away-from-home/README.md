

# Part 7 — On the road: your homelab, Pi-hole, and VPN away from home

> **The payoff of this part:** a clear, honest map of what you can and
> can’t have when you leave the house — reaching your homelab remotely,
> carrying Pi-hole’s ad-blocking with you, and running a VPN — plus the
> one rule that explains why you can’t always have all three at once on
> the same device.

At home, everything is easy: your devices share the Pi’s network and
everything just works. The moment you walk out the door, the only thing
connecting your phone to your Pi is **Tailscale**. This part is the
field manual for that world.

## Reaching your homelab from anywhere (the easy part)

This one already works, and it’s the cleanest win. Because Tailscale is
a mesh VPN, any device signed into your tailnet reaches the Pi from
anywhere — coffee shop, cellular, hotel — with no extra setup:

- **Audiobookshelf:** `http://abs.home` streams just as it does at home.
- **The dashboard:** `http://home.home` (or `http://homelab`) opens from
  anywhere.

The reason it’s effortless is that you’re only reaching *into* your own
network over an authenticated tunnel. The hard parts below are all about
the *outbound* direction — what your traffic does and which DNS resolves
it.

## Pi-hole already follows you (set up in Part 4)

You don’t need to do anything here — when you made Pi-hole your
tailnet’s DNS in [Part 4](../04-pretty-urls/README.md) (the **Override local
DNS** setup), you also got Pi-hole’s ad-blocking on every device,
everywhere. On cellular, your phone still resolves through Pi-hole, so
ads stay blocked. The same step is also what makes your `.home` names
work away from home.

That’s the good news. The catch is what happens when you turn on
*another* VPN — which is the rest of this chapter.

> [!IMPORTANT]
>
> ### This only holds while Tailscale is the active VPN
>
> The whole mechanism rides on Tailscale being the thing controlling
> your device’s DNS. The instant another VPN takes over (next section),
> this stops applying. That’s not a bug — it’s the central tension of
> going mobile, and the rest of this chapter is about navigating it.

## The one rule that governs everything off-network

Here it is, the rule that explains every “why can’t I just…” on the
road:

> **A full-device VPN owns the default route *and* the DNS. A phone runs
> only one VPN at a time.**

Two consequences fall out of it:

1.  **Aura and Tailscale can’t both be on (on a phone).** iOS and
    Android allow exactly one active VPN. Turn on Aura to change
    location, and Tailscale drops — which means your
    Pi-hole-over-Tailscale push and your `http://homelab` access both go
    dark, because the Pi’s `100.x` address is only reachable over
    Tailscale.
2.  **Whatever VPN is active forces its own DNS.** Even setting the
    one-VPN limit aside, the active VPN routes DNS through its own
    resolvers. So while you’re on *any* location/privacy VPN, your
    traffic is *not* going through Pi-hole — by design, to prevent DNS
    leaks.

`★ Insight ─────────────────────────────────────` This is why “use my
own VPN *and* filter through Pi-hole, on my phone, away from home” has
no clean answer: Pi-hole lives only on your tailnet, reaching it needs
Tailscale to be the active VPN, and a phone can’t run two VPNs. The only
ways out are to (a) make Pi-hole publicly reachable — a security no-go —
or (b) make the VPN and Pi-hole live on the *same box you route
through*, which is the Mullvad-via-Tailscale exit-node architecture, not
a separate app like Aura.
`─────────────────────────────────────────────────`

## The decision matrix

You can’t have all three of {homelab access, Pi-hole filtering, privacy
VPN} on one device at one time. But you *can* switch between coherent
modes in seconds. Pick per situation:

| You’re away and you want… | Set this | Pi-hole? | Homelab? | Hides IP? |
|----|----|----|----|----|
| **Homelab + ad-blocking** (the everyday default) | Tailscale on, no exit node | ✅ via DNS push | ✅ | ❌ (your real IP) |
| **Appear at home / reach LAN** | Tailscale + **Pi as exit node** (Part 6 C) | ✅ | ✅ | ❌ (home IP) |
| **Privacy / change location** | **Mullvad exit node** (Part 6 A) | ❌ Mullvad’s DNS | ✅ (LAN access on) | ✅ |
| **Privacy via your existing app** | **Aura** on | ❌ Aura’s DNS | ❌ (Tailscale off) | ✅ |

The pattern to read out of that table:

- **The Mullvad exit node (Option A) is the only privacy choice that
  keeps your homelab reachable**, because it *is* Tailscale — your
  tunnel to `homelab` stays up while Mullvad handles egress. It does,
  however, hand DNS to Mullvad, so Pi-hole is bypassed (use Mullvad’s
  own ad-blocking DNS as a substitute).
- **Aura gives you privacy but takes everything else down** while it’s
  on, since it displaces Tailscale entirely on the phone. Fine for a
  quick “look like I’m elsewhere” session; not a mode you live in if you
  want your homelab.
- **The Pi-as-exit-node mode is the sweet spot when you want Pi-hole
  filtering on the road** — your traffic goes home, gets filtered by
  Pi-hole, and exits from your home IP. No privacy, but full ad-blocking
  and full homelab access.

## Making a Mullvad exit node behave on the road

If you go with the Mullvad add-on (Part 6’s recommendation), two flags
matter when you’re mobile:

``` bash
# Keep access to LAN devices (printers, etc.) while using an exit node
tailscale set --exit-node=<mullvad-node> --exit-node-allow-lan-access
```

- **`--exit-node-allow-lan-access`**: by default, turning on *any* exit
  node cuts your access to the local network you’re physically on. This
  flag restores it. On mobile, it’s the **Allow LAN access** toggle when
  you pick the exit node.
- **DNS leaks:** allowing LAN access can let some DNS queries escape the
  tunnel. Recent Tailscale clients (1.48.3+) route DNS correctly through
  Mullvad exit nodes without extra config — keep your clients updated.

> [!WARNING]
>
> ### A real bug to watch for
>
> Some Tailscale client versions around 1.82 had a defect where an
> **active exit node bypassed the global Pi-hole nameserver** — so your
> ad-blocking would quietly stop whenever an exit node was on, even when
> you expected the DNS push to apply. If you see that symptom, update
> the Tailscale client first. It’s a known issue, not your
> misconfiguration.

## A practical everyday routine

For most people the comfortable default is simple:

1.  **Leave Tailscale on, no exit node, all the time.** This is the
    everyday mode: homelab reachable, Pi-hole ad-blocking everywhere via
    the DNS push, and your phone behaves normally. You give up
    IP-hiding, which most of the time you don’t need.
2.  **When you specifically want privacy** (sketchy Wi-Fi, want to
    change region): flip on the **Mullvad exit node** for that session.
    Accept that Pi-hole steps aside for Mullvad’s DNS while it’s on,
    then flip it back to None when you’re done.
3.  **Retire Aura, or keep it only as an occasional standalone tool.**
    Anything Aura does for you on the road, the Mullvad exit node does
    too — while staying inside the one VPN that keeps the rest of your
    homelab alive. The only reason to reach for Aura is if you
    specifically want its app or its kill switch on a device where
    you’re not using Tailscale anyway.

## Recap — and the whole series in one breath

- **Reaching your homelab away** is the free win: Tailscale makes
  `homelab:13378` and `http://homelab` work from anywhere, no extra
  setup.
- **Pi-hole on the road** takes one change — add the Pi as a custom
  nameserver in the Tailscale admin console and turn on **Override local
  DNS** — and works only while Tailscale is your active VPN.
- **The governing rule:** a full-device VPN owns DNS, and a phone runs
  one VPN at a time — so homelab access, Pi-hole filtering, and a
  privacy VPN can’t all be on at once. Switch between modes using the
  decision matrix.
- **Best privacy-with-homelab combo:** the Mullvad exit node, because it
  lives inside Tailscale. **Best ad-blocking-on-the-road combo:** the Pi
  as your exit node. **Aura** stays a standalone fallback.

With that, your homelab is fully mobile: an always-on Raspberry Pi that
streams your media, blocks ads on every device, presents a single
`http://home.home` control panel, and — when you understand the one-VPN
rule — gives you a deliberate, switchable answer for privacy and
ad-blocking the moment you step out the door. All of it private by
default, over one Tailscale network, with nothing exposed to the public
internet.

One direction is still missing: getting your *phone and your Linux
machines* to talk to each other for everyday file transfer and clipboard
sharing. That’s [Part 8](../08-phone-linux/README.md), the finale.
