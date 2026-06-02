> [!NOTE]
> Part of my personal homelab guide, written around my own use case. This chapter
> is mostly reading / app setup (no scripts here). See the [main README](../README.md)
> for the full picture.


# Chapter 6. Why a VPN, and Mullvad vs. a standard app like Aura

> **The payoff of this chapter:** understand what a VPN does for you,
> see how a mainstream consumer VPN (I started with Aura) differs from a
> privacy-focused one (Mullvad), and decide which kind fits this
> homelab. The plumbing, how a VPN coexists with the tailnet and Pi-hole
> away from home, is the whole of [Chapter
> 7](../07-away-from-home/README.md); this chapter is about choosing the
> kind of VPN to build around.

Everything so far has been about reaching *into* your homelab. This part
is the opposite direction: making your devices’ traffic leave through a
VPN, so the websites and apps you use can’t see your real IP address,
and so your ISP or a café’s Wi-Fi can’t see what you’re doing.

Maybe a consumer VPN is already in the mix for changing locations. I
started with **Aura VPN**, and it did that job well. I use Aura here as
the stand-in for that whole category: NordVPN, ExpressVPN, and the other
closed apps built around one big connect button. Mullvad matters in this
guide because it can hand over plain WireGuard configs, which gives the
homelab something to build with in the next chapter.

## What a VPN does (and what it doesn’t)

A VPN routes all your internet traffic through a remote server before it
reaches the wider internet. Two practical consequences:

- **Your IP is hidden.** Sites see the VPN server’s address, not yours,
  useful for privacy and for appearing to be in another location.
- **Your local network can’t snoop.** On untrusted Wi-Fi, the airport or
  hotel can see only that you’re talking to a VPN, not what you’re
  doing.

What a VPN does *not* do: it isn’t anonymity (the VPN provider can see
your traffic, so provider trust matters), and it doesn’t block ads by
itself unless the provider offers DNS-level filtering. Hold onto that
last point, because a VPN wanting to own your DNS is where it rubs
against Pi-hole, and that collision is the heart of Chapter 7.

## The standard consumer VPN (Aura, and apps like it)

This is the model most people meet first: a self-contained app on each
device, one big toggle, maybe a map of countries to pick from. **Aura
VPN** is the one I started on, bundled into the Aura identity-protection
suite, and it’s a fair representative of the whole closed-consumer
category (NordVPN, ExpressVPN, and friends behave the same way).

What it does well:

- **It is easy to use.** Install, sign in, tap a country, done. No
  config files, no command line.
- **It changes your location convincingly** and shields you on sketchy
  Wi-Fi, which is the common use case.
- **It has split tunneling on its supported platforms**, so you can
  exempt chosen apps from the tunnel.

Where this category runs into walls for *our* purposes:

- **It’s app-only.** There’s no client you can run on a headless
  Raspberry Pi, and no portable config you can lift out and reuse
  elsewhere. The VPN lives and dies inside the vendor’s app.
- **It’s a closed box.** You can’t see exactly what it does, you trust
  the vendor’s policy, and your VPN identity is tied to the larger
  account (with Aura, your identity-protection subscription).
- **Like any full-device VPN, it takes over DNS while it’s on.** That’s
  normal and even desirable (it prevents DNS leaks), but it’s also
  precisely why it will fight your Pi-hole later.

None of that makes Aura *bad*. It makes it a sealed appliance: useful
for “make me look like I’m in another country for an hour,” not built to
be reused by a Pi, VPS, or exit-node setup.

## Mullvad: the privacy-first alternative

**Mullvad** comes at the same job from the opposite philosophy. Where
Aura optimizes for a frictionless consumer experience, Mullvad optimizes
for privacy and for *control*, and that control is the reason it keeps
coming up in this guide.

The points that pushed me toward it:

- **A flat, anonymous price.** A flat **€5/month** (about \$5.40), up to
  5 devices, with no tiered “identity suite” wrapped around it. You can
  even pay by generating an anonymous account number rather than handing
  over an email.
- **A serious no-logs posture.** Privacy is the product, not an add-on
  feature, and Mullvad has a public track record (audits, no-logging
  design) that a bundled consumer VPN generally doesn’t lead with.
- **A real kill switch**, so if the tunnel drops, your traffic stops
  rather than leaking out your real connection.
- **Built-in DNS ad and tracker blocking**, which becomes a useful
  stand-in on the road when your traffic isn’t going through Pi-hole
  (see Chapter 7).
- **It hands over WireGuard config files.** This is the feature I care
  about most. Mullvad lets you download standard **WireGuard**
  configuration files and run them *anywhere*, including on the headless
  Pi or a cheap Linux VPS, with no Mullvad app at all. Aura gives you
  nothing like this.

That last point is why Mullvad, not Aura, threads through the rest of
the series. A portable WireGuard config can run on another machine,
which is what the exit-node setups in Chapter 7 need. The trade is real:
less hand-holding, more plumbing to assemble yourself.

> [!NOTE]
>
> ### Aura vs. Mullvad
>
> **Aura** (and consumer VPNs like it) is a sealed app: tap a country
> and connect, but it stays inside the vendor’s client. **Mullvad** is
> the privacy-first, control-first option: a flat anonymous price, a
> real kill switch, no-logs by design, and **portable WireGuard config
> files you can run on any machine**. For casual location-changing,
> either is fine. For a VPN that needs to mesh with a homelab, Mullvad
> is the useful shape.

## Which one should you want?

For *this* project, lean Mullvad, for one reason above all the privacy
talking points: **it gives you artifacts you can build with.** The
portable WireGuard config is what lets a VPN live on your Pi, on a VPS,
or inside Tailscale itself. A sealed consumer app like Aura can never do
that; it can only protect the one device its app runs on.

Still, keep some perspective:

- If all you ever want is “look like I’m in another country on a phone
  for an hour,” a consumer app like Aura is fine, and this chapter is
  enough.
- If you want the VPN to become *part of the homelab*, always-on privacy
  that still lets you reach your Pi, or a private exit you control, you
  want Mullvad’s openness, and you want Chapter 7.

## Recap

- A **VPN** hides your IP and shields your traffic from the local
  network, but it isn’t anonymity and doesn’t block ads on its own.
- The **standard consumer model** (Aura, and apps like it) is sealed and
  easy: one toggle, one country picker, but app-only, closed, and it
  can’t run on the Pi or be reused elsewhere.
- **Mullvad** is the privacy-first, control-first alternative: flat
  anonymous pricing, a real kill switch, no-logs by design, built-in DNS
  filtering, and **portable WireGuard config files you can run
  anywhere**.
- **For a homelab, prefer Mullvad**, not mainly for the privacy slogans
  but because its config files are building blocks; a consumer app is a
  dead end the moment you want the VPN to mesh with anything else.

Next is the harder part: how that VPN coexists with the tailnet and
Pi-hole away from home, what an **exit node** is, and what I run day to
day. That’s [Chapter 7](../07-away-from-home/README.md).