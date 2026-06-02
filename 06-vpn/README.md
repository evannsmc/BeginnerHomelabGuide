> [!NOTE]
> Part of my personal homelab guide, written around my own use case. This chapter
> is mostly reading / app setup (no scripts here). See the [main README](../README.md)
> for the full picture.


# Chapter 6. Why a VPN, and Mullvad vs. a standard app like Aura

> **The payoff of this chapter:** understand what a VPN actually does
> for you, see how a mainstream consumer VPN (I started with Aura)
> differs from a privacy-focused one (Mullvad), and come away knowing
> *which kind* you want and why. The plumbing, how a VPN coexists with
> your tailnet and your Pi-hole once you leave the house, is the whole
> of [Chapter 7](../07-away-from-home/README.md); this chapter is just
> about picking the right tool.

Everything so far has been about reaching *into* your homelab. This part
is the opposite direction: making your devices’ traffic leave through a
VPN, so the websites and apps you use can’t see your real IP address,
and so your ISP or a café’s Wi-Fi can’t see what you’re doing.

Maybe you already run a consumer VPN to change locations. I started with
**Aura VPN**, and it’s a perfectly good one. The goal here isn’t to talk
you out of whatever you run, it’s to lay out the landscape clearly: what
a VPN does, what the familiar consumer app (Aura is my stand-in for the
whole category) gives you, and where **Mullvad** is genuinely different,
because that difference is the thing the *next* chapter builds on.

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
last point, because a VPN wanting to own your DNS is exactly the seam
where it rubs against your Pi-hole, and that collision is the heart of
Chapter 7.

## The standard consumer VPN (Aura, and apps like it)

This is the model most people meet first: a self-contained app on each
device, one big toggle, maybe a map of countries to pick from. **Aura
VPN** is the one I started on, bundled into the Aura identity-protection
suite, and it’s a fair representative of the whole closed-consumer
category (NordVPN, ExpressVPN, and friends behave the same way).

What it does well:

- **It is genuinely easy.** Install, sign in, tap a country, done. No
  config files, no command line.
- **It changes your location convincingly** and shields you on sketchy
  Wi-Fi, which is the 90% use case most people actually have.
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

None of that makes Aura *bad*. It makes it a sealed appliance: great for
“make me look like I’m in another country for an hour,” not built to be
a Lego brick in a homelab.

## Mullvad: the privacy-first alternative

**Mullvad** comes at the same job from the opposite philosophy. Where
Aura optimizes for a frictionless consumer experience, Mullvad optimizes
for privacy and for *control*, and that control is the reason it keeps
coming up in this guide.

The concrete differences that matter:

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
- **It hands you the keys: WireGuard config files.** This is the big
  one. Mullvad lets you download standard **WireGuard** configuration
  files and run them *anywhere*, including on the headless Pi or a cheap
  Linux VPS, with no Mullvad app at all. Aura gives you nothing like
  this.

That last point is the whole reason Mullvad, and not Aura, threads
through the rest of the series. A VPN you can express as a portable
WireGuard config is a VPN you can wire into other machines, which is
exactly what Chapter 7’s exit-node tricks depend on. The trade is real,
though: you give up some of Aura’s hand-holding polish for plumbing you
assemble yourself.

> [!NOTE]
>
> ### Aura vs. Mullvad, in one breath
>
> **Aura** (and consumer VPNs like it) is a sealed, easy app: tap a
> country, you’re done, but it’s app-only, closed, and can’t leave its
> own walls. **Mullvad** is the privacy-first, control-first option: a
> flat anonymous price, a real kill switch, no-logs by design, and,
> crucially, **portable WireGuard config files you can run on any
> machine**. For casual location-changing, either is fine. For anything
> that has to mesh with a homelab, Mullvad’s openness is what makes it
> possible.

## Which one should you want?

For *this* project, lean Mullvad, for one reason above all the privacy
talking points: **it gives you artifacts you can build with.** The
portable WireGuard config is what lets a VPN live on your Pi, on a VPS,
or inside Tailscale itself. A sealed consumer app like Aura can never do
that; it can only protect the one device its app runs on.

That said, keep your perspective honest:

- If all you ever want is “look like I’m in another country on my phone
  for an hour,” a consumer app like Aura is genuinely fine, and you can
  stop here.
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
  filtering, and, the decisive feature, **portable WireGuard config
  files you can run anywhere**.
- **For a homelab, prefer Mullvad**, not mainly for the privacy slogans
  but because its config files are building blocks; a consumer app is a
  dead end the moment you want the VPN to mesh with anything else.

You now know *which kind* of VPN you want and why. The harder, more
interesting question, how that VPN coexists with your tailnet and your
Pi-hole once you walk out the door, what an **exit node** is, and what I
actually run day to day, is next, in [Chapter
7](../07-away-from-home/README.md).