---
title: Rescue to Grub Not Found
date: 2015-11-24 22:07:12
tags:
  - computer
  - grub
categories:
  - Notes
---

# Grub Rescue Unknown Filesystem, but you can!

> If you are working with computers especially dual-system, you may have gotten such situation showed below. It means the computer can't find the correct [Grub, Grand Unified Bootloader.](https://zh.wikipedia.org/wiki/GNU_GRUB) So you need to help him load the correct file.

---

If you want to solve it, follow the steps and you can make it.

<!-- more -->

## Steps

1. Pre-condition.
   Just make sure your grub **works** fine

2. Type ls to get all available things.
   ```
   grub rescue > ls
   (hd0) (hd0,msdos1) (hd0,msdos3) .... (hd1,msdos8)
   ```

3. Type ls every_result, such as ls (hd0,msdos1), got before. And remember the result(s) whose output is different from others.
   ```
   grub rescue > ls (hd0)
   grub rescue > ls (hd0,msdos1)
   ...
   ```

4. Type **ls** special_result/boot/grub to find whether there is grub or not.
   ```
   grub rescue > ls (hd0,msdos1)/boot/grub
   ```

5. If it is, then congratulations to you. You have find the correct grub. And now, all you need to do is **reset** it.
   ```
   grub rescue > set root=(hd0,msdos1)
   grub rescue > set prefix=(hd0,msdos1)/boot/grub
   grub rescue > insmod /boot/grub/normal.mod
   ```

6. After step 5, the "grub rescue >" will be brighter.
   ```
   grub rescue > normal
   ```

---

## Congratulations!

Your computer can start normally. And enjoy it :)

11th Nov 2015
