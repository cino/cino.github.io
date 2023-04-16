+++
author = "Ricardo Cino"
title = "Using password(les)s in 2023"
slug = "using-passwords-in-2023"
date = "2023-03-31" # change
tags = [
    "passwords",
    "passwordless",
    "1password",
    "lastpass",
    "bitwarden",
    "yubikey",
    "fido",
    "webAuthn",
    "security",
    "privacy"
]
+++

It's been almost a year since I've started using my YubiKey, even though I only recently bought a backup key (yes, you can shame me) I decided it is time to have big write up on why you should be using a hardware key with Fido2(WebAuthn) support too.
<!--more-->

## Introduction

Since using credentials online there have been countless attempts of hackers to gain access to applications and use your data to either scam you, or others and earn a lot of money. The amount of data breaches being discovered day by day is scaring to say the least, as result of this Troy Hunt created a website called [HaveIBeenPwned](https://haveibeenpwned.com/) where he keeps track of big data breaches and notifies people that they are in a breach, only if you have signed up for that ofcourse. (Tip)

These breaches should scare you if you use the same password over and over again as the possibility is that if your password is in one of the breaches, and the password was in plain text, or not properly encrypted that someone would be able to enter all your accounts. A simple solution for this would already to not use the same password over and over again but always use an unique password for each new application. More on this later.

## Most common authentication methods

### Traditional Username / Password

The traditional method of using usernames and passwords for authentication has been the cornerstone of digital security for decades. However, this approach has increasingly become a matter of concern due to its inherent vulnerabilities. A major issue with usernames and passwords is their susceptibility to brute force attacks, wherein an attacker systematically attempts various combinations of characters until they crack the correct credentials.

Additionally, users often fall into the trap of using simple, easy-to-guess passwords or reusing the same password across multiple platforms, leaving them more exposed to cyber threats. The rise of phishing and social engineering attacks further compounds these problems, as attackers deceive users into revealing their login information voluntarily. These shortcomings have led to a growing consensus that traditional username and password systems need to be supplemented or replaced with more secure and user-friendly authentication methods.

### Using a (Cloud) Password Manager

Using a password manager is a great way to securely store and manage your passwords. Password managers are software tools that help users generate strong, unique passwords for each account they have, and store them in a digital vault protected by a master password. This means users only need to remember one master password to access all their other passwords. This means you need to have a single strong master password which you definitely don't want to leak (and regurlary update), this way you don't need to remember all the generated passwords for your websites and don't need to think about those websites having weak security and leaking your password as you're only using it at that single website.

There are two types of password managers: cloud-based and self-hosted. Cloud-based password managers store encrypted password data on remote servers operated by the password manager company. Self-hosted password managers store encrypted password data on local servers controlled by the user.

The most popular password managers are:

- 1Password: A cloud-based password manager that offers features like automatic password generation, password sharing, and 2FA.
- Bitwarden: A cloud-based password manager that is open-source and offers features like secure password sharing, 2FA, and encrypted file storage.
- KeePass: A self-hosted password manager that stores encrypted password data locally on the user's device and offers features like automatic password generation and strong encryption.
- Dashlane: A cloud-based password manager that offers features like automatic password generation, password sharing, and secure digital wallet storage for credit card information.

_Lastpass is not included, [for obvious reasons](https://www.google.com/search?q=lastpass+hack+2022&biw=1997&bih=1395&ei=vvgmZMWBAceD9u8PyoOImA0&ved=0ahUKEwjF2IXIuob-AhXHgf0HHcoBAtMQ4dUDCA8&uact=5&oq=lastpass+hack+2022&gs_lcp=Cgxnd3Mtd2l6LXNlcnAQAzIHCAAQgAQQCjIHCAAQgAQQCjIHCAAQgAQQCjIJCAAQFhAeEPEEMgYIABAWEB46CQgAEB4QsAMQCjoFCAAQgARKBAhBGAFQowdY6Axg3g1oAnAAeACAAUeIAfACkgEBNpgBAKABAcgBAcABAQ&sclient=gws-wiz-serp)._

There is a difference between cloud based password managers and self hosted, when using the cloud based manager it comes with a lot of convenience as you won't have to manage a single thing. The downside is that when there is big hack like the one that happened with Lastpass there is nothing you can do about it and you'll need to change your passwords. The other side is self hosting and managing the infrastructure that is hosted on, including making sure that everything is up to date and find a way to support synchronisation across devices. The latter proves to be a pain in the ass for most and that's why most people are using cloud based password managers (as am I) and accept the small extra risk, which isn't really there when you use proper 2 factor authentication like a FIDO2 key.

### Temporarily One Time Passwords (TOTP)

Time-based One-Time Passwords (TOTP) serve as an additional layer of security to protect user accounts, commonly employed as part of a two-factor authentication (2FA) system. When using TOTP, a unique, time-sensitive code is generated by an authenticator app on a user's device, which must be entered alongside their regular password to gain access. This approach ensures that even if a user's primary login credentials are compromised, an attacker would still require possession of the device generating the TOTP codes to successfully access the account.

While it might seem convenient to store TOTP secrets within a password manager, this practice is generally discouraged. Combining both primary credentials and TOTP codes in a single repository creates a single point of failure, effectively negating the benefits of 2FA. In the event that the password manager is compromised, an attacker would have access to both the user's passwords and TOTP codes, defeating the purpose of employing a layered security approach.

I myself have stored the TOTP secrets within the password manager of my choice and acknowledge that doing this is the easy solution. While generating these from a second location is the better option this is still considered better than not doing it at all. In the event when one of your passwords has been leaked you still won't have to be worried as the TOTP secret would still be neccesary, it would only become a problem when your password manager is compromised.

### Push notification

Push message authentication is a way to make sure it's really you trying to access your online accounts. When you try to log in, you'll get a notification on your phone asking if you want to allow or deny access. You just tap on 'yes' or 'no' to respond. It's a bit like having a secret knock on your clubhouse door, but instead of knocking, your phone asks if you want to let someone in.

2FA fatigue is when you get so many of these notifications that you start to feel annoyed or tired of them. Imagine if your friends kept knocking on your door all day long, and you had to keep getting up to see who it was. Eventually, you might not even bother checking and just say "yes" without looking, accidentally letting in someone you didn't want to. That's why it's important to pay attention to these notifications and make sure you only approve access when you know it's really you trying to get in.

<img src="/img/using-passwords-in-2023/push-notification-request.webp">

## Introducing WebAuthn / FIDO2

## What is FIDO 2 / WebAuthn

FIDO2 (Fast Identity Online 2) is a new standard for secure authentication on the web. It provides a way to log in to websites and apps without the need for passwords. Instead, FIDO2 uses a variety of secure authentication factors such as biometric recognition or physical security keys.

One of the main components of FIDO2 is WebAuthn (Web Authentication), which is a special API developed by the W3C that allows users to authenticate themselves without passwords. With WebAuthn, users can use a variety of authentication factors to prove their identity, such as fingerprints, facial recognition, or physical security keys.

Here's an example of how the WebAuthn login flow might work with an email and password:

1. The user navigates to a website or app and clicks on the "Login" button.
2. The user is prompted to enter their email and password.
3. The website or app verifies the user's email and password to ensure they are valid.
4. Once the user's email and password are verified, the website or app prompts the user to set up WebAuthn authentication.
5. The user is prompted to choose a security key or biometric factor, such as a fingerprint or facial recognition, that they will use to authenticate themselves in the future.
6. The user registers their chosen security key or biometric factor with the website or app.
7. The user is now logged in and can use their security key or biometric factor to authenticate themselves for future logins, instead of their email and password.

The great thing here is that there is an actual 2 factor when using FIDO2 because there is a need of a physical / biometric factor that you need to have on you, for example I'm using a [YubiKey 5C NFC](https://www.yubico.com/product/yubikey-5c-nfc/) (not affiliated) which needs to be in the USB C port, and touched, before I'm able to login to the services I have protected with this method.

## How does it work?

Well, to explain how it works there are many good youtube video's

## WebAuthn vs Fido2, what is the difference?

FIDO2 and WebAuthn are closely related terms and are often used interchangeably, but they refer to distinct components of a larger, passwordless authentication framework.

FIDO2: FIDO2 is an overarching term that encompasses two primary components – WebAuthn and CTAP (Client-to-Authenticator Protocol). FIDO2 is a set of standards developed by the FIDO (Fast IDentity Online) Alliance, which aims to enable simpler and more secure user authentication experiences across various platforms and devices. The goal is to replace password-based authentication with more secure, passwordless methods.

WebAuthn: WebAuthn (Web Authentication) is a part of FIDO2 and is specifically a web standard developed by the World Wide Web Consortium (W3C) in collaboration with the FIDO Alliance. WebAuthn enables passwordless authentication on web applications by allowing users to register and authenticate using public key cryptography and external authenticators, such as biometrics, security keys, or mobile devices.

CTAP: CTAP is the other component of FIDO2, which allows external authenticators, like USB security keys or mobile devices, to communicate with web browsers and platforms. CTAP is a protocol that defines the communication between these authenticators and the devices they are connected to.

In summary, FIDO2 is the overarching framework that comprises both WebAuthn and CTAP. WebAuthn is a web standard focused on passwordless authentication for web applications, while CTAP is the protocol that enables communication between external authenticators and devices. Together, they create a more secure, user-friendly authentication experience that moves away from traditional passwords.

## Current support

While the prospect of this authentication method appears promising, we have not yet reached widespread adoption. At the time of writing this article, numerous websites, in fact, the majority, do not support this form of authentication. For many sites, incorporating this feature is not even on their roadmap, and it's understandable to some extent, as the decision often involves a trade-off between budget and prioritization.

Nonetheless, I firmly believe that this authentication approach represents the most effective method for the foreseeable future. It is particularly frustrating when larger companies, especially those in the payment sector, do not currently plan to implement it.

{{< tweet user="Wise" id="1641532374948388866" >}}
_still love you wise_

## My take

As explained above there are 2 major components of this new way of authentication, webAuthn and CTAP. With just the webAuthn protocol it is possible to enable passwordless logins from your mobile device / your web browser / your fingerprint scanner on your macbook and more. However I really like the other component called CTAP, for me it's a big plus to have a seperate physical "key" that is not linked to my computers. This way I can easily switch devices and don't store these keys in any form of cloud.

Does this come with an extra risk? Yes, because I'm doing it in such a way I could definitely lose the physical key that I configured all these applications with. To avoid that problem it is strongly advised to get a second key setup on all the same applications to prepare yourself for when you (hopefully not) lose the security key and have backup.

Personally I have decided to always use my Yubikey when possible, every website where I am signed up on I'll look for the possibility to add my hardware key (and back up) to ensure there is a near-zero possibility for someone to take over my accounts. This took a while before I actually committed to the cause but can say that I do not regret it, and only have become more persistent in my only security.

## Key take-aways

The most important things I'd like to share with you are;

1. Please, always use a password manager and have unique passwords for each application that you sign in too.
2. Don't store youre TOTP in your password manager.
3. Don't use Push notifications to authenticate your requests as this will cause 2fa fatigue at one point.
4. Look into the possibilities of FIDO2/webAuthn to improve your personal security everywhere you can.

_this was definitly partly written by ChatGTP, yes I am lazy_
